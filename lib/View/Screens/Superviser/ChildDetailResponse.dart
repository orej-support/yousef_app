// lib/View/Screens/Superviser/ChildDetailResponse.dart
// هذه النماذج مخصصة لاستجابة API /children/{id} بأسماء معدلة لتجنب التعارض

import 'dart:convert'; // لاستخدام jsonDecode
import 'package:flutter/foundation.dart'; // لاستخدام debugPrint

class ChildDetailResponse {
  final String status;
  final DetailedChildDetailData? data; // تم تغيير النوع هنا
  final String? message; // لرسائل الأخطاء أو النجاح

  ChildDetailResponse({required this.status, this.data, this.message});

  factory ChildDetailResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing ChildDetailResponse JSON: $json');
    return ChildDetailResponse(
      status: json['status'] as String,
      data: json['data'] != null
          ? DetailedChildDetailData.fromJson(json['data'] as Map<String, dynamic>) // تم تغيير اسم الكلاس هنا
          : null,
      message: json['message'] as String?,
    );
  }
}

// النموذج الذي يضم كائن DetailedChild الرئيسي وقائمة الأقسام الفريدة والتقارير والملاحظات
class DetailedChildDetailData { // تم تغيير اسم الكلاس هنا
  final DetailedChild child; // تم تغيير النوع هنا
  final List<UniqueDepartmentWithSpecialists> uniqueDepartmentsWithSpecialists;
  final List<DetailedReport>? reports; // تم تغيير النوع هنا
  final List<DetailedChildNote>? childNotes; // تم تغيير النوع هنا

  DetailedChildDetailData({ // تم تغيير اسم الكلاس هنا
    required this.child,
    required this.uniqueDepartmentsWithSpecialists,
    this.reports,
    this.childNotes,
  });

  factory DetailedChildDetailData.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing DetailedChildDetailData JSON: $json');
    return DetailedChildDetailData( // تم تغيير اسم الكلاس هنا
      child: DetailedChild.fromJson(json['child'] as Map<String, dynamic>), // تم تغيير اسم الكلاس هنا
      uniqueDepartmentsWithSpecialists:
          (json['unique_departments_with_specialists'] as List<dynamic>)
              .map((e) => UniqueDepartmentWithSpecialists.fromJson(e as Map<String, dynamic>))
              .toList(),
      reports: (json['reports'] as List<dynamic>?)
          ?.map((e) => DetailedReport.fromJson(e as Map<String, dynamic>)) // تم تغيير اسم الكلاس هنا
          .toList(),
      childNotes: (json['childNotes'] as List<dynamic>?) // تم تغيير الاسم هنا ليتوافق مع الـ JSON
          ?.map((e) => DetailedChildNote.fromJson(e as Map<String, dynamic>)) // تم تغيير اسم الكلاس هنا
          .toList(),
    );
  }
}

// نموذج DetailedChild (مفصل أكثر، مع قائمة DetailedSpecialists وحقول إضافية)
class DetailedChild { // تم تغيير اسم الكلاس هنا
  final String id;
  final String name;
  final String gender;
  final int age;
  final String? notes;
  final String? birthDate;
  final String? createdAt;
  final String? updatedAt;
  final String? branchId;
  final String? healthIssues;
  final String? emergencyContact;

  final List<DetailedSpecialist> specialists; // تم تغيير النوع هنا

  DetailedChild({ // تم تغيير اسم الكلاس هنا
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    this.notes,
    this.birthDate,
    this.createdAt,
    this.updatedAt,
    this.branchId,
    this.healthIssues,
    this.emergencyContact,
    required this.specialists,
  });

  factory DetailedChild.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing DetailedChild JSON: $json');
    return DetailedChild( // تم تغيير اسم الكلاس هنا
      id: json['id'].toString(),
      name: json['name'] as String,
      gender: json['gender'] as String,
      age: json['age'] as int,
      notes: json['notes'] as String?,
      birthDate: json['birthDate'] as String?, // تم التعديل ليتوافق مع JSON
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      branchId: json['branch_id']?.toString(),
      healthIssues: json['health_issues'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      specialists: (json['specialists'] as List<dynamic>?)
              ?.map((e) => DetailedSpecialist.fromJson(e as Map<String, dynamic>)) // تم تغيير اسم الكلاس هنا
              .toList() ??
          [],
    );
  }
}

// نموذج DetailedSpecialist (مفصل أكثر، مع Pivot و DetailedDepartment)
class DetailedSpecialist { // تم تغيير اسم الكلاس هنا
  final String id;
  final String name;
  final String? departmentId;
  final Pivot? pivot;
  final DetailedDepartment? department; // تم تغيير النوع هنا

  final String? email;
  final String? phoneNumber;
  final String? type;

  DetailedSpecialist({ // تم تغيير اسم الكلاس هنا
    required this.id,
    required this.name,
    this.departmentId,
    this.pivot,
    this.department,
    this.email,
    this.phoneNumber,
    this.type,
  });

  factory DetailedSpecialist.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing DetailedSpecialist JSON: $json');
    return DetailedSpecialist( // تم تغيير اسم الكلاس هنا
      id: json['id'].toString(),
      name: json['name'] as String,
      departmentId: json['department_id']?.toString(),
      pivot: json['pivot'] != null
          ? Pivot.fromJson(json['pivot'] as Map<String, dynamic>)
          : null,
      department: json['department'] != null
          ? DetailedDepartment.fromJson(json['department'] as Map<String, dynamic>) // تم تغيير اسم الكلاس هنا
          : null,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      type: json['type'] as String?,
    );
  }
}

