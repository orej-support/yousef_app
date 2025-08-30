// lib/models/report_family.dart
import 'package:flutter/material.dart';
import 'package:youseuf_app/models/specialist.dart'; // قد تحتاجها لبعض الـ widgets إذا لم تكن موجودة

class ReportFamily {
  final String id;
  final String title;
  final String category;
  final String? description;
  final String specialistId;
  final String? specialistName; // اسم الأخصائي
  final DateTime? createdAt; // تم التعديل: أصبح قابلاً لـ null
  final DateTime? updatedAt; // تم التعديل: أصبح قابلاً لـ null
  final List<ReportFile>? files;

  ReportFamily(
    this.specialistName, {
    required this.id,
    required this.title,
    required this.category,
    this.description,
    required this.specialistId,
    this.createdAt, // لم يعد required
    this.updatedAt, // لم يعد required
    this.files,
  });

  factory ReportFamily.fromJson(Map<String, dynamic> json) {
    return ReportFamily(
      json['specialist_name'] as String?, // Pass specialistName as the first positional argument
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String? ?? 'غير محدد',
      description: json['description'] as String?,
      specialistId: json['specialist_id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(
              json['created_at'] as String) // استخدام tryParse أكثر أمانًا
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(
              json['updated_at'] as String) // استخدام tryParse أكثر أمانًا
          : null,
      files: (json['files'] as List<dynamic>?)
          ?.map((e) => ReportFile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'specialist_id': specialistId,
      'created_at': createdAt?.toIso8601String(), // استخدام ? للتعامل مع null
      'updated_at': updatedAt?.toIso8601String(), // استخدام ? للتعامل مع null
      'files': files?.map((e) => e.toJson()).toList(),
      
      'specialist_name': specialistName,
    };
  }
}

// نموذج بسيط للملفات
class ReportFile {
  final String id;
  final String reportFamilyId;
  final String filePath;
  final DateTime? createdAt; // تم التعديل: أصبح قابلاً لـ null
  final DateTime? updatedAt; // تم التعديل: أصبح قابلاً لـ null

  ReportFile({
    required this.id,
    required this.reportFamilyId,
    required this.filePath,
    this.createdAt, // لم يعد required
    this.updatedAt, // لم يعد required
  });

  factory ReportFile.fromJson(Map<String, dynamic> json) {
    return ReportFile(
      id: json['id'] as String,
      reportFamilyId: json['report_family_id'] as String,
      filePath: json['file_path'] as String,
      // التعديل هنا: فحص إذا كانت القيمة ليست null قبل التحويل
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(
              json['created_at'] as String) // استخدام tryParse أكثر أمانًا
          : null,
      // التعديل هنا: فحص إذا كانت القيمة ليست null قبل التحويل
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(
              json['updated_at'] as String) // استخدام tryParse أكثر أمانًا
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_family_id': reportFamilyId,
      'file_path': filePath,
      'created_at': createdAt?.toIso8601String(), // استخدام ? للتعامل مع null
      'updated_at': updatedAt?.toIso8601String(), // استخدام ? للتعامل مع null
    };
  }
}
