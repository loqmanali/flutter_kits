import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firebase_ai_data_source.dart';
import '../../data/firebase_ai_repository_impl.dart';
import '../../domain/repositories/firebase_ai_repository.dart';

final firebaseAiDataSourceProvider = Provider<FirebaseAiDataSource>((ref) {
  return FirebaseAiDataSource();
});

final firebaseAiRepositoryProvider = Provider<FirebaseAiRepository>((ref) {
  return FirebaseAiRepositoryImpl(
    dataSource: ref.watch(firebaseAiDataSourceProvider),
  );
});

/// Streamed one-shot text generation, useful for chat-bubble style UIs:
///
/// ```dart
/// final stream = ref.watch(aiTextStreamProvider('Tell me a joke'));
/// stream.when(
///   data: (chunk) => ...,
///   loading: () => ...,
///   error: (e, _) => ...,
/// );
/// ```
final aiTextStreamProvider =
    StreamProvider.autoDispose.family<String, String>((ref, prompt) {
  return ref.watch(firebaseAiRepositoryProvider).streamText(prompt);
});

/// One-shot text generation as a future.
final aiTextProvider =
    FutureProvider.autoDispose.family<String, String>((ref, prompt) {
  return ref.watch(firebaseAiRepositoryProvider).generateText(prompt);
});
