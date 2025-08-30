
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/widget/Specialist/report_media_widget.dart';
import 'package:youseuf_app/ViewModel/Family/family_report_details_view_model.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/date_utils.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد

class FamilyReportDetails extends StatelessWidget {
  final Map<String, dynamic> report;

  const FamilyReportDetails({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    return ChangeNotifierProvider(
      create: (_) => FamilyReportDetailsViewModel(report['id']),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "تفاصيل التقرير",
            style: TextStyle(
                fontSize: ScreenSize.getWidth(5)), // 💡 استخدام نسبة مئوية
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Consumer<FamilyReportDetailsViewModel>(
            builder: (context, vm, _) {
              if (vm.isLoading) {
                return Center(
                  child: CircularProgressIndicator(color: blue),
                );
              }

              if (vm.errorMessage != null) {
                return Center(
                  child: Text(
                    vm.errorMessage!,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize:
                            ScreenSize.getWidth(4)), // 💡 استخدام نسبة مئوية
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return SingleChildScrollView(
                // 💡 استخدام نسب مئوية للهوامش
                padding: EdgeInsets.all(ScreenSize.getWidth(4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFamilyCard(context, vm.title),
                    SizedBox(
                        height:
                            ScreenSize.getHeight(2)), // 💡 استخدام نسبة مئوية
                    _buildReportCard(vm),
                    SizedBox(
                        height:
                            ScreenSize.getHeight(2)), // 💡 استخدام نسبة مئوية
                    _buildReportContent(vm.description),
                    if (vm.allFileUrls.isNotEmpty) ...[
                      SizedBox(
                          height:
                              ScreenSize.getHeight(2)), // 💡 استخدام نسبة مئوية
                      _buildAttachments(vm.allFileUrls),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // 💡 تم تحديث الدوال المساعدة لاستخدام النسب المئوية
  Widget _buildFamilyCard(BuildContext context, String familyName) {
    return Padding(
      // 💡 استخدام نسب مئوية للهوامش
      padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(2)),
      child: Center(
        child: Container(
          width: ScreenSize.getWidth(80), // 💡 استخدام نسبة مئوية
          height: ScreenSize.getHeight(8), // 💡 استخدام نسبة مئوية
          // 💡 استخدام نسب مئوية للهوامش
          padding: EdgeInsets.symmetric(
            horizontal: ScreenSize.getWidth(4),
            vertical: ScreenSize.getHeight(1),
          ),
          decoration: BoxDecoration(
            color: white,
            // 💡 استخدام نسبة مئوية لنصف القطر
            borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)),
            border: Border.all(color: grey300),
          ),
          child: Center(
            child: Text(
              familyName,
              style: TextStyle(
                fontSize: ScreenSize.getWidth(4.5), // 💡 استخدام نسبة مئوية
                fontWeight: FontWeight.bold,
                color: black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(FamilyReportDetailsViewModel vm) {
    return Container(
      // 💡 استخدام نسب مئوية للهوامش
      padding: EdgeInsets.all(ScreenSize.getWidth(3.5)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        // 💡 استخدام نسبة مئوية لنصف القطر
        borderRadius: BorderRadius.circular(ScreenSize.getWidth(3.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ScreenSize.getHeight(1)), // 💡 استخدام نسبة مئوية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDateTime(vm.createdAt ?? DateTime.now()),
                style: TextStyle(
                    fontSize:
                        ScreenSize.getWidth(3.5)), // 💡 استخدام نسبة مئوية
              ),
              Text(
                "التصنيف: ${vm.category}",
                style: TextStyle(
                  fontSize: ScreenSize.getWidth(3.5), // 💡 استخدام نسبة مئوية
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(String content) {
    return Container(
      // 💡 استخدام نسب مئوية للهوامش
      padding: EdgeInsets.all(ScreenSize.getWidth(3.5)),
      decoration: BoxDecoration(
        color: Colors.white,
        // 💡 استخدام نسبة مئوية لنصف القطر
        borderRadius: BorderRadius.circular(ScreenSize.getWidth(3.5)),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        content,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildAttachments(List<String> fileUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "المرفقات",
          style: TextStyle(
            fontSize: ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ScreenSize.getHeight(1)), // 💡 استخدام نسبة مئوية
        ...fileUrls.map(
          (url) => Padding(
            // 💡 استخدام نسب مئوية للهوامش
            padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(0.8)),
            child: ReportMediaWidget(fileUrl: url),
          ),
        ),
      ],
    );
  }
}
