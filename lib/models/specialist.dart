// lib/models/specialist.dart
class Specialist {
  final String id; // يُفضل أن يكون int إذا كان الـ ID رقمًا
  final String name;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl; // قابل للقيم الخالية
  final String? type; // ثابت لكل الأخصائيين

  Specialist({
    required this.id,
    required this.name,
    this.phoneNumber,
    required this.email,
    this.avatarUrl,
    this.type,
  });


  factory Specialist.fromJson(Map<String, dynamic> json) {

    return Specialist(
      
      id: json['id']?.toString() ?? '0', // تأكد من تحويل الـ ID وتوفير قيمة افتراضية

      name: json['name'] as String? ?? 'أخصائي غير معروف', // توفير قيمة افتراضية
      email: json['email'] as String? ?? 'unknown@specialist.com', // توفير قيمة افتراضية
       phoneNumber: json['phone_number'] as String?, 
      avatarUrl: json['avatar_url'] as String?, // يمكن أن يكون null
      type: json['type'] as String? ?? 'specialist', // توفير قيمة افتراضية
    );
  }

Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'type': type,
    };
  }
}