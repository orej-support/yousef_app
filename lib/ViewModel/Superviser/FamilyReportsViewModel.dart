// import 'package:flutter/material.dart';
// import 'package:youseuf_app/models/report_family.dart';
// import 'package:youseuf_app/services/api_service.dart';

// class FamilyReportsViewModel extends ChangeNotifier {
//   bool isLoading = false;
//   String? errorMessage;
//   List<ReportFamily> reports = [];

//   Future<void> fetchFamilyReports() async {
//     isLoading = true;
//     errorMessage = null;
//     notifyListeners();

//     try {
//       reports = await ApiService().getFamilyReports();
//     } catch (e) {
//       errorMessage = e.toString();
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//   String formatDateTime(String isoDate) {
//     final dateTime = DateTime.parse(isoDate).toLocal();
//     return "${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} _ ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
//   }
// }
// lib/ViewModel/Superviser/FamilyReportsViewModel.dart

import 'package:flutter/material.dart';
import 'package:youseuf_app/models/report_family.dart';
import 'package:youseuf_app/services/api_service.dart';

class FamilyReportsViewModel extends ChangeNotifier {
  // 1. أضف مثيل ApiService كخاصية نهائية (final)
  final ApiService apiService;

  bool isLoading = false;
  String? errorMessage;
  List<ReportFamily> reports = [];

  // 2. أنشئ دالة بانية (Constructor) تتطلب مثيل ApiService
  FamilyReportsViewModel({required this.apiService});

  Future<void> fetchFamilyReports() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 3. استخدم مثيل apiService الذي تم تمريره
      reports = await apiService.getFamilyReports();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String formatDateTime(String isoDate) {
    final dateTime = DateTime.parse(isoDate).toLocal();
    return "${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} _ ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}