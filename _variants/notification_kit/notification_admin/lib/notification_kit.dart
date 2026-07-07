/// notification_kit
///
/// Self-contained, plug-and-play notification module for Flutter.
///
/// - Firebase Cloud Messaging (foreground / background / terminated)
/// - Local & scheduled notifications
/// - FCM HTTP v1 admin sender (service-account JWT)
/// - Riverpod state, settings UI, history page, admin page
/// - Deep-link routing on notification tap
/// - In-app toast banners
/// - Pluggable storage adapter (defaults to SharedPreferences)
/// - Pluggable logger adapter (defaults to debugPrint)
///
/// Quick start:
/// ```dart
/// import 'package:notification_kit/notification_kit.dart';
///
/// final rootNavKey = GlobalKey<NavigatorState>();
///
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///
///   NotificationKitRuntime.use(
///     navigator: NotificationNavigator(
///       rootNavigatorKey: rootNavKey,
///       fallbackRoute: '/home',
///     ),
///   );
///
///   await NotificationInitializer.initialize();
///
///   runApp(ProviderScope(child: MyApp(navigatorKey: rootNavKey)));
/// }
/// ```
library;

// Host-app integration surface
export 'src/adapters/notification_kit_runtime.dart';
export 'src/adapters/notification_logger.dart';
export 'src/adapters/notification_navigator.dart';
export 'src/adapters/notification_storage_adapter.dart';

// Config
export 'src/config/notification_categories.dart';
export 'src/config/notification_channels.dart';
export 'src/config/notification_config.dart';

// Constants
export 'src/constants/notification_defaults.dart';
export 'src/constants/notification_keys.dart';
export 'src/constants/notification_topics.dart';

// Data - DataSources
export 'src/data/datasources/fcm_data_source.dart';
export 'src/data/datasources/local_notification_data_source.dart';
export 'src/data/datasources/notification_storage_data_source.dart';
export 'src/data/datasources/platform_notification_data_source.dart';

// Data - Models
export 'src/data/models/fcm_message_model.dart';
export 'src/data/models/notification_action_model.dart';
export 'src/data/models/notification_model.dart';
export 'src/data/models/notification_payload_model.dart';
export 'src/data/models/notification_settings_model.dart';
export 'src/data/models/scheduled_notification_model.dart';

// Data - Repositories
export 'src/data/repositories/notification_repository_impl.dart';
export 'src/data/repositories/notification_settings_repository_impl.dart';
export 'src/data/repositories/notification_storage_repository_impl.dart';

// Domain - Entities
export 'src/domain/entities/notification_action.dart';
export 'src/domain/entities/notification_channel.dart';
export 'src/domain/entities/notification_entity.dart';
export 'src/domain/entities/notification_payload.dart';
export 'src/domain/entities/notification_priority.dart';
export 'src/domain/entities/notification_request.dart';
export 'src/domain/entities/notification_schedule.dart';
export 'src/domain/entities/notification_settings.dart';
export 'src/domain/entities/notification_target_type.dart';

// Domain - Failures
export 'src/domain/failures/notification_failures.dart';

// Domain - Repositories
export 'src/domain/repositories/notification_repository.dart';
export 'src/domain/repositories/notification_settings_repository.dart';
export 'src/domain/repositories/notification_storage_repository.dart';

// Domain - Use Cases
export 'src/domain/usecases/cancel_notification_usecase.dart';
export 'src/domain/usecases/get_notification_history_usecase.dart';
export 'src/domain/usecases/handle_permission_usecase.dart';
export 'src/domain/usecases/process_deep_link_usecase.dart';
export 'src/domain/usecases/schedule_notification_usecase.dart';
export 'src/domain/usecases/show_notification_usecase.dart';
export 'src/domain/usecases/subscribe_topic_usecase.dart';
export 'src/domain/usecases/update_settings_usecase.dart';

// Handlers
export 'src/handlers/background_handler.dart';
export 'src/handlers/foreground_handler.dart';
export 'src/handlers/notification_handler.dart';
export 'src/handlers/notification_tap_handler.dart';

// Initializer
export 'src/notification_initializer.dart';

// Presentation - Pages
export 'src/presentation/pages/notification_admin_page.dart';
export 'src/presentation/pages/notification_history_page.dart';
export 'src/presentation/pages/notification_settings_page.dart';

// Presentation - Providers
export 'src/presentation/providers/notification_admin_provider.dart';
export 'src/presentation/providers/notification_notifier.dart';
export 'src/presentation/providers/notification_providers.dart';
export 'src/presentation/providers/notification_settings_notifier.dart';
export 'src/presentation/providers/notification_settings_state.dart';
export 'src/presentation/providers/notification_state.dart';

// Presentation - Widgets
export 'src/presentation/widgets/in_app_notification_banner.dart';
export 'src/presentation/widgets/notification_list_tile.dart';
export 'src/presentation/widgets/notification_permission_dialog.dart';
export 'src/presentation/widgets/notification_settings_tile.dart';

// Services
export 'src/services/deep_link_notification_service.dart';
export 'src/services/fcm_admin_service.dart';
export 'src/services/fcm_service.dart';
export 'src/services/notification_badge_service.dart';
export 'src/services/notification_channel_service.dart';
export 'src/services/notification_scheduler_service.dart';
export 'src/services/notification_service.dart';
export 'src/services/toast_notification_service.dart';

// Utils
export 'src/utils/notification_id_generator.dart';
export 'src/utils/notification_payload_parser.dart';
