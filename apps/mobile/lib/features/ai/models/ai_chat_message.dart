import '../../../core/utils/guid_generator.dart';

enum AiChatRole { user, assistant }

class AiChatMessage {
  AiChatMessage({
    required this.role,
    required this.content,
    required this.createdAt,
    this.isFailed = false,
  }) : id = GuidGenerator.newGuid();

  final String id;
  final AiChatRole role;
  final String content;
  final DateTime createdAt;

  /// Mesaj gönderildi ancak yanıt alınamadıysa true olur.
  final bool isFailed;

  String get timeLabel {
    final h = createdAt.hour.toString().padLeft(2, '0');
    final m = createdAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
