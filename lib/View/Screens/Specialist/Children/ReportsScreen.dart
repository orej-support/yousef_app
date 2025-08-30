
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// الودجت المشتركة للـ Back button
import 'package:youseuf_app/View/widget/Sheared/back_leading.dart';

// الودجات الخاصة بالشاشة
import 'package:youseuf_app/View/widget/Specialist/NotesWidgets.dart';
import 'package:youseuf_app/View/widget/Specialist/ReportsWidget.dart';
import 'package:youseuf_app/View/widget/Specialist/info_widgets.dart';

// شاشة رفع تقرير جديد

// الـ ViewModel المسؤول عن إدارة التبويبات
import 'package:youseuf_app/ViewModel/Children/ReportsViewModel.dart';

// الألوان والأيقونات
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد

// الموديل
import 'package:youseuf_app/models/child.dart';

class ReportsScreen extends StatelessWidget {
  final Child child;

  const ReportsScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    return ChangeNotifierProvider<ReportsViewModel>(
      create: (_) => ReportsViewModel(),
      child: Scaffold(
        appBar: PreferredSize(
          // 💡 استخدام نسبة مئوية لارتفاع الـ AppBar
          preferredSize: Size.fromHeight(ScreenSize.getHeight(11)),
          child: Consumer<ReportsViewModel>(
            builder: (context, viewModel, _) {
              return AppBar(
                backgroundColor: lightpink,
                centerTitle: true,
                leadingWidth: ScreenSize.getWidth(30),
                leading: Row(
                  children: [
                    SizedBox(width: ScreenSize.getWidth(2.5)),
                    const BackLeading(),
                  ],
                ),
                title: Text(
                  viewModel.getTitle(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenSize.getWidth(5), // 💡 استخدام نسبة مئوية
                  ),
                ),
              );
            },
          ),
        ),
        body: Consumer<ReportsViewModel>(
          builder: (context, viewModel, _) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                // ✅ الصندوق في النص
                Padding(
                  // 💡 استخدام نسب مئوية للهوامش
                  padding:
                      EdgeInsets.symmetric(vertical: ScreenSize.getHeight(2)),
                  child: Center(
                    child: Container(
                      width: ScreenSize.getWidth(80),
                      height: ScreenSize.getHeight(9), // 💡 استخدام نسبة مئوية
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenSize.getWidth(4),
                        vertical: ScreenSize.getHeight(1),
                      ),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius:
                            BorderRadius.circular(ScreenSize.getWidth(3)),
                        border: Border.all(color: grey300),
                      ),
                      child: Center(
                        child: Row(
                          textDirection: TextDirection.rtl,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(ScreenSize.getWidth(1.5)),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                'assets/icons/person.png',
                                width: ScreenSize.getWidth(
                                    7), // 💡 استخدام نسبة مئوية
                                height: ScreenSize.getWidth(
                                    7), // 💡 استخدام نسبة مئوية
                              ),
                            ),
                            SizedBox(
                                width: ScreenSize.getWidth(
                                    2)), // 💡 استخدام نسبة مئوية
                            Text(
                              'الابن: ${child.name}',
                              style: TextStyle(
                                fontSize: ScreenSize.getWidth(
                                    4.5), // 💡 استخدام نسبة مئوية
                                fontWeight: FontWeight.bold,
                                color: black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    height: ScreenSize.getHeight(2.5)), // 💡 استخدام نسبة مئوية
                // ✅ أزرار التبويبات
                Padding(
                  // 💡 استخدام نسب مئوية للهوامش
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenSize.getWidth(7.5)),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTabButton(context, 0, "التقارير"),
                      _buildTabButton(context, 1, "ملحوظات"),
                      _buildTabButton(context, 2, "معلومات"),
                    ],
                  ),
                ),
                SizedBox(
                    height: ScreenSize.getHeight(1.8)), // 💡 استخدام نسبة مئوية
                // ✅ عرض محتوى التبويبات
                SizedBox(
                  // 💡 استخدام نسبة مئوية لارتفاع الصندوق
                  height: ScreenSize.getHeight(50),
                  child: IndexedStack(
                    index: viewModel.selectedIndex,
                    children: [
                      ReportsWidget(
                        childrenId: child.id,
                        childrenName: child.name,
                        key: const ValueKey(0),
                      ),
                      NotesWidgets(childrenId: child.id),
                      InfoWidgets(
                        fallbackChild: child,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ✅ دالة إنشاء زر التبويب
  Widget _buildTabButton(BuildContext context, int index, String title) {
    final viewModel = context.watch<ReportsViewModel>();
    final selected = viewModel.selectedIndex == index;

    return InkWell(
      onTap: () => viewModel.changeTab(index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية
              fontWeight: FontWeight.bold,
              color: selected ? blue : Colors.black54,
            ),
          ),
          SizedBox(height: ScreenSize.getHeight(0.8)), // 💡 استخدام نسبة مئوية
          Container(
            width: ScreenSize.getWidth(23), // 💡 استخدام نسبة مئوية
            height: ScreenSize.getHeight(0.4), // 💡 استخدام نسبة مئوية
            decoration: BoxDecoration(
              color: selected ? blue : Colors.transparent,
              borderRadius: BorderRadius.circular(ScreenSize.getWidth(0.5)),
            ),
          ),
        ],
      ),
    );
  }
}
