// lib/models/attachment.dart

class Attachment {
  final int id;
  final int messageId; // تأكد أن هذا موجود لو كان مطلوبًا
  final String? filePath;
  final String? fileType;
  final String? fileName; // 💡 يجب أن يكون هذا موجودًا
  final String? createdAt; // إذا كنت ترسلها من Laravel
  final String? updatedAt; // إذا كنت ترسلها من Laravel

  Attachment({
    required this.id,
    required this.messageId,
    this.filePath,
    this.fileType,
    this.fileName, // 💡 أضف هذا إذا لم يكن موجودًا
    this.createdAt,
    this.updatedAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      messageId: json['message_id'], // تأكد من اسم المفتاح في JSON
      filePath: json['file_path'],
      fileType: json['file_type'],
      fileName: json['file_name'], // 💡 تأكد من قراءة 'file_name' من الـ JSON
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}