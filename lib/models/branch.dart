// lib/models/branch.dart

class Branch {
  final String id;
  final String name;
  final String? city; // أضف هذا إذا كان موجودًا في Laravel API

  Branch({required this.id, required this.name, this.city});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'].toString(), // تأكد من تحويل الـ ID إلى String
      name: json['name'] as String,
      city: json['city'] as String?,
    );
  }
}
