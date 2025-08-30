// lib/models/user.dart
class User {
  final int id;
  final String name; // يجب أن تكون هذه الخاصية String لأنها مطلوبة
  final String email; // يجب أن تكون هذه الخاصية String لأنها مطلوبة
  final String? avatarUrl; // رابط صورة الملف الشخصي (قابل للقيم الخالية)

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int, // تأكد من تحويلها إلى int
      name: json['name'] as String? ?? 'مستخدم', // **هنا التعديل:** إذا كان name هو null، فاستخدم 'مستخدم' كقيمة افتراضية
      email: json['email'] as String? ?? 'غير معروف@example.com', // **هنا التعديل:** إذا كان email هو null، فاستخدم قيمة افتراضية
      avatarUrl: json['avatar_url'] as String?, // تأكد من أنها String?
    );
  }
}