
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:youseuf_app/View/widget/Specialist/report_media_widget.dart';
// import 'package:youseuf_app/ViewModel/Children/report_details_view_model.dart';
// import 'package:youseuf_app/core/theme/app_colors.dart';
// import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد

// class ReportDetailsView extends StatelessWidget {
//   const ReportDetailsView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // 💡 تهيئة كلاس الأبعاد هنا
//     ScreenSize.init(context);

//     final vm = Provider.of<ReportDetailsViewModel>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("تفاصيل التقرير"),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         // 💡 استخدام نسب مئوية للهوامش
//         padding: EdgeInsets.all(ScreenSize.getWidth(4)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildBeneficiaryCard(context, vm.childName),
//             SizedBox(height: ScreenSize.getHeight(2)), // 💡 استخدام نسبة مئوية
//             _buildReportCard(vm),
//             SizedBox(height: ScreenSize.getHeight(2)), // 💡 استخدام نسبة مئوية
//             _buildReportContent(vm.content),
//             if (vm.hasMedia) ...[
//               SizedBox(
//                   height: ScreenSize.getHeight(2)), // 💡 استخدام نسبة مئوية
//               _buildAttachments(vm.fileUrls),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   /// بطاقة المستفيد
//   Widget _buildBeneficiaryCard(BuildContext context, String childName) {
//     return Padding(
//       // 💡 استخدام نسب مئوية للهوامش
//       padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(2)),
//       child: Center(
//         child: Container(
//           width: ScreenSize.getWidth(80), // 80% من عرض الشاشة
//           height: ScreenSize.getHeight(9), // 💡 استخدام نسبة مئوية للطول
//           padding: EdgeInsets.symmetric(
//             horizontal: ScreenSize.getWidth(4),
//             vertical: ScreenSize.getHeight(1),
//           ),
//           decoration: BoxDecoration(
//             color: white,
//             borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)),
//             border: Border.all(color: grey300),
//           ),
//           child: Center(
//             child: Row(
//               textDirection: TextDirection.rtl,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(ScreenSize.getWidth(1.5)),
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                   ),
//                   child: Image.asset(
//                     'assets/icons/person.png',
//                     width: ScreenSize.getWidth(7),
//                     height: ScreenSize.getWidth(7),
//                   ),
//                 ),
//                 SizedBox(width: ScreenSize.getWidth(2)),
//                 Text(
//                   'الابن: $childName',
//                   style: TextStyle(
//                     fontSize: ScreenSize.getWidth(4.5),
//                     fontWeight: FontWeight.bold,
//                     color: black,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   /// بطاقة التقرير
//   Widget _buildReportCard(ReportDetailsViewModel vm) {
//     return Container(
//       // 💡 استخدام نسب مئوية للهوامش
//       padding: EdgeInsets.all(ScreenSize.getWidth(3.5)),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFF3E0),
//         borderRadius: BorderRadius.circular(ScreenSize.getWidth(3.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Text(
//               vm.title,
//               style: TextStyle(
//                 // 💡 استخدام نسب مئوية لحجم الخط
//                 fontSize: ScreenSize.getWidth(5),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           SizedBox(height: ScreenSize.getHeight(1)), // 💡 استخدام نسبة مئوية
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 vm.date,
//                 style: TextStyle(fontSize: ScreenSize.getWidth(3.5)),
//               ),
//               Row(
//                 children: [
//                   const Text('الحالة:'),
//                   SizedBox(width: ScreenSize.getWidth(1)),
//                   Container(
//                     // 💡 استخدام نسب مئوية للأبعاد
//                     width: ScreenSize.getWidth(2),
//                     height: ScreenSize.getWidth(2),
//                     decoration: BoxDecoration(
//                       color: vm.status == 'ممتازة'
//                           ? Colors.green
//                           : vm.status == 'جيدة'
//                               ? Colors.yellow
//                               : Colors.red,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   SizedBox(width: ScreenSize.getWidth(1)),
//                   Text(
//                     vm.status,
//                     style: TextStyle(
//                       fontSize: ScreenSize.getWidth(3.5),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               )
//             ],
//           ),
//           SizedBox(height: ScreenSize.getHeight(0.5)), // 💡 استخدام نسبة مئوية
//         ],
//       ),
//     );
//   }

//   /// المحتوى
//   Widget _buildReportContent(String content) {
//     return Container(
//       // 💡 استخدام نسب مئوية للهوامش
//       padding: EdgeInsets.all(ScreenSize.getWidth(3.5)),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(ScreenSize.getWidth(3.2)),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Center(
//         child: Text(
//           content,
//           textDirection: TextDirection.rtl,
//           textAlign: TextAlign.justify,
//           style: TextStyle(
//             fontSize: ScreenSize.getWidth(4),
//             height: 1.6,
//           ),
//         ),
//       ),
//     );
//   }

