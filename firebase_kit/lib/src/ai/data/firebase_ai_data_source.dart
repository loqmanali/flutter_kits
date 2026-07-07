import 'package:firebase_ai/firebase_ai.dart';

import '../../config/firebase_kit_config.dart';
import '../../firebase_kit_runtime.dart';

/// Thin wrapper over the `firebase_ai` SDK. Picks the Vertex AI or Google AI
/// backend based on [FirebaseAiConfig.useVertexAi] and applies the kit's
/// model / system-instruction / generation config defaults.
class FirebaseAiDataSource {
  GenerativeModel? _cached;

  FirebaseAiConfig get _config {
    final cfg = FirebaseKitRuntime.config.ai;
    if (cfg == null) {
      throw StateError(
        'Firebase AI is not enabled. Pass an `ai: FirebaseAiConfig(...)` '
        'into FirebaseKitConfig and register it via FirebaseKitRuntime.use.',
      );
    }
    return cfg;
  }

  GenerativeModel model({
    String? systemInstruction,
    double? temperature,
    int? maxOutputTokens,
  }) {
    final cfg = _config;
    // Per-call overrides bypass the cache.
    if (systemInstruction != null ||
        temperature != null ||
        maxOutputTokens != null) {
      return _build(cfg,
          systemInstructionOverride: systemInstruction,
          temperatureOverride: temperature,
          maxOutputTokensOverride: maxOutputTokens);
    }
    return _cached ??= _build(cfg);
  }

  GenerativeModel _build(
    FirebaseAiConfig cfg, {
    String? systemInstructionOverride,
    double? temperatureOverride,
    int? maxOutputTokensOverride,
  }) {
    final backend = cfg.useVertexAi ? FirebaseAI.vertexAI() : FirebaseAI.googleAI();
    final sysText = systemInstructionOverride ?? cfg.systemInstruction;
    final temp = temperatureOverride ?? cfg.temperature;
    final maxTok = maxOutputTokensOverride ?? cfg.maxOutputTokens;

    return backend.generativeModel(
      model: cfg.model,
      systemInstruction: sysText != null ? Content.system(sysText) : null,
      generationConfig: (temp != null || maxTok != null)
          ? GenerationConfig(
              temperature: temp,
              maxOutputTokens: maxTok,
            )
          : null,
    );
  }
}
