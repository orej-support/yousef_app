// lib/models/department.dart

import 'package:youseuf_app/models/specialist.dart';

class Department {
  final String id;
  final String name;
  final String branchId;
  final String departmentNumber;
  final String? createdAt;
  final String? updatedAt;
  final String? description;
  final List<Specialist> specialists;

  Department({
    required this.id,
    required this.name,
    required this.branchId,
    required this.departmentNumber,
    this.createdAt,
    this.updatedAt,
    this.description,
    required this.specialists,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    // الـ API يرجع {"message": ..., "department": {data}, "specialists": [...] }
    final Map<String, dynamic>? departmentJson =
        json['department'] as Map<String, dynamic>?;

    if (departmentJson == null) {
      // إذا لم يكن هناك قسم، هذا يشير إلى مشكلة في البيانات من API
      // يمكن أن نرمي FormatException أو نرجع Department بقيم افتراضية هنا
      // ولكننا نعتمد الآن على ApiService لإدارة هذا.
      // ومع ذلك، هذا الفحص مهم للتأكد من بنية الـ JSON
      throw FormatException(
          "Department data is missing from the API response body.");
    }

    var specialistsListJson = json['specialists'] as List<dynamic>?;
    List<Specialist> specialists = specialistsListJson != null
        ? specialistsListJson
            .map((i) => Specialist.fromJson(i as Map<String, dynamic>))
            .toList()
        : [];

    return Department(
      id: departmentJson['id']?.toString() ?? 'غير معروف',
      name: departmentJson['name'] as String? ?? 'غير معروف',
      branchId: departmentJson['branch_id']?.toString() ?? 'غير معروف',
      departmentNumber:
          departmentJson['department_number'] as String? ?? 'غير معروف',
      createdAt: departmentJson['created_at'] as String?,
      updatedAt: departmentJson['updated_at'] as String?,
      description: departmentJson['description'] as String?,
      specialists: specialists,
    );
  }
}