//   /// المرفقات (مع ReportMediaWidget)
//   Widget _buildAttachments(List<String> fileUrls) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Text(
//           "المرفقات",
//           style: TextStyle(
//             // 💡 استخدام نسب مئوية لحجم الخط
//             fontSize: ScreenSize.getWidth(4),
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: ScreenSize.getHeight(1)),
//         ...fileUrls.map(
//           (url) => Padding(
//             // 💡 استخدام نسب مئوية للهوامش
//             padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(0.7)),
//             child: ReportMediaWidget(fileUrl: url),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/widget/Specialist/report_media_widget.dart';
import 'package:youseuf_app/ViewModel/Children/report_details_view_model.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart';

class ReportDetailsView extends StatelessWidget {
  const ReportDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    final vm = Provider.of<ReportDetailsViewModel>(context);

    // ✅ عرض رسالة خطأ كسناكبار
    if (vm.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage!),
            backgroundColor: red,
          ),
        );
        vm.clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("تفاصيل التقرير"),
        centerTitle: true,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.title.isEmpty
              ? const Center(child: Text("لا توجد بيانات للتقرير"))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(ScreenSize.getWidth(4)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBeneficiaryCard(context, vm.childName),
                      SizedBox(height: ScreenSize.getHeight(2)),
                      _buildReportCard(vm),
                      SizedBox(height: ScreenSize.getHeight(2)),
                      _buildReportContent(vm.content),
                      if (vm.hasMedia) ...[
                        SizedBox(height: ScreenSize.getHeight(2)),
                        _buildAttachments(vm.fileUrls),
                      ],
                    ],
                  ),
                ),
    );
  }

  /// بطاقة المستفيد
  Widget _buildBeneficiaryCard(BuildContext context, String childName) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(2)),
      child: Center(
        child: Container(
          width: ScreenSize.getWidth(80),
          height: ScreenSize.getHeight(9),
          padding: EdgeInsets.symmetric(
            horizontal: ScreenSize.getWidth(4),
            vertical: ScreenSize.getHeight(1),
          ),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)),
            border: Border.all(color: grey300),
          ),
          child: Center(
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(ScreenSize.getWidth(1.5)),
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Image.asset(
                    'assets/icons/person.png',
                    width: ScreenSize.getWidth(7),
                    height: ScreenSize.getWidth(7),
                  ),
                ),
                SizedBox(width: ScreenSize.getWidth(2)),
                Text(
                  'الابن: $childName',
                  style: TextStyle(
                    fontSize: ScreenSize.getWidth(4.5),
                    fontWeight: FontWeight.bold,
                    color: black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// بطاقة التقرير
  Widget _buildReportCard(ReportDetailsViewModel vm) {
    return Container(
      padding: EdgeInsets.all(ScreenSize.getWidth(3.5)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(ScreenSize.getWidth(3.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              vm.title,
              style: TextStyle(
                fontSize: ScreenSize.getWidth(5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: ScreenSize.getHeight(1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(vm.date, style: TextStyle(fontSize: ScreenSize.getWidth(3.5))),
              Row(
                children: [
                  const Text('الحالة:'),
                  SizedBox(width: ScreenSize.getWidth(1)),
                  Container(
                    width: ScreenSize.getWidth(2.5),
                    height: ScreenSize.getWidth(2.5),
                    decoration: BoxDecoration(
                      color: vm.status == 'ممتازة'
                          ? Colors.green
                          : vm.status == 'جيدة'
                              ? Colors.yellow
                              : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: ScreenSize.getWidth(1)),
                  Text(
                    vm.status,
                    style: TextStyle(
                      fontSize: ScreenSize.getWidth(3.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  /// محتوى التقرير
  Widget _buildReportContent(String content) {
    return Container(
      padding: EdgeInsets.all(ScreenSize.getWidth(3.5)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.getWidth(3.2)),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        content,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: ScreenSize.getWidth(4),
          height: 1.6,
        ),
      ),
    );
  }

  /// المرفقات
  Widget _buildAttachments(List<String> fileUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "المرفقات",
          style: TextStyle(
            fontSize: ScreenSize.getWidth(4),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ScreenSize.getHeight(1)),
        ...fileUrls.map(
          (url) => Padding(
            padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(0.7)),
            child: ReportMediaWidget(fileUrl: url),
          ),
        ),
      ],
    );
  }
}

