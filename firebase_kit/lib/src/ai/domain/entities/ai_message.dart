import 'package:equatable/equatable.dart';

/// Role of a message in an AI conversation.
enum AiRole { user, model, system }

/// A single message in an AI conversation. Plain Dart so the domain layer
/// stays decoupled from `firebase_ai`.
class AiMessage extends Equatable {
  final AiRole role;
  final String text;
  final DateTime createdAt;

  AiMessage({
    required this.role,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AiMessage.user(String text) =>
      AiMessage(role: AiRole.user, text: text);
  factory AiMessage.model(String text) =>
      AiMessage(role: AiRole.model, text: text);
  factory AiMessage.system(String text) =>
      AiMessage(role: AiRole.system, text: text);

  AiMessage copyWith({AiRole? role, String? text, DateTime? createdAt}) {
    return AiMessage(
      role: role ?? this.role,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [role, text, createdAt];
}
