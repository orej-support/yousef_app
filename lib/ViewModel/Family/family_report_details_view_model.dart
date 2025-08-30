import 'package:flutter/material.dart';
import 'package:youseuf_app/models/report_family.dart';
import 'package:youseuf_app/services/api_service.dart';

class FamilyReportDetailsViewModel extends ChangeNotifier {
  final String reportId;

  FamilyReportDetailsViewModel(this.reportId) {
    fetchReportDetails();
  }

  final ApiService _apiService = ApiService();

  ReportFamily? _report;
  ReportFamily? get report => _report;
  DateTime? get createdAt => report?.createdAt?.toLocal();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  List<String> get allFileUrls {
    if (report?.files != null && report!.files!.isNotEmpty) {
      return report!.files!.map((f) => f.filePath).toList();
    }
    return [];
  }

  Future<void> fetchReportDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.getReportFamilyDetails(reportId);
      if (data != null) {
        _report = ReportFamily.fromJson(data);
      } else {
        _errorMessage = "لم يتم العثور على بيانات التقرير.";
      }
    } catch (e) {
      _errorMessage = "فشل في جلب البيانات: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String get title => report?.title ?? 'عنوان غير متوفر';
  String get description => report?.description ?? 'لا يوجد وصف';
  String get category => report?.category ?? 'غير محدد';

  String get formattedDate {
    final dt = report?.createdAt?.toLocal();
    if (dt == null) return "تاريخ غير متوفر";
    return "${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  /// نأخذ أول ملف فقط للتوافق مع التصميم القديم
  String? get firstFileUrl {
    if (report?.files != null && report!.files!.isNotEmpty) {
      return report!.files!.first.filePath;
    }
    return null;
  }

  Future<void> loadReportDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.getReportFamilyDetails(reportId);
      if (data != null) {
        _report = ReportFamily.fromJson(data);
      } else {
        _errorMessage = "لم يتم العثور على بيانات التقرير.";
      }
    } catch (e) {
      _errorMessage = "فشل في جلب البيانات: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
