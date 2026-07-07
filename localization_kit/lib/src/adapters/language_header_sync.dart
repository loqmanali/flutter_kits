/// Callback invoked whenever the active language changes.
///
/// Use this to keep HTTP client headers (`Accept-Language`,
/// `X-Language-Code`, …) in sync with the user's choice.
///
/// Example:
/// ```dart
/// LocalizationKitRuntime.use(
///   onLanguageChanged: (apiCode) async {
///     await MyApiClient.instance.setHeader('Accept-Language', apiCode);
///   },
/// );
/// ```
typedef LanguageHeaderSync = Future<void> Function(String apiCode);