// نموذج Pivot (لم يتم تغيير اسمه لأنه خاص بالعلاقة)
class Pivot {
  final String childId;
  final String specialistId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Pivot({
    required this.childId,
    required this.specialistId,
    this.createdAt,
    this.updatedAt,
  });

  factory Pivot.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing Pivot JSON: $json');
    return Pivot(
      childId: json['child_id'].toString(),
      specialistId: json['specialist_id'].toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) // استخدام tryParse
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) // استخدام tryParse
          : null,
    );
  }
}

// نموذج DetailedDepartment (تم تغيير اسمه لتجنب التعارض)
class DetailedDepartment { // تم تغيير اسم الكلاس هنا
  final String id;
  final String name;
  final String? departmentNumber;

  DetailedDepartment({ // تم تغيير اسم الكلاس هنا
    required this.id,
    required this.name,
    this.departmentNumber,
  });

  factory DetailedDepartment.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing DetailedDepartment JSON: $json');
    return DetailedDepartment( // تم تغيير اسم الكلاس هنا
      id: json['id'].toString(),
      name: json['name'] as String,
      departmentNumber: json['department_number'] as String?,
    );
  }
}

// نموذج UniqueDepartmentWithSpecialists (لم يتم تغيير اسمه لأنه خاص بهذه الاستجابة)
class UniqueDepartmentWithSpecialists {
  final String name;
  final String? departmentNumber;
  final List<AssociatedSpecialist> associatedSpecialists;

  UniqueDepartmentWithSpecialists({
    required this.name,
    this.departmentNumber,
    required this.associatedSpecialists,
  });

  factory UniqueDepartmentWithSpecialists.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing UniqueDepartmentWithSpecialists JSON: $json');
    return UniqueDepartmentWithSpecialists(
      name: json['name'] as String,
      departmentNumber: json['department_number'] as String?,
      associatedSpecialists: (json['associated_specialists'] as List<dynamic>?)
              ?.map((e) => AssociatedSpecialist.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// نموذج AssociatedSpecialist (لم يتم تغيير اسمه لأنه خاص بهذه الاستجابة)
class AssociatedSpecialist {
  final String name;
  final DateTime? relationCreatedAt;

  AssociatedSpecialist({
    required this.name,
    this.relationCreatedAt,
  });

  factory AssociatedSpecialist.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing AssociatedSpecialist JSON: $json');
    return AssociatedSpecialist(
      name: json['name'] as String,
      relationCreatedAt: json['relation_created_at'] != null
          ? DateTime.tryParse(json['relation_created_at'] as String) // استخدام tryParse
          : null,
    );
  }
}

// نماذج جديدة للتقارير والملاحظات بأسماء معدلة
class DetailedReport { // تم تغيير اسم الكلاس هنا
  final String id;
  final String childId;
  final String specialistId;
  final String content; // تم التعديل من reportText إلى content
  final String title; // تم إضافة حقل title
  final String status; // تم إضافة حقل status
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DetailedSpecialist? specialist; // تم تغيير النوع هنا

  DetailedReport({ // تم تغيير اسم الكلاس هنا
    required this.id,
    required this.childId,
    required this.specialistId,
    required this.content, // تم التعديل
    required this.title, // تم الإضافة
    required this.status, // تم الإضافة
    this.createdAt,
    this.updatedAt,
    this.specialist,
  });

  factory DetailedReport.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing DetailedReport JSON: $json');
    return DetailedReport( // تم تغيير اسم الكلاس هنا
      id: json['id'].toString(),
      childId: json['child_id'].toString(),
      specialistId: json['specialist_id'].toString(),
      content: json['content'] as String, // تم التعديل
      title: json['title'] as String, // تم الإضافة
      status: json['status'] as String, // تم الإضافة
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) // استخدام tryParse
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) // استخدام tryParse
          : null,
      specialist: json['specialist'] != null
          ? DetailedSpecialist.fromJson(json['specialist'] as Map<String, dynamic>) // تم تغيير اسم الكلاس هنا
          : null,
    );
  }
}

class DetailedChildNote { // تم تغيير اسم الكلاس هنا
  final String id;
  final String childId;
  final String content; // تم التعديل من note إلى content
  final String title; // تم إضافة حقل title
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? specialistId; // تم إضافة هذا الحقل
  final String? supervisorId; // تم إضافة هذا الحقل

  DetailedChildNote({ // تم تغيير اسم الكلاس هنا
    required this.id,
    required this.childId,
    required this.content, // تم التعديل
    required this.title, // تم الإضافة
    this.createdAt,
    this.updatedAt,
    this.specialistId, // تم إضافة هذا الحقل
    this.supervisorId, // تم إضافة هذا الحقل
  });

  factory DetailedChildNote.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing DetailedChildNote JSON: $json');
    return DetailedChildNote( // تم تغيير اسم الكلاس هنا
      id: json['id'].toString(),
      childId: json['child_id'].toString(),
      content: json['content'] as String, // تم التعديل
      title: json['title'] as String, // تم الإضافة
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) // استخدام tryParse
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) // استخدام tryParse
          : null,
      specialistId: json['specialist_id']?.toString(), // تم إضافة هذا الحقل
      supervisorId: json['supervisor_id']?.toString(), // تم إضافة هذا الحقل
    );
  }
}
