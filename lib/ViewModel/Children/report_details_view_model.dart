// // import 'package:flutter/material.dart';

// // class ReportDetailsViewModel extends ChangeNotifier {
// //   final Map<String, dynamic> reportData;
// //   final String childName;

// //   ReportDetailsViewModel({
// //     required this.reportData,
// //     required this.childName,
// //   });

// //   String get title => reportData['title'] ?? 'عنوان غير متوفر';

// //   String get content => reportData['content'] ?? 'لا يوجد محتوى';

// //   /// قائمة روابط الملفات إن وُجدت
// //   List<String> get fileUrls {
// //     final List<dynamic>? files = reportData['files'];
// //     if (files != null && files.isNotEmpty) {
// //       return files.map((e) => e.toString()).toList();
// //     }
// //     return [];
// //   }

// //   /// هل يحتوي التقرير على أي مرفقات؟
// //   bool get hasMedia => fileUrls.isNotEmpty;
// // }
// import 'package:flutter/material.dart';
// import 'package:youseuf_app/models/report_model.dart';


// class ReportDetailsViewModel extends ChangeNotifier {
//   final ReportModel report;
//   final String childName;

//   ReportDetailsViewModel({
//     required this.report,
//     required this.childName,
//   });


//   /// عنوان التقرير
//   String get title =>
//       report.title.isNotEmpty ? report.title : "عنوان غير متوفر";

//   /// محتوى التقرير
//   String get content =>
//       report.content.isNotEmpty ? report.content : "لا يوجد محتوى";

  
//   /// حالة التقرير
//   String get status =>
//       report.status.isNotEmpty ? report.status : "غير محدد";

//   /// التاريخ بصيغة yyyy-MM-dd
//   String get date =>
//       "${report.createdAt.year}-${report.createdAt.month.toString().padLeft(2, '0')}-${report.createdAt.day.toString().padLeft(2, '0')}";

//   /// روابط الملفات
//   List<String> get fileUrls => report.files;

//   /// هل يحتوي التقرير على مرفقات؟
//   bool get hasMedia => report.files.isNotEmpty;

//   /// تحديث البيانات
//   Future<void> refreshData() async {
//     // قم بإعادة تحميل البيانات هنا
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:youseuf_app/models/report_model.dart';

class ReportDetailsViewModel extends ChangeNotifier {
  final ReportModel report;
  final String childName;

  /// الحالة (تحميل - خطأ - بيانات)
  bool isLoading = false;
  String? errorMessage;

  ReportDetailsViewModel({
    required this.report,
    required this.childName,
  });

  /// عنوان التقرير
  String get title =>
      report.title.isNotEmpty ? report.title : "عنوان غير متوفر";

  /// محتوى التقرير
  String get content =>
      report.content.isNotEmpty ? report.content : "لا يوجد محتوى";

  /// حالة التقرير
  String get status =>
      report.status.isNotEmpty ? report.status : "غير محدد";

  /// التاريخ بصيغة yyyy-MM-dd
  String get date =>
      "${report.createdAt.year}-${report.createdAt.month.toString().padLeft(2, '0')}-${report.createdAt.day.toString().padLeft(2, '0')}";

  /// روابط الملفات
  List<String> get fileUrls => report.files;

  /// هل يحتوي التقرير على مرفقات؟
  bool get hasMedia => report.files.isNotEmpty;

  /// تحديث البيانات (ممكن تربطها مع Supabase أو API)
  Future<void> refreshData() async {
    try {
      isLoading = true;
      notifyListeners();

      // 👇 هنا تحط كود إعادة التحميل من الـ API أو Supabase
      await Future.delayed(const Duration(seconds: 1));

      // مثال: لو فيه مشكلة بالتحميل
      // throw Exception("تعذر تحميل التقرير");

    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// مسح رسالة الخطأ بعد عرضها
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
