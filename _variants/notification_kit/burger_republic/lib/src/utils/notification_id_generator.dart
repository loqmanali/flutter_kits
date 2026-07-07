import 'dart:math';

class NotificationIdGenerator {
  static String generate() {
    return DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString();
  }
  
  static int generateIntId() {
    return Random().nextInt(100000);
  }
}
