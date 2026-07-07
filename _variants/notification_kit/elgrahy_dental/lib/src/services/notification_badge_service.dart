import 'package:flutter_app_badger/flutter_app_badger.dart';

class NotificationBadgeService {
  Future<void> updateBadgeCount(int count) async {
    final bool isSupported = await FlutterAppBadger.isAppBadgeSupported();
    if (isSupported) {
      if (count > 0) {
        FlutterAppBadger.updateBadgeCount(count);
      } else {
        FlutterAppBadger.removeBadge();
      }
    }
  }

  Future<void> removeBadge() async {
    final bool isSupported = await FlutterAppBadger.isAppBadgeSupported();
    if (isSupported) {
      FlutterAppBadger.removeBadge();
    }
  }
}
