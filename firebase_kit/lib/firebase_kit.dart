/// firebase_kit
///
/// Self-contained, project-agnostic Firebase module for Flutter.
///
/// - Auth: email/password, phone, anonymous, custom token, every OAuth
///   provider (via pluggable adapters)
/// - Firestore: generic typed CRUD repository + fluent query builder
/// - Firebase AI Logic (Vertex AI / Google AI / Gemini): one-shot and
///   streaming generation, chat sessions, token counting
/// - Riverpod providers and a ready-to-use auth notifier
/// - Pluggable logger and storage paths so the kit fits any host app
///
/// Quick start:
/// ```dart
/// import 'package:firebase_kit/firebase_kit.dart';
///
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///
///   FirebaseKitRuntime.use(
///     logger: AppLoggerFirebaseAdapter(),
///     oauthAdapters: [GoogleOAuthAdapter()],
///     config: const FirebaseKitConfig(
///       ai: FirebaseAiConfig(model: 'gemini-1.5-flash'),
///     ),
///   );
///
///   runApp(const ProviderScope(child: MyApp()));
/// }
/// ```
library;

// Runtime + adapters
export 'src/firebase_kit_runtime.dart';
export 'src/adapters/firebase_logger.dart';
export 'src/adapters/firestore_collection_config.dart';
export 'src/adapters/oauth_provider_adapter.dart';

// Config
export 'src/config/firebase_kit_config.dart';

// Auth - Domain
export 'src/auth/domain/entities/firebase_user_entity.dart';
export 'src/auth/domain/entities/phone_verification.dart';
export 'src/auth/domain/failures/auth_failure.dart';
export 'src/auth/domain/repositories/auth_repository.dart';

// Auth - Data
export 'src/auth/data/datasources/auth_data_source.dart';
export 'src/auth/data/datasources/user_firestore_data_source.dart';
export 'src/auth/data/models/firebase_user_model.dart';
export 'src/auth/data/repositories/auth_repository_impl.dart';

// Auth - Presentation
export 'src/auth/presentation/providers/auth_notifier.dart';
export 'src/auth/presentation/providers/auth_providers.dart';

// Firestore
export 'src/firestore/domain/firestore_repository.dart';
export 'src/firestore/domain/firestore_serializable.dart';
export 'src/firestore/data/firestore_repository_impl.dart';
export 'src/firestore/query/firestore_query.dart';

// AI - Domain
export 'src/ai/domain/entities/ai_message.dart';
export 'src/ai/domain/repositories/firebase_ai_repository.dart';

// AI - Data
export 'src/ai/data/firebase_ai_data_source.dart';
export 'src/ai/data/firebase_ai_repository_impl.dart';

// AI - Presentation
export 'src/ai/presentation/providers/ai_providers.dart';
