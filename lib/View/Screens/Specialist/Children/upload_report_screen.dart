
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/widget/Sheared/back_leading.dart';
import 'package:youseuf_app/ViewModel/children/upload_report_view_model.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد

class UploadReportScreen extends StatelessWidget {
  final String childrenId;
  const UploadReportScreen({super.key, required this.childrenId});

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    return ChangeNotifierProvider(
      create: (_) => UploadReportViewModel(),
      child: Consumer<UploadReportViewModel>(
        builder: (context, vm, _) => Scaffold(
          appBar: AppBar(
            backgroundColor: lightpink,
            automaticallyImplyLeading: false,
            centerTitle: true,
            // 💡 استخدام نسبة مئوية لارتفاع الـ AppBar
            toolbarHeight: ScreenSize.getHeight(10),
            // 💡 استخدام نسبة مئوية لعرض الـ Leading
            leadingWidth: ScreenSize.getWidth(30),
            elevation: 0,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    width: ScreenSize.getWidth(2.5)), // 💡 استخدام نسبة مئوية
                const BackLeading(),
              ],
            ),
            title: Text(
              'رفع التقرير',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize:
                    ScreenSize.getWidth(5), // 💡 استخدام نسبة مئوية لحجم الخط
              ),
            ),
          ),
          body: vm.isLoading
              ?  Center(child: CircularProgressIndicator(color: blue))
              : Padding(
                  // 💡 استخدام نسب مئوية للهوامش
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenSize.getWidth(6),
                    vertical: ScreenSize.getHeight(2),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildTextField(vm.titleController, 'العنوان'),
                        SizedBox(
                            height: ScreenSize.getHeight(
                                1.8)), // 💡 استخدام نسبة مئوية
                        DropdownButtonFormField<String>(
                          value: vm.selectedStatus,
                          items: ["ممتازة", "جيدة", "سيئة"].map((status) {
                            return DropdownMenuItem(
                                value: status, child: Text(status));
                          }).toList(),
                          onChanged: (value) {
                            vm.selectedStatus = value;
                            vm.notifyListeners();
                          },
                          decoration: inputDecoration('الحالة'),
                        ),
                        SizedBox(
                            height: ScreenSize.getHeight(
                                1.8)), // 💡 استخدام نسبة مئوية
                        buildTextField(
                          vm.descriptionController,
                          'اكتب التقرير هنا ...',
                          maxLines: 3,
                        ),
                        SizedBox(
                            height: ScreenSize.getHeight(
                                1.2)), // 💡 استخدام نسبة مئوية
                        DropdownButtonFormField<String>(
                          value: vm.selectedMediaType,
                          items: ["صورة", "فيديو", "PDF"].map((type) {
                            return DropdownMenuItem(
                                value: type, child: Text(type));
                          }).toList(),
                          onChanged: (value) async {
                            vm.selectedMediaType = value;
                            await vm.pickMedia(context, value);
                          },
                          decoration: inputDecoration('اختر نوع الملف'),
                        ),
                        if (vm.selectedFiles.isNotEmpty)
                          Padding(
                            padding:
                                EdgeInsets.only(top: ScreenSize.getHeight(1.2)),
                            child: Text(
                              "تم اختيار الملفات: ${vm.selectedFileNames.join(', ')}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        SizedBox(
                            height: ScreenSize.getHeight(
                                2.5)), // 💡 استخدام نسبة مئوية
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: vm.selectedFiles.isNotEmpty
                                ? () async {
                                    await vm.uploadReport(context, childrenId);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blue,
                              // 💡 استخدام نسبة مئوية للهوامش
                              padding: EdgeInsets.symmetric(
                                  vertical: ScreenSize.getHeight(1.8)),
                              shape: RoundedRectangleBorder(
                                // 💡 استخدام نسبة مئوية لنصف القطر
                                borderRadius: BorderRadius.circular(
                                    ScreenSize.getWidth(3)),
                              ),
                            ),
                            child: Text(
                              "رفع التقرير",
                              style: TextStyle(
                                // 💡 استخدام نسبة مئوية لحجم الخط
                                fontSize: ScreenSize.getWidth(4.5),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // 💡 تم تحديث الدوال المساعدة لاستخدام النسب المئوية
  TextField buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      decoration: inputDecoration(hint),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        // 💡 استخدام نسبة مئوية لحجم الخط
        fontSize: ScreenSize.getWidth(3.2),
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade500,
      ),
      border: OutlineInputBorder(
        // 💡 استخدام نسبة مئوية لنصف القطر
        borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)),
      ),
    );
  }
}
