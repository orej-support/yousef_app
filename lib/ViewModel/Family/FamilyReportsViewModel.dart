import 'package:flutter/material.dart';
import 'package:youseuf_app/services/api_service.dart';

class FamilyReportsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> get reports => _reports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadReports() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.getReportFamilies();
      if (data != null && data is List) {
        _reports = List<Map<String, dynamic>>.from(data);
      } else {
        _errorMessage = 'لا توجد تقارير.';
        _reports = [];
      }
    } catch (e) {
      _errorMessage = e.toString();
      _reports = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  String formatDateTime(String isoDate) {
    final dateTime = DateTime.parse(isoDate).toLocal();
    return "${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} _ ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
