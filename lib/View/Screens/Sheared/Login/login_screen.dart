
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/Screens/Sheared/Login/auth_check_screen.dart';
import 'package:youseuf_app/View/widget/Sheared/login_form.dart';
import 'package:youseuf_app/ViewModel/CustomAppBar.dart';
import '../../../../../services/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:youseuf_app/models/app_role.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AppRole _currentRole = AppRole.specialist;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;
  bool _isLoading = false;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _currentRole =
            _tabController.index == 0 ? AppRole.specialist : AppRole.user;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? red : green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _login() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!isValidEmail(email) || password.isEmpty) {
      _showSnackBar("يرجى إدخال بريد إلكتروني صالح وكلمة مرور", isError: true);
      setState(() => _isLoading = false);
      return;
    }

    final api = ApiService();
    try {
      Map<String, dynamic>? response;
      String objectKey = '';
      String savedUserType = '';

      if (_currentRole == AppRole.specialist) {
        response = await api.loginSpecialist(email, password);
        objectKey = 'specialist';
        savedUserType = 'specialist';
      } else {
        response = await api.loginUser(email, password);
        objectKey = (response != null && response['supervisor'] != null)
            ? 'supervisor'
            : 'user';
        savedUserType = 'supervisor';
      }

      setState(() => _isLoading = false);

      if (response != null && response[objectKey] != null) {
        _showSnackBar('تم تسجيل الدخول بنجاح !', isError: false);
        await _storage.write(key: 'authToken', value: response['token']);
        await _storage.write(
          key: 'user_id',
          value: response[objectKey]['id'].toString(),
        );
        await _storage.write(key: 'user_type', value: savedUserType);
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          final authToken = await api.getToken();
          final currentUserId = await api.getCurrentUserId();
          if (authToken != null && currentUserId != null) {
            await api.sendFcmTokenToBackend(fcmToken, currentUserId, authToken);
          }
        }
        if (context.mounted) {
          final vm = Provider.of<CustomAppBarViewModel>(context, listen: false);
          await vm.refreshData(context);
        }
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthCheckScreen()),
        );
      } else {
        _showSnackBar(response?['message'] ?? 'فشل تسجيل الدخول',
            isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar( '$e', isError: true);
    }
  }

  void _toggleObscure() => setState(() => _isObscured = !_isObscured);

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            // 💡 استخدام نسب مئوية للهوامش
            padding: EdgeInsets.all(ScreenSize.getWidth(6)),
            child: Column(
              children: [
                // العنوان + اللوجو
                SizedBox(
                    height: ScreenSize.getHeight(1)), // 💡 استخدام نسبة مئوية
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    // 💡 استخدام نسب مئوية للأبعاد
                    width: ScreenSize.getWidth(38),
                    height: ScreenSize.getWidth(38),
                  ),
                ),
                SizedBox(
                    height: ScreenSize.getHeight(1.2)), // 💡 استخدام نسبة مئوية
                Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    // 💡 استخدام نسب مئوية لحجم الخط
                    fontSize: ScreenSize.getWidth(6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ScreenSize.getHeight(1.2)),
                // ✅ TabBar للأدوار
                TabBar(
                  controller: _tabController,
                  indicatorColor: blue,
                  labelColor: blue,
                  unselectedLabelColor: black54,
                  // 💡 استخدام نسب مئوية لحجم الخط
                  labelStyle: TextStyle(fontSize: ScreenSize.getWidth(3.8)),
                  unselectedLabelStyle:
                      TextStyle(fontSize: ScreenSize.getWidth(3.8)),
                  tabs: const [
                    Tab(text: 'أخصائي'),
                    Tab(text: 'مشرف'),
                  ],
                ),
                SizedBox(
                    height: ScreenSize.getHeight(1.5)), // 💡 استخدام نسبة مئوية
                // ✳️ بدلاً من TabBarView، نعرض نفس الفورم ويقرأ الدور من _currentRole
                Expanded(
                  child: SingleChildScrollView(
                    child: LoginForm(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      isObscured: _isObscured,
                      isLoading: _isLoading,
                      onLoginPressed: _login,
                      onToggleObscure: _toggleObscure,
                      showForgotPassword: _currentRole == AppRole.specialist,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
