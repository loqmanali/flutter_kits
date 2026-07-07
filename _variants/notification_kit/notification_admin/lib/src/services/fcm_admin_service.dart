import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pointycastle/export.dart';

import '../domain/entities/notification_priority.dart';
import '../domain/entities/notification_request.dart';
import '../domain/entities/notification_target_type.dart';
import '../domain/failures/notification_failures.dart';

// =============================================================================
// MODELS
// =============================================================================

/// Result of sending a notification
class NotificationSendResult {
  final bool success;
  final String? messageId;
  final String? error;

  const NotificationSendResult({
    required this.success,
    this.messageId,
    this.error,
  });

  factory NotificationSendResult.success(String messageId) {
    return NotificationSendResult(
      success: true,
      messageId: messageId,
    );
  }

  factory NotificationSendResult.failure(String error) {
    return NotificationSendResult(
      success: false,
      error: error,
    );
  }
}

/// OAuth2 Access Token for Firebase Admin SDK
class FirebaseAccessToken {
  String? _token;
  DateTime? _expiry;

  String get token => _token ?? '';
  bool get isExpired => _expiry == null || DateTime.now().isAfter(_expiry!);

  void setToken(String token, int expiresIn) {
    _token = token;
    _expiry = DateTime.now().add(Duration(seconds: expiresIn));
  }

  void clear() {
    _token = null;
    _expiry = null;
  }
}

// =============================================================================
// ABSTRACT SERVICE
// =============================================================================

/// Service for sending notifications via FCM API
abstract class FCMAdminService {
  /// Send a notification request
  Future<Either<NotificationFailure, NotificationSendResult>> sendNotification(
    NotificationRequest request,
  );

  /// Send a notification to multiple devices (batch)
  Future<Either<NotificationFailure, List<NotificationSendResult>>>
      sendBatchNotifications(
    List<NotificationRequest> requests,
  );
}

// =============================================================================
// FIREBASE HTTP v1 API IMPLEMENTATION
// =============================================================================

/// Implementation using Firebase Cloud Messaging HTTP v1 API
/// with OAuth2 authentication using Service Account
class FCMAdminServiceImpl implements FCMAdminService {
  final Dio _dio;
  final String projectId;
  final Map<String, dynamic> serviceAccount;

  final _accessToken = FirebaseAccessToken();

