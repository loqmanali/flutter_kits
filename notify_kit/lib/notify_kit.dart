/// FCM + local notifications behind one init() call, with unified tap
/// routing across foreground / background / terminated states.
library;

export 'package:firebase_messaging/firebase_messaging.dart'
    show BackgroundMessageHandler, RemoteMessage;

export 'src/background_handler.dart';
export 'src/config.dart';
export 'src/models.dart';
export 'src/notify_kit.dart';
