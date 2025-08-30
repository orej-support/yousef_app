
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/Screens/Specialist/report_family/AddFamilyReportPage.dart';
import 'package:youseuf_app/View/Screens/Specialist/report_family/family_report_details.dart';
import 'package:youseuf_app/View/widget/Sheared/app_bar.dart';
import 'package:youseuf_app/ViewModel/Family/FamilyReportsViewModel.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد

class FamilyReportsScreen extends StatelessWidget {
  const FamilyReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    return ChangeNotifierProvider(
      create: (_) => FamilyReportsViewModel()..loadReports(),
      child: Scaffold(
        appBar: const CustomAppBar(title: "التقارير"),
        body: Consumer<FamilyReportsViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: blue),
              );
            }

            return Column(
              children: [
                Padding(
                  // 💡 استخدام نسب مئوية للهوامش
                  padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(1.2)),
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddFamilyReportPage(
                            onReportUploaded: () => viewModel.loadReports(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      // 💡 استخدام نسب مئوية للهوامش
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenSize.getWidth(5),
                        vertical: ScreenSize.getHeight(1.5),
                      ),
                      shape: RoundedRectangleBorder(
                        // 💡 استخدام نسبة مئوية لنصف القطر
                        borderRadius: BorderRadius.circular(ScreenSize.getWidth(12.5)),
                      ),
                    ),
                    child: Text(
                      ' + رفع تقرير جديد',
                      style: TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenSize.getWidth(3.5), // 💡 استخدام نسبة مئوية
                      ),
                    ),
                  ),
                ),
                viewModel.reports.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Text(
                            "لا توجد تقارير بعد",
                            style: TextStyle(fontSize: ScreenSize.getWidth(4)), // 💡 استخدام نسبة مئوية
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: viewModel.reports.length,
                          itemBuilder: (context, index) {
                            final report = viewModel.reports[index];
                            return Container(
                              // 💡 استخدام نسب مئوية للهوامش
                              margin: EdgeInsets.symmetric(
                                horizontal: ScreenSize.getWidth(3.5),
                                vertical: ScreenSize.getHeight(0.8),
                              ),
                              // 💡 استخدام نسب مئوية للهوامش
                              padding: EdgeInsets.all(ScreenSize.getWidth(4)),
                              decoration: BoxDecoration(
                                color: white,
                                // 💡 استخدام نسبة مئوية لنصف القطر
                                borderRadius: BorderRadius.circular(ScreenSize.getWidth(4)),
                                border: Border.all(color: grey300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        viewModel.formatDateTime(report["created_at"]),
                                        style: TextStyle(
                                          color: black54,
                                          fontSize: ScreenSize.getWidth(3.5), // 💡 استخدام نسبة مئوية
                                        ),
                                      ),
                                      Text(
                                        report["title"],
                                        style: TextStyle(
                                          fontSize: ScreenSize.getWidth(3.8), // 💡 استخدام نسبة مئوية
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: ScreenSize.getHeight(1.2)), // 💡 استخدام نسبة مئوية
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => FamilyReportDetails(
                                              report: report,
                                            ),
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          // 💡 استخدام نسبة مئوية لنصف القطر
                                          borderRadius: BorderRadius.circular(ScreenSize.getWidth(2.5)),
                                        ),
                                        side: BorderSide(color: blue),
                                      ),
                                      child: Text(
                                        "التفاصيل",
                                        style: TextStyle(fontSize: ScreenSize.getWidth(3.5)), // 💡 استخدام نسبة مئوية
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
