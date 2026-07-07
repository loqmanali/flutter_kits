import 'package:timezone/timezone.dart' as tz;

/// Next occurrence of (hour, minute) in the local timezone. If today's time
/// has already passed, rolls to tomorrow. Mirrors the daily-reminder logic the
/// host app previously kept in its own NotificationService.
tz.TZDateTime nextInstanceOfTime(int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (!scheduled.isAfter(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}
