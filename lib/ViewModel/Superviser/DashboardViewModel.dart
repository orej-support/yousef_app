import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youseuf_app/View/Screens/Sheared/Login/auth_check_screen.dart';
import 'package:youseuf_app/View/Screens/Sheared/chat/conversations_list_page.dart';
import 'package:youseuf_app/View/Screens/Superviser/Familly_reports.dart';
import 'package:youseuf_app/View/Screens/Superviser/departments_list_screen.dart';
import 'package:youseuf_app/View/Screens/Superviser/specialists_list_screen.dart';
import 'package:youseuf_app/models/branch.dart';
import 'package:youseuf_app/services/api_service.dart';

/// تعريف استثناء مخصص للتعامل مع أخطاء الـ API
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// 💡 ViewModel لإدارة بيانات وعرض لوحة التحكم
class DashboardViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _userDashboardData;
  List<String> _permissions = [];
  String _userType = '';
  int _selectedIndex = 0;
  int _unreadCount = 0;
  List<Branch> _branches = [];
  String? _currentBranchName;

  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _bottomNavItems;

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get userDashboardData => _userDashboardData;
  int get selectedIndex => _selectedIndex;
  int get unreadCount => _unreadCount;
  List<Branch> get branches => _branches;
  String? get currentBranchName => _currentBranchName;
  List<Widget> get pages => _pages;
  List<BottomNavigationBarItem> get bottomNavItems => _bottomNavItems;
  String get userType => _userType;

  DashboardViewModel() {
    _pages = [];
    _bottomNavItems = [];
  }

  /// تهيئة البيانات عند أول تشغيل
  Future<void> initializeData(BuildContext context) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    await refreshData( context);

    _isLoading = false;
    notifyListeners();
  }

  /// إعادة تحميل البيانات (تحديث)
  Future<void> refreshData(BuildContext context) async {
    try {
      await _fetchUserDashboardData();
      await _loadPermissions();
      await _loadUserType();
      _buildNavItemsAndPages();
      await fetchUnreadCount(context);
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

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    _userType = prefs.getString('user_type') ?? '';
  }

  /// بناء الصفحات و عناصر الـ BottomNavigationBar حسب الصلاحيات
  void _buildNavItemsAndPages() {
    final List<Widget> tempPages = [];
    final List<BottomNavigationBarItem> tempItems = [];

    // الرئيسية (ثابتة)
    tempPages.add(const SizedBox.shrink());
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
    if (_permissions.contains('عرض التقارير')) {
      tempPages.add(FamilyReportsScreen());
      tempItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.description),
        label: 'التقارير',
      ));
    }
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

    // لو المؤشر أكبر من عدد الصفحات نرجعه للصفر
    if (_selectedIndex >= _pages.length) {
      _selectedIndex = 0;
    }
  }

  Future<void> _loadCurrentBranchName() async {
    final prefs = await SharedPreferences.getInstance();
    _currentBranchName = prefs.getString('current_branch_name');
    if (_currentBranchName == null && _branches.isNotEmpty) {
      _currentBranchName = _branches.first.name;
      await prefs.setString('current_branch_name', _branches.first.name);
    }
  }

  /// تغيير الفرع
  Future<void> changeUserBranch(BuildContext context, Branch selectedBranch) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      ),
    );
    try {
      await _apiService.setUserBranch(branchId: selectedBranch.id);

      if (context.mounted) Navigator.pop(context);

      _currentBranchName = selectedBranch.name;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_branch_name', selectedBranch.name);

      notifyListeners();
      await refreshData(context);
    } on ApiException catch (e) {
      if (context.mounted) Navigator.pop(context);
      _errorMessage = 'فشل تغيير الفرع: ${e.message}';
      notifyListeners();
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      _errorMessage = 'حدث خطأ غير متوقع: ${e.toString()}';
      notifyListeners();
    }
  }

  /// جلب عدد الإشعارات الغير مقروءة
  Future<void> fetchUnreadCount(BuildContext context) async {
    try {
      _unreadCount = await _apiService.fetchUnreadNotificationsCount(context);
      notifyListeners();
    } catch (e) {
      _unreadCount = 0;
    }
  }

  /// جلب الفروع
  Future<void> _fetchBranches() async {
    try {
      _branches = await _apiService.fetchBranches();
    } on ApiException {
      _branches = [];
    } catch (e) {
      _branches = [];
    }
  }

  /// جلب بيانات لوحة التحكم من الـ API
  Future<void> _fetchUserDashboardData() async {
    try {
      final apiResponse = await _apiService.getUserDashboardStats();
      final permissions = apiResponse?['permissions'];
      final userType = apiResponse?['userType'];

      if (permissions != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('user_permissions', permissions.cast<String>());
        _permissions = permissions.cast<String>();
      }

      if (userType != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_type', userType);
        _userType = userType;
      }

      _userDashboardData = apiResponse?['data'];
    } on ApiException catch (e) {
      _errorMessage = 'فشل جلب بيانات لوحة التحكم: ${e.message}';
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع: ${e.toString()}';
    }
  }

  /// عند الضغط على عنصر في الـ BottomNavigationBar
  void onItemTapped(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  /// تسجيل الخروج
  Future<void> logout(BuildContext context) async {
    try {
      await _apiService.logoutUser();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthCheckScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تسجيل الخروج: ${e.toString()}')),
        );
      }
    }
  }
}
