// lib/models/child.dart

class Child {
  final String id; 
  final String name;
  final String gender;
  final int age;
  final String? branchName; 
  final String? departmentName; 
  final String? healthIssues; 
  final String? emergencyContact; 
  final String? notes; 
  // إذا كانت هذه الحقول موجودة في الـ API، تأكد من إضافتها هنا
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? branchId;
  final String? laravelThroughKey; // إذا كان هذا الحقل لا يزال يأتي من الـ API

  Child({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    this.branchName,
    this.departmentName,
    this.healthIssues,
    this.emergencyContact,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.branchId,
    this.laravelThroughKey,
  });

  // Factory constructor لتحويل JSON إلى كائن Child
  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      // استخدام المفاتيح التي تظهر في سجل الـ API
      id: json['child_id']?.toString() ?? '', 
      name: json['child_name'] as String? ?? 'غير معروف', 
      age: json['child_age'] as int? ?? 0, 
      gender: json['child_gender'] as String? ?? 'غير معروف', 
      branchName: json['branch_name'] as String?,
      departmentName: json['department_name'] as String?,
      healthIssues: json['health_issues'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      notes: json['notes'] as String?,
      // إضافة الحقول الزمنية ومعرفات الفروع إذا كانت تأتي في الـ API
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      branchId: json['branch_id']?.toString(),
      laravelThroughKey: json['laravel_through_key']?.toString(),
    );
  }
}
