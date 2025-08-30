
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/widget/Sheared/back_leading.dart';
import 'package:youseuf_app/ViewModel/Family/AddFamilyReportViewModel.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/icons.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد

class AddFamilyReportPage extends StatelessWidget {
  final VoidCallback onReportUploaded;

  const AddFamilyReportPage({super.key, required this.onReportUploaded});

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    return ChangeNotifierProvider(
      create: (_) => AddFamilyReportViewModel(),
      child: const _AddFamilyReportBody(),
    );
  }
}

class _AddFamilyReportBody extends StatelessWidget {
  const _AddFamilyReportBody();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AddFamilyReportViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightpink,
        automaticallyImplyLeading: false,
        centerTitle: true,
        toolbarHeight: ScreenSize.getHeight(10), // 💡 استخدام نسبة مئوية
        leadingWidth: ScreenSize.getWidth(30), // 💡 استخدام نسبة مئوية
        elevation: 0,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: ScreenSize.getWidth(2.5)), // 💡 استخدام نسبة مئوية
            const BackLeading(),
          ],
        ),
        title: Text(
          'رفع تقرير',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ScreenSize.getWidth(5), // 💡 استخدام نسبة مئوية
          ),
        ),
      ),
      body: vm.isUploading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   CircularProgressIndicator(color: blue),
                  SizedBox(height: ScreenSize.getHeight(1)), // 💡 استخدام نسبة مئوية
                  Text(
                    "جارٍ رفع التقرير...",
                    style: TextStyle(fontSize: ScreenSize.getWidth(4)), // 💡 استخدام نسبة مئوية
                  ),
                ],
              ),
            )
          : Padding(
              // 💡 استخدام نسب مئوية للهوامش
              padding: EdgeInsets.symmetric(
                horizontal: ScreenSize.getWidth(6.5),
                vertical: ScreenSize.getHeight(1.8),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    buildTextField(vm.titleController, 'العنوان'),
                    SizedBox(height: ScreenSize.getHeight(1.8)), // 💡 استخدام نسبة مئوية
                    DropdownButtonFormField<String>(
                      value: vm.selectedCategory,
                      items: const [
                        DropdownMenuItem(
                            value: 'لقاء تدريبي', child: Text('لقاء تدريبي')),
                        DropdownMenuItem(
                            value: 'جلسة جمعية', child: Text('جلسة جمعية')),
                        DropdownMenuItem(value: 'استشارة', child: Text('استشارة')),
                        DropdownMenuItem(value: 'أخرى', child: Text('أخرى')),
                      ],
                      onChanged: vm.setCategory,
                      decoration: inputDecoration('التصنيف'),
                    ),
                    SizedBox(height: ScreenSize.getHeight(1.8)), // 💡 استخدام نسبة مئوية
                    buildTextField(vm.descController, 'تفاصيل التقرير',
                        maxLines: 4),
                    SizedBox(height: ScreenSize.getHeight(1.8)), // 💡 استخدام نسبة مئوية
                    OutlinedButton(
                      onPressed: () async {
                        await vm.pickFiles(context);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          // 💡 استخدام نسبة مئوية لنصف القطر
                          borderRadius: BorderRadius.circular(ScreenSize.getWidth(2.5)),
                        ),
                        side: BorderSide(color: blue),
                      ),
                      child: Text(
                        "إرفاق ملفات",
                        style: TextStyle(fontSize: ScreenSize.getWidth(3.5)), // 💡 استخدام نسبة مئوية
                      ),
                    ),
                    // عرض الملفات المرفقة
                    if (vm.selectedFiles.isNotEmpty) ...[
                      SizedBox(height: ScreenSize.getHeight(1.2)), // 💡 استخدام نسبة مئوية
                      Text(
                        'الملفات المرفقة:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية
                        ),
                      ),
                      SizedBox(height: ScreenSize.getHeight(0.5)), // 💡 استخدام نسبة مئوية
                      ...vm.selectedFiles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final file = entry.value;
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                file.path.split('/').last,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: ScreenSize.getWidth(3.5)), // 💡 استخدام نسبة مئوية
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                AppIcons.close,
                                color: red,
                                size: ScreenSize.getWidth(5), // 💡 استخدام نسبة مئوية
                              ),
                              onPressed: () => vm.removeFile(index),
                            )
                          ],
                        );
                      }).toList(),
                    ],
                    SizedBox(height: ScreenSize.getHeight(4)), // 💡 استخدام نسبة مئوية
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final success = await vm.uploadReport(context);
                          if (success) {
                            final parentWidget = context.findAncestorWidgetOfExactType<AddFamilyReportPage>();
                            if (parentWidget != null) {
                              parentWidget.onReportUploaded();
                            }
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue,
                          // 💡 استخدام نسبة مئوية للهوامش
                          padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(1.8)),
                          shape: RoundedRectangleBorder(
                            // 💡 استخدام نسبة مئوية لنصف القطر
                            borderRadius: BorderRadius.circular(ScreenSize.getWidth(3.5)),
                          ),
                        ),
                        child: Text(
                          "رفع التقرير",
                          style: TextStyle(
                            fontSize: ScreenSize.getWidth(4.5), // 💡 استخدام نسبة مئوية
                            color: white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // 💡 تم تحديث الدوال المساعدة لاستخدام النسب المئوية
  TextField buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
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
        fontSize: ScreenSize.getWidth(3.5), // 💡 استخدام نسبة مئوية
        fontWeight: FontWeight.bold,
        color: grey500,
      ),
      border: OutlineInputBorder(
          // 💡 استخدام نسبة مئوية لنصف القطر
          borderRadius: BorderRadius.circular(ScreenSize.getWidth(3.5))),
    );
  }
}