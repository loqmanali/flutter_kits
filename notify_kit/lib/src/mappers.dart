import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'models.dart';

NotifyMessage messageFromRemote(RemoteMessage message) => NotifyMessage(
      title: message.notification?.title,
      body: message.notification?.body,
      data: Map<String, dynamic>.from(message.data),
      messageId: message.messageId,
    );

/// Decode failures deliver an empty message rather than crashing (spec §8).
/// Failures are logged, never silent (docs/core/error-handling.md: no empty
/// catch blocks).
NotifyMessage messageFromLocalPayload(String? payload) {
  if (payload == null || payload.isEmpty) return const NotifyMessage();
  try {
    if (jsonDecode(payload) case final Map<String, dynamic> data) {
      return NotifyMessage(data: data);
    }
  } catch (error) {
    debugPrint('notify_kit: failed to decode local payload: $error');
  }
  return const NotifyMessage();
}
