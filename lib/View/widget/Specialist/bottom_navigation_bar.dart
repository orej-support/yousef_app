import 'package:flutter/material.dart';
import 'package:youseuf_app/View/Screens/Sheared/chat/conversations_list_page.dart';
import 'package:youseuf_app/View/Screens/Specialist/report_family/FamilyReportsScreen.dart';
import 'package:youseuf_app/View/Screens/Specialist/courses_screen.dart';
import 'package:youseuf_app/View/Screens/Specialist/Profile/profile_screen.dart';
import 'package:youseuf_app/View/Screens/Specialist/Children/view_all_children.dart';
import 'package:youseuf_app/View/widget/Sheared/app_bar.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/icons.dart';

class BottomNavigationWidget extends StatefulWidget {
  final String type;
  const BottomNavigationWidget({Key? key, required this.type})
      : super(key: key);

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  int _currentIndex = 0;
  bool showReportsTab = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _determineSpecialistType();
  }

  void _determineSpecialistType() async {
    debugPrint("Determining specialist type...");
    await Future.delayed(const Duration(milliseconds: 300)); // محاكاة تحميل

    final type = widget.type.trim().toLowerCase();
    debugPrint("Specialist type: $type");
    if (type == "children") {
      // ابناء فقط
      showReportsTab = false;
    } else if (type == "children_and_reports") {
      // ابناء و تقارير
      showReportsTab = true;
    }

    setState(() => isLoading = false);
  }

  Future<void> _onRefresh() async {
    debugPrint("🔄 Refresh triggered on tab: $_currentIndex");
    // هنا تحط API مختلف حسب التبويب الحالي
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<String> titles = [
      'الأبناء',
      if (showReportsTab) 'التقارير',
      'المحادثات',
      'الدورات',
      'حسابي',
    ];

    if (isLoading) {
      return Scaffold(
        appBar: CustomAppBar(
          title: titles[_currentIndex],
        ),
        body: Center(child: CircularProgressIndicator(color: blue)),
      );
    }

    List<Widget> screens = [
      const ViewAllChildrenScreen(),
      if (showReportsTab) const FamilyReportsScreen(),
      const ConversationsListPage(),
      const CoursesScreen(),
      const ProfileScreen(),
    ];

    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(AppIcons.group),
        label: "الأبناء",
      ),
      if (showReportsTab)
        const BottomNavigationBarItem(
          icon: Icon(AppIcons.libraryBooks),
          label: "التقارير",
        ),
      const BottomNavigationBarItem(
        icon: Icon(AppIcons.wechatRounded),
        label: "المحادثات",
      ),
      const BottomNavigationBarItem(
        icon: Icon(AppIcons.menuBook),
        label: "الدورات",
      ),
      const BottomNavigationBarItem(
        icon: Icon(AppIcons.personOutlineRounded),
        label: "حسابي",
      ),
    ];

    return Scaffold(
      body: RefreshIndicator(
        color: blue,
        onRefresh: _onRefresh,
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: blue,
          unselectedItemColor: black54,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          items: items,
        ),
      ),
    );
  }
}
