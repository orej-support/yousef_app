
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/Screens/Specialist/Children/ReportsScreen.dart';
import 'package:youseuf_app/View/widget/Sheared/app_bar.dart';
import 'package:youseuf_app/ViewModel/Children/ViewAllChildrenViewModel.dart';
import 'package:youseuf_app/core/utils/icons.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد
import '../../../../core/theme/app_colors.dart';

class ViewAllChildrenScreen extends StatefulWidget {
  const ViewAllChildrenScreen({super.key});

  @override
  State<ViewAllChildrenScreen> createState() => _ViewAllChildrenScreenState();
}

class _ViewAllChildrenScreenState extends State<ViewAllChildrenScreen> {
  late ViewAllChildrenViewModel vm;

  bool _isFirstRun = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstRun) {
      vm = ViewAllChildrenViewModel();
      vm.fetchChildren();
      _isFirstRun = false;
    }
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    return ChangeNotifierProvider<ViewAllChildrenViewModel>.value(
      value: vm,
      child: Consumer<ViewAllChildrenViewModel>(
        builder: (context, vm, _) {
          final title = "عدد الأبناء: ${vm.filteredchildren.length}";

          return Scaffold(
            appBar: const CustomAppBar(title: 'الأبناء'),
            body: Column(
              textDirection: TextDirection.rtl,
              children: [
                SizedBox(height: ScreenSize.getHeight(1.8)), // 💡 استخدام نسبة مئوية
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية
                  ),
                ),
                SizedBox(height: ScreenSize.getHeight(1.8)), // 💡 استخدام نسبة مئوية
                Expanded(
                  child: vm.isLoading
                      ?  Center(child: CircularProgressIndicator(color: blue))
                      : vm.filteredchildren.isEmpty
                          ? Center(
                              child: Text(
                                "لا يوجد أبناء تحت إشرافك حالياً",
                                style: TextStyle(
                                  fontSize: ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: vm.filteredchildren.length,
                              itemBuilder: (context, index) {
                                final children = vm.filteredchildren[index];
                                return Padding(
                                  key: ValueKey(children.id),
                                  // 💡 استخدام نسب مئوية للهوامش
                                  padding: EdgeInsets.symmetric(
                                      horizontal: ScreenSize.getWidth(5.5)),
                                  child: Container(
                                    // 💡 استخدام نسبة مئوية للهامش
                                    margin: EdgeInsets.only(bottom: ScreenSize.getHeight(1.2)),
                                    // 💡 استخدام نسب مئوية للهوامش
                                    padding: EdgeInsets.all(ScreenSize.getWidth(3)),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      // 💡 استخدام نسبة مئوية لنصف القطر
                                      borderRadius: BorderRadius.circular(ScreenSize.getWidth(2.5)),
                                    ),
                                    child: Row(
                                      textDirection: TextDirection.rtl,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          textDirection: TextDirection.rtl,
                                          children: [
                                            Image.asset(
                                              'assets/icons/person.png',
                                              width: ScreenSize.getWidth(7),
                                              height: ScreenSize.getWidth(7),
                                            ),
                                            SizedBox(width: ScreenSize.getWidth(2.5)), // 💡 استخدام نسبة مئوية
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "الابن: ",
                                                    style: TextStyle(
                                                      fontSize: ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: children.name,
                                                    style: TextStyle(
                                                      color: blue,
                                                      fontSize: ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return ReportsScreen(
                                                      child: children);
                                                },
                                              ),
                                            );
                                          },
                                          child: Row(
                                            textDirection: TextDirection.rtl,
                                            children: [
                                              Text(
                                                "التقارير",
                                                style: TextStyle(
                                                  color: blue,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية
                                                ),
                                              ),
                                              Icon(
                                                AppIcons.chevronLeft,
                                                color: blue,
                                                size: ScreenSize.getWidth(6), // 💡 استخدام نسبة مئوية
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}