  FCMAdminServiceImpl({
    required this.projectId,
    required this.serviceAccount,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Create from service account JSON map
  factory FCMAdminServiceImpl.fromServiceAccountJson(
    Map<String, dynamic> json, {
    Dio? dio,
  }) {
    return FCMAdminServiceImpl(
      projectId: json['project_id'] as String,
      serviceAccount: json,
      dio: dio,
    );
  }

  /// Create from service account JSON string
  factory FCMAdminServiceImpl.fromServiceAccountString(
    String jsonString, {
    Dio? dio,
  }) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return FCMAdminServiceImpl.fromServiceAccountJson(json, dio: dio);
  }

  /// Create from service account JSON file in assets
  static Future<FCMAdminServiceImpl> fromAssets({
    String assetPath = 'assets/burger-republic-app-359140fa6f0a.json',
    Dio? dio,
  }) async {
    final jsonString = await rootBundle.loadString(assetPath);
    return FCMAdminServiceImpl.fromServiceAccountString(jsonString, dio: dio);
  }

  @override
  Future<Either<NotificationFailure, NotificationSendResult>> sendNotification(
    NotificationRequest request,
  ) async {
    try {
      final validationError = request.validate();
      if (validationError != null) {
        return Left(
          FCMFailure(message: validationError),
        );
      }

      // Get fresh access token
      final tokenResult = await _getAccessToken();
      if (!tokenResult) {
        return const Left(
          FCMFailure(message: 'Failed to get OAuth2 access token'),
        );
      }

      // Build FCM v1 API request
      final fcmRequest = _buildV1Request(request);

      final response = await _dio.post(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
        data: fcmRequest,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_accessToken.token}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Right(
          NotificationSendResult.success(
            response.data['name'] ?? 'sent',
          ),
        );
      }

      return Left(
        FCMFailure(
          message:
              'Failed to send notification: ${response.statusCode} - ${response.data}',
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _accessToken.clear();
        return const Left(
          FCMFailure(
            message: 'Unauthorized - check service account credentials',
          ),
        );
      }
      return Left(
        FCMFailure(
          message: 'Network error: ${e.message}',
        ),
      );
    } catch (e) {
      return Left(
        FCMFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<NotificationFailure, List<NotificationSendResult>>>
      sendBatchNotifications(
    List<NotificationRequest> requests,
  ) async {
    final results = <NotificationSendResult>[];

    for (final request in requests) {
      final result = await sendNotification(request);
      result.fold(
        (failure) =>
            results.add(NotificationSendResult.failure(failure.message)),
        (success) => results.add(success),
      );
    }

    return Right(results);
  }

  /// Get OAuth2 access token for Firebase Admin SDK
  Future<bool> _getAccessToken() async {
    if (!_accessToken.isExpired) {
      return true;
    }

    try {
      final jwt = await _createJWT();

      // Exchange JWT for access token
      final response = await _dio.post(
        'https://oauth2.googleapis.com/token',
        data: {
          'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          'assertion': jwt,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200) {
        _accessToken.setToken(
          response.data['access_token'] as String,
          response.data['expires_in'] as int,
        );
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Create and sign JWT for OAuth2
  Future<String> _createJWT() async {
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Create JWT header
    final header = {
      'alg': 'RS256',
      'typ': 'JWT',
      'kid': serviceAccount['private_key_id'],
    };

    // Create JWT payload
    final payload = {
      'iss': serviceAccount['client_email'],
      'scope': 'https://www.googleapis.com/auth/firebase.messaging',
      'aud': 'https://oauth2.googleapis.com/token',
      'iat': currentTime,
      'exp': currentTime + 3600,
    };

    // Encode header and payload
    final encodedHeader = _base64UrlEncode(jsonEncode(header));
    final encodedPayload = _base64UrlEncode(jsonEncode(payload));

    // Sign JWT
    final signature = await _signData('$encodedHeader.$encodedPayload');

    return '$encodedHeader.$encodedPayload.$signature';
  }

  /// Sign data with RSA private key using pointycastle
  Future<String> _signData(String data) async {
    try {
      final privateKeyPem = serviceAccount['private_key'] as String;

      // Parse PEM private key using pointycastle
      final privateKey = _parsePrivateKey(privateKeyPem);

      // Create signer with RSA and SHA-256
      final signer = Signer('SHA-256/RSA')
        ..init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

      // Sign the data
      final dataBytes = Uint8List.fromList(utf8.encode(data));
      final signature = signer.generateSignature(dataBytes) as RSASignature;

      // Encode signature with base64url without padding
      return base64UrlEncode(signature.bytes).replaceAll('=', '');
    } catch (e) {
      throw Exception('Failed to sign JWT: $e');
    }
  }

  /// Parse PEM formatted private key
  RSAPrivateKey _parsePrivateKey(String pem) {
    // Remove PEM headers and footers
    final lines = pem
        .replaceAll('-----BEGIN PRIVATE KEY-----', '')
        .replaceAll('-----END PRIVATE KEY-----', '')
        .replaceAll('-----BEGIN RSA PRIVATE KEY-----', '')
        .replaceAll('-----END RSA PRIVATE KEY-----', '')
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .trim();

    final bytes = base64Decode(lines);

    // Use ASN1 parser to extract RSA key components
    final parser = ASN1Parser(bytes);
    final seq = parser.nextObject() as ASN1Sequence;

    // Handle PKCS#8 format
    RSAPrivateKey privateKey;
    if (seq.elements.length == 3 || seq.elements.length == 4) {
      // PKCS#8: version + algorithm + privateKey + optional attributes
      final privateKeyBytes = (seq.elements[2] as ASN1OctetString).octets;
      final privateKeyParser = ASN1Parser(privateKeyBytes);
      final privateKeySeq = privateKeyParser.nextObject() as ASN1Sequence;
      privateKey = _parseRSASequence(privateKeySeq);
    } else {
      // PKCS#1 format
      privateKey = _parseRSASequence(seq);
    }

    return privateKey;
  }

  /// Parse RSA key components from ASN1 sequence
  RSAPrivateKey _parseRSASequence(ASN1Sequence seq) {
    final elements = seq.elements;

    return RSAPrivateKey(
      (elements[1] as ASN1Integer).valueAsBigInteger, // modulus
      (elements[3] as ASN1Integer).valueAsBigInteger, // privateExponent
      (elements[4] as ASN1Integer).valueAsBigInteger, // p
      (elements[5] as ASN1Integer).valueAsBigInteger, // q
    );
  }

  /// Base64 URL encode (replace +/ with -_ and remove padding)
  String _base64UrlEncode(String input) {
    final bytes = utf8.encode(input);
    final base64 = base64Encode(bytes);
    return base64.replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
  }

  /// Build FCM v1 API request
  Map<String, dynamic> _buildV1Request(NotificationRequest request) {
    final message = <String, dynamic>{
      'notification': <String, dynamic>{
        'title': request.title,
        'body': request.body,
      },
      'android': <String, dynamic>{
        'priority': _getFcmPriority(request.priority),
        'notification': <String, dynamic>{
          'channel_id': request.channelId ?? 'high_importance_channel',
        },
      },
      'apns': <String, dynamic>{
        'payload': <String, dynamic>{
          'aps': <String, dynamic>{
            'priority': _getApnsPriority(request.priority),
          },
        },
      },
    };

    // Add image if provided
    if (request.imageUrl != null && request.imageUrl!.isNotEmpty) {
      message['notification']['image'] = request.imageUrl;
    }

    // Add custom data
    if (request.data != null && request.data!.isNotEmpty) {
      message['data'] = request.data;
    }

    // Set target based on type
    switch (request.targetType) {
      case NotificationTargetType.allUsers:
        message['topic'] = 'all_users';
        break;
      case NotificationTargetType.topic:
        message['topic'] = request.topic ?? 'promotions';
        break;
      case NotificationTargetType.singleDevice:
        message['token'] = request.deviceToken;
        break;
      case NotificationTargetType.multipleDevices:
        // For multiple devices, send to first token
        message['token'] = request.deviceTokens?.first ?? '';
        break;
    }

    return {
      'message': message,
    };
  }

  String _getFcmPriority(FCMNotificationPriority priority) {
    switch (priority) {
      case FCMNotificationPriority.high:
        return 'HIGH';
      case FCMNotificationPriority.normal:
        return 'NORMAL';
      case FCMNotificationPriority.low:
        return 'MIN';
    }
  }

  String _getApnsPriority(FCMNotificationPriority priority) {
    switch (priority) {
      case FCMNotificationPriority.high:
        return '10';
      case FCMNotificationPriority.normal:
        return '5';
      case FCMNotificationPriority.low:
        return '1';
    }
  }
}
