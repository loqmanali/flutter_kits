import 'package:app_badge_plus/app_badge_plus.dart';

class NotificationBadgeService {
  Future<void> updateBadgeCount(int count) async {
    final bool isSupported = await AppBadgePlus.isSupported();
    if (isSupported) {
      AppBadgePlus.updateBadge(count > 0 ? count : 0);
    }
  }

  Future<void> removeBadge() async {
    final bool isSupported = await AppBadgePlus.isSupported();
    if (isSupported) {
      AppBadgePlus.updateBadge(0);
    }
  }
}
