import 'package:intl/intl.dart';
import 'package:youseuf_app/models/specialist.dart';

class ReportFamily {
  final String id;
  final String title;
  final String category;
  final String? description;
  final Specialist specialist; // تم التعديل ليكون من نوع Specialist
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ReportFile>? files;

  ReportFamily({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    required this.specialist, // تم التعديل
    this.createdAt,
    this.updatedAt,
    this.files,
  });


factory ReportFamily.fromJson(Map<String, dynamic> json) {
  DateTime? parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      // صيغة التاريخ القادمة: "2025-08-31 02:40:30"
      return DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateStr, true).toLocal();
    } catch (_) {
      return null;
    }
  }

  return ReportFamily(
    id: json['id']?.toString() ?? '',
    title: json['title'] as String? ?? 'بدون عنوان',
    category: json['category'] as String? ?? 'غير محدد',
    description: json['description'] as String?,
    specialist: json['specialist'] != null
        ? Specialist.fromJson(json['specialist'] as Map<String, dynamic>)
        : Specialist(id: '0', name: 'غير معروف'),
    createdAt: parseDate(json['created_at'] as String?),
    updatedAt: parseDate(json['updated_at'] as String?),
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
      'specialist': specialist.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'files': files?.map((e) => e.toJson()).toList(),
    };
  }
}

// نموذج بسيط للملفات
class ReportFile {
  final String id;
  final String reportFamilyId;
  final String filePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReportFile({
    required this.id,
    required this.reportFamilyId,
    required this.filePath,
    this.createdAt,
    this.updatedAt,
  });

  factory ReportFile.fromJson(Map<String, dynamic> json) {
    return ReportFile(
      id: json['id'] as String,
      reportFamilyId: json['report_family_id'] as String,
      filePath: json['file_path'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_family_id': reportFamilyId,
      'file_path': filePath,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}