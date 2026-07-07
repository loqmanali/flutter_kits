import 'dart:io';

import 'package:api_kit/api_kit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for DioApiClient's error classification.
///
/// _handleError is private and just delegates to the top-level
/// `@visibleForTesting ApiException mapDioError(DioException)`. We test that
/// hook directly — it is the least-invasive seam: constructing a real
/// DioException through the public HTTP path would require a live/mocked socket
/// for every transport variant (timeout, cancel, badCertificate, …), which is
/// far more brittle than feeding a hand-built DioException to the pure mapper.
void main() {
  final req = RequestOptions(path: '/x');

  DioException dio(
    DioExceptionType type, {
    int? statusCode,
    dynamic data,
    Object? underlyingError,
  }) {
    return DioException(
      requestOptions: req,
      type: type,
      error: underlyingError,
      response: statusCode == null && data == null
          ? null
          : Response<dynamic>(
              requestOptions: req,
              statusCode: statusCode,
              data: data,
            ),
    );
  }

  group('transport types (no HTTP code carried)', () {
    test('connectionTimeout → TimeoutException', () {
      final e = mapDioError(dio(DioExceptionType.connectionTimeout));
      expect(e, isA<TimeoutException>());
      expect(e.statusCode, isNull);
    });

    test('sendTimeout → TimeoutException', () {
      expect(mapDioError(dio(DioExceptionType.sendTimeout)),
          isA<TimeoutException>());
    });

    test('receiveTimeout → TimeoutException', () {
      expect(mapDioError(dio(DioExceptionType.receiveTimeout)),
          isA<TimeoutException>());
    });

    test('cancel → CancellationException', () {
      final e = mapDioError(dio(DioExceptionType.cancel));
      expect(e, isA<CancellationException>());
      expect(e.statusCode, isNull);
    });

    test('connectionError → NoInternetConnectionException', () {
      final e = mapDioError(dio(DioExceptionType.connectionError));
      expect(e, isA<NoInternetConnectionException>());
      expect(e.statusCode, isNull);
    });

    test('badCertificate → BadCertificateException', () {
      final e = mapDioError(dio(DioExceptionType.badCertificate));
      expect(e, isA<BadCertificateException>());
      expect(e.statusCode, isNull);
    });

    test('transport type ignores any partial response.statusCode', () {
      // receiveTimeout that somehow carries a 200 partial response stays a
      // transport TimeoutException with NO status code.
      final e = mapDioError(
        dio(DioExceptionType.receiveTimeout, statusCode: 200),
      );
      expect(e, isA<TimeoutException>());
      expect(e.statusCode, isNull);
    });
  });

  group('SocketException guard', () {
    test('unknown + SocketException underlying → NoInternetConnection', () {
      final e = mapDioError(
        dio(DioExceptionType.unknown,
            underlyingError: const SocketException('down')),
      );
      expect(e, isA<NoInternetConnectionException>());
    });

    test('badResponse + SocketException underlying → NoInternetConnection', () {
      final e = mapDioError(
        dio(DioExceptionType.badResponse,
            underlyingError: const SocketException('down')),
      );
      expect(e, isA<NoInternetConnectionException>());
    });
  });

  group('badResponse codes WITH a dedicated subclass', () {
    final cases = <int, Type>{
      400: BadRequestException,
      401: UnauthorizedException,
      403: ForbiddenException,
      404: NotFoundException,
      405: MethodNotAllowedException,
      406: NotAcceptableException,
      409: ConflictException,
      500: InternalServerErrorException,
      501: NotImplementedException,
      503: ServiceUnavailableException,
    };

    cases.forEach((code, type) {
      test('$code → $type (carries $code)', () {
        final e = mapDioError(
          dio(DioExceptionType.badResponse, statusCode: code),
        );
        expect(e.runtimeType, type);
        expect(e.statusCode, code);
      });
    });

    test('unknown WITH a code is classified like badResponse', () {
      final e = mapDioError(dio(DioExceptionType.unknown, statusCode: 404));
      expect(e, isA<NotFoundException>());
      expect(e.statusCode, 404);
    });
  });

  group('422 → ValidationException (carries 422 + field errors)', () {
    test('plain 422 carries statusCode 422', () {
      final e = mapDioError(dio(DioExceptionType.badResponse, statusCode: 422));
      expect(e, isA<ValidationException>());
      expect(e.statusCode, 422);
    });

    test('parses response.data["errors"] into fieldErrors', () {
      final e = mapDioError(
        dio(
          DioExceptionType.badResponse,
          statusCode: 422,
          data: {
            'message': 'Validation failed',
            'errors': {
              'email': ['The email field is required.'],
              'name': 'Too short',
            },
          },
        ),
      ) as ValidationException;
      expect(e.statusCode, 422);
      expect(e.message, 'Validation failed');
      expect(e.fieldErrors, {
        'email': 'The email field is required.',
        'name': 'Too short',
      });
    });
  });

  group('codes WITHOUT a dedicated subclass keep the REAL code', () {
    test('other 4xx (429) → base ApiException carrying 429 (not 400)', () {
      final e = mapDioError(dio(DioExceptionType.badResponse, statusCode: 429));
      expect(e.runtimeType, ApiException);
      expect(e.statusCode, 429);
    });

    test('other 4xx (410) → base ApiException carrying 410', () {
      final e = mapDioError(dio(DioExceptionType.badResponse, statusCode: 410));
      expect(e.runtimeType, ApiException);
      expect(e.statusCode, 410);
    });

    test('other 5xx (502) → ServerException carrying 502', () {
      final e = mapDioError(dio(DioExceptionType.badResponse, statusCode: 502));
      expect(e, isA<ServerException>());
      expect(e.statusCode, 502);
    });

    test('other 5xx (504) → ServerException carrying 504', () {
      final e = mapDioError(dio(DioExceptionType.badResponse, statusCode: 504));
      expect(e, isA<ServerException>());
      expect(e.statusCode, 504);
    });

    test('out-of-band code (3xx that surfaced as error) → base, carried', () {
      final e = mapDioError(dio(DioExceptionType.badResponse, statusCode: 301));
      expect(e.runtimeType, ApiException);
      expect(e.statusCode, 301);
    });
  });

  group('anomalous / unclassifiable', () {
    test('badResponse with NO code → UnexpectedException (no code)', () {
      // A response present but with a null statusCode.
      final e = mapDioError(
        DioException(
          requestOptions: req,
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(requestOptions: req, statusCode: null),
        ),
      );
      expect(e, isA<UnexpectedException>());
      expect(e.statusCode, isNull);
    });

    test('unknown with no code and no SocketException → UnexpectedException',
        () {
      final e = mapDioError(dio(DioExceptionType.unknown));
      expect(e, isA<UnexpectedException>());
      expect(e.statusCode, isNull);
    });
  });

  group('message precedence', () {
    test('server message from response.data["message"] is preserved', () {
      final e = mapDioError(
        dio(
          DioExceptionType.badResponse,
          statusCode: 401,
          data: {'message': 'Token expired'},
        ),
      );
      expect(e, isA<UnauthorizedException>());
      expect(e.message, 'Token expired');
    });

    test('empty/whitespace server message falls back to subclass default', () {
      final e = mapDioError(
        dio(
          DioExceptionType.badResponse,
          statusCode: 404,
          data: {'message': '   '},
        ),
      );
      expect(e, isA<NotFoundException>());
      expect(e.message, 'Resource not found'); // the subclass default
    });

    test('non-String message value is ignored (no cast crash)', () {
      final e = mapDioError(
        dio(
          DioExceptionType.badResponse,
          statusCode: 409,
          data: {'message': 12345},
        ),
      );
      expect(e, isA<ConflictException>());
      expect(e.message, 'Conflict occurred'); // default used
    });
  });
}
