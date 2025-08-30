import 'package:flutter/material.dart';
import 'package:youseuf_app/models/child.dart';
import 'package:youseuf_app/models/report_model.dart';
import 'package:youseuf_app/services/api_service.dart';

class ReportsViewModel extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  List<ReportModel> _reports = [];
  Child? _childData;

  bool isLoading = false;
  String? errorMessage;

  final ApiService _apiService = ApiService();

  List<ReportModel> get reports => _reports;
  Child? get childData => _childData;

  Future<void> fetchReportsForChild( String childId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.getChildReportsAndNotes(childId);
      debugPrint("بيانات كاملة: $data");

      if (data != null) {
       _childData = data['child_data'] != null ? Child.fromJson(data['child_data']) : null;


        final reportsData = data['reports'] as List<dynamic>? ?? [];
        _reports = reportsData
            .map((reportJson) => ReportModel.fromMap(reportJson))
            .toList();

        debugPrint("عدد التقارير: ${reportsData.length}");

        // _reports = reportsData
        //     .map((reportJson) => ReportModel.fromMap(reportJson))
        //     .toList();
      } else {
        _reports = [];
        _childData = null;
        errorMessage = 'لا توجد تقارير متاحة.';
      }
    } catch (e) {
      errorMessage = e.toString().replaceFirst("Exception: ", "");
    }

    isLoading = false;
    notifyListeners();
  }

  void addReport(ReportModel report) {
    _reports.insert(0, report);
    notifyListeners();
  }

  void changeTab(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  String getTitle() {
    switch (_selectedIndex) {
      case 0:
        return "التقارير";
      case 1:
        return "ملحوظات";
      case 2:
        return "معلومات";
      default:
        return "";
    }
  }

  Future<void> refreshData() async {
    if (_childData != null) {
      await fetchReportsForChild(_childData!.id!);
    }
  }

}
