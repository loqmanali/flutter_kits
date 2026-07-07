/// Kit-wide configuration.
class FirebaseKitConfig {
  /// AI module config. Null disables the AI module.
  final FirebaseAiConfig? ai;

  /// When true, the kit auto-creates a Firestore user document on first sign-in
  /// for users that exist in Auth but not yet in Firestore.
  final bool autoCreateUserDocument;

  const FirebaseKitConfig({
    this.ai,
    this.autoCreateUserDocument = true,
  });
}

/// Firebase AI Logic (Gemini in Firebase / Vertex AI in Firebase) configuration.
class FirebaseAiConfig {
  /// Model id — e.g. `gemini-1.5-flash`, `gemini-1.5-pro`, `gemini-2.0-flash`.
  final String model;

  /// `true` uses Vertex AI backend; `false` uses Google AI backend.
  /// Vertex offers more controls and is the recommended production choice.
  final bool useVertexAi;

  /// Optional system instruction applied to every conversation.
  final String? systemInstruction;

  /// Sampling temperature (0.0 – 1.0). Null uses the model default.
  final double? temperature;

  /// Maximum output tokens. Null uses the model default.
  final int? maxOutputTokens;

  const FirebaseAiConfig({
    this.model = 'gemini-1.5-flash',
    this.useVertexAi = true,
    this.systemInstruction,
    this.temperature,
    this.maxOutputTokens,
  });
}
