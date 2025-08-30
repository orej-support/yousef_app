
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/Screens/Superviser/FamilyReportDetails.dart';
import 'package:youseuf_app/ViewModel/Superviser/FamilyReportsViewModel.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart';
import 'package:youseuf_app/models/report_family.dart';
import 'package:youseuf_app/services/api_service.dart';

 // 👈 Ensure FamilyReport is imported

class FamilyReportsScreen extends StatelessWidget { // 💡 تم تغيير اسم الكلاس
  const FamilyReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    return ChangeNotifierProvider(
      create: (_) => FamilyReportsViewModel(apiService: ApiService())
        ..fetchFamilyReports(),
      child: Scaffold(
        body: Consumer<FamilyReportsViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return  Center(child: CircularProgressIndicator(color: blue));
            }

            if (viewModel.errorMessage != null) {
              return _buildErrorWidget(viewModel);
            }

            if (viewModel.reports.isEmpty) {
              return _buildEmptyWidget();
            }

            return _buildReportsList(viewModel);
          },
        ),
      ),
    );
  }
  
  // 💡 دالة لبناء واجهة الخطأ مع زر إعادة المحاولة
  Widget _buildErrorWidget(FamilyReportsViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: red, size: ScreenSize.getWidth(12)),
          SizedBox(height: ScreenSize.getHeight(2)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenSize.getWidth(5)),
            child: Text(
              "حدث خطأ: ${viewModel.errorMessage}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: ScreenSize.getWidth(4), color: red),
            ),
          ),
          SizedBox(height: ScreenSize.getHeight(2)),
          ElevatedButton.icon(
            onPressed: viewModel.fetchFamilyReports,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  // 💡 دالة لبناء واجهة عدم وجود بيانات
  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, color: grey, size: ScreenSize.getWidth(12)),
          SizedBox(height: ScreenSize.getHeight(2)),
          Text(
            "لا توجد تقارير عائلية لعرضها.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: ScreenSize.getWidth(5), color: darkgrey),
          ),
        ],
      ),
    );
  }

  // 💡 دالة لبناء قائمة التقارير
  Widget _buildReportsList(FamilyReportsViewModel viewModel) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(1)),
        itemCount: viewModel.reports.length,
        itemBuilder: (context, index) {
          final report = viewModel.reports[index];
          return _buildReportItem(context, report, viewModel);
        },
      ),
    );
  }
  
  // 💡 دالة لبناء عنصر التقرير الواحد
  Widget _buildReportItem(BuildContext context, ReportFamily report, FamilyReportsViewModel viewModel) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: ScreenSize.getWidth(3), vertical: ScreenSize.getHeight(1)),
      padding: EdgeInsets.all(ScreenSize.getWidth(4)),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(ScreenSize.getWidth(4)),
        border: Border.all(color: grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                report.title ?? "بدون عنوان",
                style: TextStyle(
                  fontSize: ScreenSize.getWidth(4),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                viewModel.formatDateTime(report.createdAt.toString()),
                style: TextStyle(
                  color: black54,
                  fontSize: ScreenSize.getWidth(3.5),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenSize.getHeight(1.5)),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportDetailsScreen(report: report),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ScreenSize.getWidth(2)),
                ),
                side: BorderSide(color: blue),
              ),
              child: Text(
                "التفاصيل",
                style: TextStyle(fontSize: ScreenSize.getWidth(3.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}