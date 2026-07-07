import 'package:firebase_ai/firebase_ai.dart' as fa;

import '../../firebase_kit_runtime.dart';
import '../domain/entities/ai_message.dart';
import '../domain/repositories/firebase_ai_repository.dart';
import 'firebase_ai_data_source.dart';

class FirebaseAiRepositoryImpl implements FirebaseAiRepository {
  final FirebaseAiDataSource _ds;

  FirebaseAiRepositoryImpl({FirebaseAiDataSource? dataSource})
      : _ds = dataSource ?? FirebaseAiDataSource();

  void _log(String message) => FirebaseKitRuntime.logger.debug(message);

  @override
  Future<String> generateText(
    String prompt, {
    String? systemInstruction,
    double? temperature,
    int? maxOutputTokens,
  }) async {
    _log('AI generateText (len=${prompt.length})');
    final model = _ds.model(
      systemInstruction: systemInstruction,
      temperature: temperature,
      maxOutputTokens: maxOutputTokens,
    );
    final response = await model.generateContent([fa.Content.text(prompt)]);
    return response.text ?? '';
  }

  @override
  Stream<String> streamText(
    String prompt, {
    String? systemInstruction,
    double? temperature,
    int? maxOutputTokens,
  }) {
    _log('AI streamText (len=${prompt.length})');
    final model = _ds.model(
      systemInstruction: systemInstruction,
      temperature: temperature,
      maxOutputTokens: maxOutputTokens,
    );
    return model
        .generateContentStream([fa.Content.text(prompt)])
        .map((r) => r.text ?? '')
        .where((chunk) => chunk.isNotEmpty);
  }

  @override
  Future<String> generateFromHistory(List<AiMessage> history) async {
    final model = _ds.model();
    final response = await model.generateContent(_toContents(history));
    return response.text ?? '';
  }

  @override
  Stream<String> streamFromHistory(List<AiMessage> history) {
    final model = _ds.model();
    return model
        .generateContentStream(_toContents(history))
        .map((r) => r.text ?? '')
        .where((chunk) => chunk.isNotEmpty);
  }

  @override
  Future<int> countTokens(String prompt) async {
    final model = _ds.model();
    final response = await model.countTokens([fa.Content.text(prompt)]);
    return response.totalTokens;
  }

  @override
  AiChatHandle startChat({List<AiMessage> history = const []}) {
    final model = _ds.model();
    final session = model.startChat(history: _toContents(history));
    return _ChatHandleImpl(session: session, history: [...history]);
  }

  // ----- helpers ------------------------------------------------------------

  List<fa.Content> _toContents(List<AiMessage> messages) {
    return messages.map(_toContent).toList();
  }

  fa.Content _toContent(AiMessage m) {
    switch (m.role) {
      case AiRole.user:
        return fa.Content.text(m.text);
      case AiRole.model:
        return fa.Content('model', [fa.TextPart(m.text)]);
      case AiRole.system:
        return fa.Content.system(m.text);
    }
  }
}

class _ChatHandleImpl implements AiChatHandle {
  final fa.ChatSession session;
  final List<AiMessage> _history;

  _ChatHandleImpl({required this.session, required List<AiMessage> history})
      : _history = history;

  @override
  List<AiMessage> get history => List.unmodifiable(_history);

  @override
  Future<String> send(String text) async {
    _history.add(AiMessage.user(text));
    final response = await session.sendMessage(fa.Content.text(text));
    final reply = response.text ?? '';
    _history.add(AiMessage.model(reply));
    return reply;
  }

  @override
  Stream<String> stream(String text) async* {
    _history.add(AiMessage.user(text));
    final buffer = StringBuffer();
    await for (final chunk in session.sendMessageStream(fa.Content.text(text))) {
      final part = chunk.text;
      if (part != null && part.isNotEmpty) {
        buffer.write(part);
        yield part;
      }
    }
    _history.add(AiMessage.model(buffer.toString()));
  }
}
