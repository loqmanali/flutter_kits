import '../entities/ai_message.dart';

/// One-shot and streaming AI calls plus a chat-session handle.
abstract class FirebaseAiRepository {
  /// Single-prompt generation. Returns the model's full reply.
  Future<String> generateText(
    String prompt, {
    String? systemInstruction,
    double? temperature,
    int? maxOutputTokens,
  });

  /// Streamed generation — emits incremental text chunks.
  Stream<String> streamText(
    String prompt, {
    String? systemInstruction,
    double? temperature,
    int? maxOutputTokens,
  });

  /// Multi-turn generation from a message history. Returns the model's reply
  /// (the history itself is not mutated).
  Future<String> generateFromHistory(List<AiMessage> history);

  /// Streamed multi-turn generation.
  Stream<String> streamFromHistory(List<AiMessage> history);

  /// Approximate token count for a prompt — useful for budget checks.
  Future<int> countTokens(String prompt);

  /// Opens a chat session. Use [AiChatHandle.send] / [AiChatHandle.stream] to
  /// keep history in-sync without manually re-sending it each turn.
  AiChatHandle startChat({List<AiMessage> history = const []});
}

/// Wraps a `firebase_ai` ChatSession with the kit's plain Dart message type.
abstract class AiChatHandle {
  Future<String> send(String text);
  Stream<String> stream(String text);
  List<AiMessage> get history;
}
