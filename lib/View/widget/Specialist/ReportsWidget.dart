
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/Screens/Specialist/Children/report_details_view.dart';
import 'package:youseuf_app/View/Screens/Specialist/Children/upload_report_screen.dart';
import 'package:youseuf_app/ViewModel/Children/ReportsViewModel.dart';
import 'package:youseuf_app/ViewModel/Children/report_details_view_model.dart';
import 'package:youseuf_app/core/utils/icons.dart';
import 'package:youseuf_app/models/report_model.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';

class ReportsWidget extends StatefulWidget {
  final String childrenId;
  final String childrenName;

  const ReportsWidget({
    super.key,
    required this.childrenId,
    required this.childrenName,
  });

  @override
  State<ReportsWidget> createState() => _ReportsWidgetState();
}

class _ReportsWidgetState extends State<ReportsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportsViewModel>(context, listen: false)
          .fetchReportsForChild( widget.childrenId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ReportsViewModel>(context);

    if (viewModel.isLoading) {
      return  Center(child: CircularProgressIndicator(color: blue));
    }

    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }

    final List<ReportModel> reports = viewModel.reports;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UploadReportScreen(
                      childrenId: widget.childrenId,
                    ),
                  ),
                ).then((didUpload) {
                  if (didUpload == true) {
                    viewModel.fetchReportsForChild( widget.childrenId);
                  }
                });
              },
              icon: const Icon(AppIcons.add),
              label: const Text("إضافة تقرير"),
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: reports.isEmpty
              ? const Center(child: Text("لا توجد تقارير متاحة."))
              : Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return Card(
                        color: white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // الجزء الأيمن (التاريخ والوقت)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    intl.DateFormat('d-M-yyyy | h:mm a', 'en')
                                        .format(report.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: grey600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    report.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text('الحالة:'),
                                      const SizedBox(width: 4),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: report.status == 'ممتازة'
                                              ? Colors.green
                                              : report.status == 'جيدة'
                                                  ? Colors.yellow
                                                  : Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        report.status,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              // الجزء الأيسر (زر التفاصيل)
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: BorderSide(color: blue),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChangeNotifierProvider(
                                        create: (_) => ReportDetailsViewModel(
                                          report: report,
                                          childName: widget.childrenName,
                                        ),
                                        child: const ReportDetailsView(),
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'التفاصيل',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
