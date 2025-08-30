import 'package:flutter/material.dart';
import 'package:youseuf_app/View/widget/Sheared/back_leading.dart';
import 'package:youseuf_app/View/widget/Specialist/report_media_widget.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/date_utils.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/ViewModel/Superviser/FamilyReportsViewModel.dart';
import 'package:youseuf_app/models/report_family.dart';
import 'package:youseuf_app/models/specialist.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart';

class ReportDetailsScreen extends StatelessWidget {
  final ReportFamily report;

  const ReportDetailsScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    final apiService =
        Provider.of<FamilyReportsViewModel>(context, listen: false).apiService;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(report.title ?? "تفاصيل التقرير"),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(ScreenSize.getWidth(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BackLeading(),
                  ],
                ),
                _buildSectionHeader("الأخصائي", Icons.person),
                FutureBuilder<Specialist?>(
                  future: apiService.fetchSpecialistById(report.specialistId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildSpecialistCard(context, null,
                          isLoading: true);
                    } else if (snapshot.hasError) {
                      return _buildSpecialistCard(context, null, isError: true);
                    } else {
                      return _buildSpecialistCard(context, snapshot.data);
                    }
                  },
                ),
                SizedBox(height: ScreenSize.getHeight(2)),
                _buildSectionHeader("تفاصيل التقرير", Icons.description),
                _buildReportCard(report),
                SizedBox(height: ScreenSize.getHeight(2)),
                _buildSectionHeader("المحتوى", Icons.article),
                _buildReportContent(report.description),
                if (report.files != null && report.files!.isNotEmpty) ...[
                  SizedBox(height: ScreenSize.getHeight(2)),
                  _buildSectionHeader("المرفقات", Icons.attach_file),
                  _buildAttachments(report.files!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 💡 دالة لبناء عنوان القسم
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenSize.getHeight(1)),
      child: Row(
        children: [
          Icon(icon, color: blue, size: ScreenSize.getWidth(5.5)),
          SizedBox(width: ScreenSize.getWidth(2)),
          Text(
            title,
            style: TextStyle(
              fontSize: ScreenSize.getWidth(4.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 💡 بطاقة الأخصائي
  Widget _buildSpecialistCard(BuildContext context, Specialist? specialist,
      {bool isLoading = false, bool isError = false}) {
    String text;
    Widget leadingWidget;

    if (isLoading) {
      text = "جاري التحميل...";
      leadingWidget = CircularProgressIndicator(color: blue);
    } else if (isError) {
      text = "الأخصائي غير متوفر";
      leadingWidget = Icon(Icons.error_outline, color: red);
    } else {
      text = specialist?.name ?? "الأخصائي غير محدد";
      leadingWidget = Icon(Icons.person, color: blue);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScreenSize.getWidth(3))),
      child: Padding(
        padding: EdgeInsets.all(ScreenSize.getWidth(4)),
        child: Row(
          children: [
            leadingWidget,
            SizedBox(width: ScreenSize.getWidth(3)),
            Text(
              text,
              style: TextStyle(
                  fontSize: ScreenSize.getWidth(4),
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  /// 💡 بطاقة التقرير (التاريخ والتصنيف)
  Widget _buildReportCard(ReportFamily report) {
    return Container(
      padding: EdgeInsets.all(ScreenSize.getWidth(4)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoItem(
              "التصنيف:", report.category ?? "غير محدد", Icons.category),
          _buildInfoItem(
            "تاريخ الإنشاء:",
            report.createdAt != null
                ? formatDateTime(report.createdAt!)
                : "غير محدد",
            Icons.calendar_today,
          ),
        ],
      ),
    );
  }

  /// 💡 عنصر معلومات صغير داخل البطاقة
  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: ScreenSize.getWidth(4.5), color: darkgrey),
        SizedBox(width: ScreenSize.getWidth(1)),
        Text(
          "$label $value",
          style: TextStyle(fontSize: ScreenSize.getWidth(3.5), color: black54),
        ),
      ],
    );
  }

  /// 💡 محتوى التقرير (الوصف)
  Widget _buildReportContent(String? content) {
    return Container(
      padding: EdgeInsets.all(ScreenSize.getWidth(4)),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)),
        border: Border.all(color: grey300),
      ),
      child: Text(
        content ?? "لا يوجد محتوى لهذا التقرير.",
        textAlign: TextAlign.justify,
        style: TextStyle(fontSize: ScreenSize.getWidth(4), height: 1.6),
      ),
    );
  }

  /// 💡 المرفقات
  Widget _buildAttachments(List<ReportFile> files) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: files
          .map(
            (file) => Padding(
              padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(1)),
              child: ReportMediaWidget(fileUrl: file.filePath),
            ),
          )
          .toList(),
    );
  }
}
