import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/Screens/Sheared/Login/auth_check_screen.dart';
import 'package:youseuf_app/View/Screens/Sheared/chat/conversations_list_page.dart';
import 'package:youseuf_app/View/Screens/Superviser/Familly_reports.dart';
import 'package:youseuf_app/View/Screens/Superviser/departments_list_screen.dart';
import 'package:youseuf_app/View/Screens/Superviser/specialists_list_screen.dart';
import 'package:youseuf_app/View/widget/Sheared/ListItem.dart';
import 'package:youseuf_app/View/widget/Superviser/BottomNavigationBar.dart';
import 'package:youseuf_app/View/widget/Superviser/app_bar.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/models/branch.dart';
import 'package:youseuf_app/services/api_service.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart';

// تعريف كلاس ApiException
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    return ChangeNotifierProvider(
      create: (_) =>
          DashboardViewModel()..initializeData(context), // 💡 تهيئة ViewModel
      child: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return  Scaffold(
                body: Center(
                    child: CircularProgressIndicator(color: blue)));
          }

          final bool showBottomNav = viewModel.bottomNavItems.length >= 2;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: SuperviseAppBar(
                title: '${viewModel.currentBranchName}',
                branches: viewModel.branches,
                onChangeBranch: (branch) =>
                    viewModel.changeUserBranch(context, branch),
               onRefresh: () => viewModel.refreshData(context),
              ),
              body: RefreshIndicator(
                color: blue,
               onRefresh: () => viewModel.refreshData(context),
                child: _buildBody(viewModel, context),
              ),
              bottomNavigationBar: showBottomNav
                  ? CustomBottomNav(
                      items: viewModel.bottomNavItems,
                      currentIndex: viewModel.selectedIndex,
                      onTap: viewModel.onItemTapped,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(DashboardViewModel viewModel,BuildContext context) {
    if (viewModel.errorMessage.isNotEmpty) {
      return _buildErrorWidget(viewModel,context);
    }
    if (viewModel.selectedIndex == 0) {
      return _buildDashboardContent(viewModel);
    }
    return viewModel.pages[viewModel.selectedIndex];
  }

  Widget _buildErrorWidget(DashboardViewModel viewModel,BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenSize.getWidth(5)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                color: red, size: ScreenSize.getWidth(12)),
            SizedBox(height: ScreenSize.getHeight(2)),
            Text(
              viewModel.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: red, fontSize: ScreenSize.getWidth(4)),
            ),
            SizedBox(height: ScreenSize.getHeight(2)),
            ElevatedButton.icon(
              onPressed: () => viewModel.refreshData(context),
              
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(DashboardViewModel viewModel) {
    final data = viewModel.userDashboardData;
    if (data == null) {
      return  Center(child: CircularProgressIndicator(color: blue));
    }
    return ListView(
      padding: EdgeInsets.all(ScreenSize.getWidth(4)),
      children: [
        SizedBox(height: ScreenSize.getHeight(2)),
        ListItem(
          title: 'إجمالي التقارير',
          value: data['reportsCount']?.toString() ?? '0',
          icon: Icons.description,
        ),
        ListItem(
          title: 'إجمالي الأقسام',
          value: data['departmentsCount']?.toString() ?? '0',
          icon: Icons.business,
        ),
        ListItem(
          title: 'إجمالي الأخصائيين',
          value: data['specialistsCount']?.toString() ?? '0',
          icon: Icons.medical_services,
        ),
        ListItem(
          title: 'إجمالي الأبناء',
          value: data['childrenCount']?.toString() ?? '0',
          icon: Icons.child_care,
        ),
        SizedBox(height: ScreenSize.getHeight(2)),
      ],
    );
  }
}

