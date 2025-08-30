// import 'package:flutter/material.dart';

// // ------------------------------------
// // Section 1: Error Message Constants
// // ------------------------------------
// class ErrorMessages {
//   // أخطاء الاتصال بالإنترنت
//   static const String noInternetConnection = 'لا يوجد اتصال بالإنترنت.';

//   // أخطاء تسجيل الدخول والمصادقة
//   static const String loginFailedUnexpectedFormat =
//       'فشل تسجيل الدخول: تنسيق استجابة غير متوقع.';
//   static const String unauthorized = 'غير مصرح به';
//   static const String logoutFailed = 'فشل تسجيل الخروج: ';

//   // أخطاء عامة وغير متوقعة
//   static const String unexpectedError = 'حدث خطأ غdddddddddddير متوقع: ';
//   static const String unexpectedErrorForgotPasswordUser =
//       'حدث خطأ غير متوقع أثناء طلب إعادة تعيين كلمة المرور للمستخدم: ';
//   static const String unexpectedErrorVerifyOtpUser =
//       'حدث خطأ غير متوقع أثناء التحقق من رمز التأكيد للمستخدم:  ';
//   static const String unexpectedErrorGetSpecialistProfile =
//       'حدث خطأ غير متوقع أثناء جلب الملف الشخصي للأخصائي: ';
//   static const String unexpectedErrorUpdateSpecialistProfile =
//       'حدث خطأ غير متوقع أثناء تحديث الملف الشخصي للأخصائي: ';
//   static const String unexpectedErrorResetPasswordUser =
//       'حدث خطأ غير متوقع أثناء إعادة تعيين كلمة المرور للمستخدم: ';
//   static const String unexpectedErrorGetUserDashboardStats =
//       'حدث خطأ غير متوقع أثناء جلب إحصائيات لوحة التحكم للمستخدم: ';
//   static const String unexpectedErrorForgotPasswordSpecialist =
//       'حدث خطأ غير متوقع أثناء طلب إعادة تعيين كلمة المرور للأخصائي: ';
//   static const String unexpectedErrorVerifyOtpSpecialist =
//       'حدث خطأ غير متوقع أثناء التحقق من رمز التأكيد للأخصائي: ';
//   static const String unexpectedErrorResetPasswordSpecialist =
//       'حدث خطأ غير متوقع أثناء إعادة تعيين كلمة المرور للأخصائي: ';
//   static const String unexpectedErrorGetChildDetails =
//       'حدث خطأ غير متوقع أثناء جلب تفاصيل الابن: ';
//   static const String unexpectedErrorGetReportFamilies = 'حدث خطأ غير متوقع:';
//   static const String unexpectedErrorGetChildReportsAndNotes =
//       'حدث خطأ غير متوقع: ';
//   static const String unexpectedErrorCreateReport = 'حدث خطأ غير متوقع: ';

//   // أخطاء تنسيق الاستجابة
//   static const String unexpectedResponseFormat = 'تنسيق استجابة غير متوقع.';
//   static const String unexpectedResponseFormatLogin = 'فشل تسجيل الدخول ';
//   static const String unexpectedResponseFormatGetUserDashboard =
//       'تنسيق استجابة غير متوقع لإحصائيات لوحة التحكم.';
//   static const String missingSpecialistKey =
//       'تنسيق استجابة غير متوقع بعد تحديث الملف الشخصي. المفتاح "specialist" مفقود.';
//   static const String unexpectedResponseFormatGetMyChildren =
//       'تنسيق استجابة غير متوقع.';
//   static const String unexpectedResponseFormatChildData =
//       'تنسيق استجابة غير متوقع.';
//   static const String unexpectedResponseFormatReportsAndNotes =
//       'تنسيق استجابة غير متوقع.';

//   // أخطاء التحليل
//   static const String failedToParseSpecialistData =
//       'Failed to parse specialists data: Expected a list or map with "specialists" key.';

//   // أخطاء أخرى
//   static const String apiException = 'ApiExceptinnnnon: ';
// }

// // ------------------------------------
// // Section 2: UI Widget for Error Dialog
// // ------------------------------------
// void showErrorDialog(BuildContext context, String title, String message) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16.0),
//           ),
//           padding: EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               // رمز التحذير
//               Icon(
//                 Icons.warning_amber_rounded,
//                 color: Colors.yellow[700],
//                 size: 60,
//               ),
//               const SizedBox(height: 16),
//               // عنوان الخطأ
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: Colors.blue[900],
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//               // رسالة الخطأ
//               Text(
//                 message,
//                 style: TextStyle(
//                   color: Colors.grey[700],
//                   fontSize: 14,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               // زر الإغلاق
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text('إغلاق'),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
import 'package:flutter/material.dart';

