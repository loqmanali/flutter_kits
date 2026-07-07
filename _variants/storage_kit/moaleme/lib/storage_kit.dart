/// storage_kit
///
/// A pluggable, project-agnostic key-value storage facade for Flutter.
///
/// - One uniform API ([AppStorage]) over multiple backends.
/// - Built-in adapters: [SharedPrefsAdapter] and [HiveAdapter] (with optional
///   AES-256 encryption).
/// - Plug your own [StorageAdapter] for tests or alternative backends.
/// - No domain assumptions: define your own keys.
///
/// Quick start:
/// ```dart
/// import 'package:storage_kit/storage_kit.dart';
///
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await AppStorage.initialize();        // SharedPreferences (default)
///   // or:
///   // await AppStorage.initialize(type: StorageType.hive);
///
///   await AppStorage.instance.setString('locale', 'ar');
///   final locale = await AppStorage.instance.getString('locale');
///   runApp(MyApp());
/// }
/// ```
library;

export 'src/adapters/hive_adapter.dart';
export 'src/adapters/shared_prefs_adapter.dart';
export 'src/adapters/storage_adapter.dart';
export 'src/app_storage.dart';
export 'src/storage_inspector.dart';
export 'src/storage_type.dart';
