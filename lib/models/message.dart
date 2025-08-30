import 'package:youseuf_app/models/attachment.dart';

class Message {
  final int id;
  final int conversationId;
  final dynamic senderId;
  final String senderType;
  final String? senderName;
  final String? content;
  final DateTime? createdAt; // ✅ غيّر من String إلى DateTime
  final String? updatedAt;
  final List<Attachment>? attachments;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    this.senderName,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.attachments,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['senderId'],
      senderType: json['senderType'],
      senderName: json['senderName'],
      content: json['content'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null, // ✅ التحويل الآمن
      updatedAt: json['updated_at'],
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((i) => Attachment.fromJson(i as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