// ------------------------------------
// Section 1: Error Message Constants (بالعربي فقط)
// ------------------------------------
class ErrorMessages {
  // أخطاء الاتصال بالإنترنت
  static const String noInternetConnection = 'لا يوجد اتصال بالإنترنت.';
  static const String requestTimeout = 'انتهت مهلة الطلب، حاول مرة أخرى.';

  // أخطاء تسجيل الدخول والمصادقة
  static const String loginFailedUnexpectedFormat =
      'فشل تسجيل الدخول: تنسيق الاستجابة غير متوقع.';
  static const String unauthorized = 'غير مصرح لك بتنفيذ هذا الإجراء.';
  static const String logoutFailed = 'فشل تسجيل الخروج: ';

  // أخطاء عامة وغير متوقعة
  static const String unexpectedError = 'حدث خطأ غير متوقع: ';
  static const String unexpectedErrorForgotPasswordUser =
      'حدث خطأ غير متوقع أثناء طلب إعادة تعيين كلمة المرور للمستخدم.';
  static const String unexpectedErrorVerifyOtpUser =
      'حدث خطأ غير متوقع أثناء التحقق من رمز التأكيد للمستخدم.';
  static const String logoutSuccess = "تم تسجيل الدخول";
  static const String unexpectedErrorGetSpecialistProfile =
      'حدث خطأ غير متوقع أثناء جلب الملف الشخصي للأخصائي.';
  static const String unexpectedErrorUpdateSpecialistProfile =
      'حدث خطأ غير متوقع أثناء تحديث الملف الشخصي للأخصائي.';
  static const String unexpectedErrorResetPasswordUser =
      'حدث خطأ غير متوقع أثناء إعادة تعيين كلمة المرور للمستخدم.';
  static const String unexpectedErrorGetUserDashboardStats =
      'حدث خطأ غير متوقع أثناء جلب إحصائيات لوحة التحكم للمستخدم.';
  static const String unexpectedErrorForgotPasswordSpecialist =
      'حدث خطأ غير متوقع أثناء طلب إعادة تعيين كلمة المرور للأخصائي.';
  static const String unexpectedErrorVerifyOtpSpecialist =
      'حدث خطأ غير متوقع أثناء التحقق من رمز التأكيد للأخصائي.';
  static const String unexpectedErrorResetPasswordSpecialist =
      'حدث خطأ غير متوقع أثناء إعادة تعيين كلمة المرور للأخصائي.';
  static const String unexpectedErrorGetChildDetails =
      'حدث خطأ غير متوقع أثناء جلب تفاصيل الابن.';
  static const String unexpectedErrorGetReportFamilies =
      'حدث خطأ غير متوقع أثناء جلب تقارير العائلة.';
  static const String unexpectedErrorGetChildReportsAndNotes =
      'حدث خطأ غير متوقع أثناء جلب تقارير وملاحظات الطفل.';
  static const String unexpectedErrorCreateReport =
      'حدث خطأ غير متوقع أثناء إنشاء التقرير.';

  // أخطاء تنسيق الاستجابة
  static const String unexpectedResponseFormat = 'تنسيق الاستجابة غير متوقع.';
  static const String unexpectedResponseFormatLogin =
      'فشل تسجيل الدخول: بيانات غير صحيحة.';
  static const String unexpectedResponseFormatGetUserDashboard =
      'تنسيق الاستجابة غير متوقع لإحصائيات لوحة التحكم.';
  static const String missingSpecialistKey =
      'تنسيق الاستجابة غير متوقع بعد تحديث الملف الشخصي، المفتاح "specialist" مفقود.';
  static const String unexpectedResponseFormatGetMyChildren =
      'تنسيق الاستجابة غير متوقع أثناء جلب بيانات الأبناء.';
  static const String unexpectedResponseFormatChildData =
      'تنسيق الاستجابة غير متوقع لبيانات الطفل.';
  static const String unexpectedResponseFormatReportsAndNotes =
      'تنسيق الاستجابة غير متوقع للتقارير والملاحظات.';

  // أخطاء التحليل
  static const String failedToParseSpecialistData =
      'فشل في معالجة بيانات الأخصائي: صيغة غير متوقعة.';

  // أخطاء أخرى
  static const String apiException = 'خطأ في واجهة البرمجة: ';
}

// ------------------------------------
// Section 2: UI Widget for Error Dialog
// ------------------------------------
void showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // رمز التحذير
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.yellow[700],
                size: 60,
              ),
              const SizedBox(height: 16),
              // عنوان الخطأ
              Text(
                title,
                style: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // رسالة الخطأ
              // Text(
              //   message,
              //   style: TextStyle(
              //     color: Colors.grey[700],
              //     fontSize: 14,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              const SizedBox(height: 20),
              // زر الإغلاق
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