// 💡 هذا هو الكلاس الجديد DashboardViewModel
class DashboardViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _userDashboardData;
  List<String> _permissions = [];
  int _selectedIndex = 0;
  int _unreadCount = 0;
  List<Branch> _branches = [];
  String? _currentBranchName;
  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _bottomNavItems;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get userDashboardData => _userDashboardData;
  int get selectedIndex => _selectedIndex;
  int get unreadCount => _unreadCount;
  List<Branch> get branches => _branches;
  String? get currentBranchName => _currentBranchName;
  List<Widget> get pages => _pages;
  List<BottomNavigationBarItem> get bottomNavItems => _bottomNavItems;

  DashboardViewModel() {
    _pages = [];
    _bottomNavItems = [];
  }

  Future<void> initializeData(BuildContext context) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    await refreshData(context);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshData(BuildContext context) async {
    try {
      await _fetchUserDashboardData();
      await _loadPermissions();
      _buildNavItemsAndPages();
      await _fetchUnreadCount(context);
      await _fetchBranches();
      await _loadCurrentBranchName();
    } catch (e) {
      _errorMessage = 'فشل تحديث البيانات: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> _loadPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    _permissions = prefs.getStringList('user_permissions') ?? [];
  }

  void _buildNavItemsAndPages() {
    final List<Widget> tempPages = [];
    final List<BottomNavigationBarItem> tempItems = [];

    tempPages.add(_buildDashboardContentPlaceholder());
    tempItems.add(const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'الرئيسية',
    ));

    if (_permissions.contains('المحادثة')) {
      tempPages.add(const ConversationsListPage());
      tempItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.chat),
        label: 'محادثاتي',
      ));
    }
    // if (_permissions.contains('عرض التقارير')) {
    tempPages.add(FamilyReportsScreen());
    tempItems.add(const BottomNavigationBarItem(
      icon: Icon(Icons.description),
      label: 'التقارير',
    ));
    // }
    if (_permissions.contains('عرض الأخصائيين')) {
      tempPages.add(const SpecialistsListScreen());
      tempItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.people_alt),
        label: 'الأخصائيون',
      ));
    }
    if (_permissions.contains('عرض الأقسام')) {
      tempPages.add(const DepartmentsListScreen());
      tempItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.apartment),
        label: 'الأقسام',
      ));
    }

    _pages = tempPages;
    _bottomNavItems = tempItems;
    if (_selectedIndex >= _pages.length) {
      _selectedIndex = 0;
    }
  }

  Widget _buildDashboardContentPlaceholder() {
    return const SizedBox.shrink(); // A placeholder widget
  }

  // Future<void> _loadCurrentBranchName() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   _currentBranchName = prefs.getString('current_branch_name');
  // }
  Future<void> _loadCurrentBranchName() async {
  final prefs = await SharedPreferences.getInstance();
  _currentBranchName = prefs.getString('current_branch_name');
  
  // إذا كان اسم الفرع فارغاً، قم بتعيين أول فرع من القائمة كقيمة افتراضية
  if (_currentBranchName == null && _branches.isNotEmpty) {
    _currentBranchName = _branches.first.name;
    // يمكنك أيضاً حفظه في SharedPreferences ليكون القيمة الافتراضية في المرات القادمة
    await prefs.setString('current_branch_name', _branches.first.name);
  }
}

  Future<void> changeUserBranch(
      BuildContext context, Branch selectedBranch) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>  Center(
        child: CircularProgressIndicator(color: blue),
      ),
    );
    try {
      await _apiService.setUserBranch(branchId: selectedBranch.id);
      Navigator.pop(context);
      _currentBranchName = selectedBranch.name;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_branch_name', selectedBranch.name);
      notifyListeners();
      await refreshData(context);
    } on ApiException catch (e) {
      Navigator.pop(context);
      _errorMessage = 'فشل تغيير الفرع: ${e.message}';
      notifyListeners();
    } catch (e) {
      Navigator.pop(context);
      _errorMessage = 'حدث خطأ غير متوقع: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> _fetchUnreadCount(BuildContext context) async {
    try {
      _unreadCount = await _apiService.fetchUnreadNotificationsCount(context);
    } catch (e) {
      _unreadCount = 0;
    }
  }

  Future<void> _fetchBranches() async {
    try {
      _branches = await _apiService.fetchBranches();
    } on ApiException {
      _branches = [];
    } catch (e) {
      _branches = [];
    }
  }

  Future<void> _fetchUserDashboardData() async {
    try {
      final apiResponse = await _apiService.getUserDashboardStats();
      final permissions = apiResponse?['permissions'];
      if (permissions != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(
            'user_permissions', permissions.cast<String>());
        _permissions = permissions.cast<String>();
      }
      _userDashboardData = apiResponse?['data'];
    } on ApiException catch (e) {
      _errorMessage = 'فشل جلب بيانات لوحة التحكم: ${e.message}';
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع: ${e.toString()}';
    }
  }

  void onItemTapped(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _apiService.logoutUser();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthCheckScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تسجيل الخروج: ${e.toString()}')),
      );
    }
  }
}
