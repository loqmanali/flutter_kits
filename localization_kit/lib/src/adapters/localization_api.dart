import '../models/language_model.dart';

/// Optional contract for fetching the list of supported languages from a
/// backend (Odoo, custom REST API, …).
///
/// The kit can run in two modes:
/// 1. **Local mode (default)** — the host app provides a fixed list of
///    [LanguageModel]s via [LocalizationKitRuntime.defaultLanguages].
/// 2. **Remote mode** — the host app supplies a [LocalizationApi]; the kit
///    fetches the list on initialization and stores it in state.
///
/// Implement this in your app if you want to expose languages dynamically.
abstract class LocalizationApi {
  Future<List<LanguageModel>> getLanguages();
}
