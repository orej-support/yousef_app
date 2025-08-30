
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import '../../../../../services/api_service.dart';
import 'package:youseuf_app/View/Screens/Sheared/Login/login_screen.dart';
import 'package:youseuf_app/View/Screens/Specialist/main_screen.dart';
import 'package:youseuf_app/View/Screens/Superviser/user_dashboard_screen.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد
import '../../../../../services/pusher_service.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatusAndNavigate();
  }

  Future<void> _checkAuthStatusAndNavigate() async {
    debugPrint("🚀 بدء التحقق من حالة الدخول...");
    await Future.delayed(const Duration(milliseconds: 400));
    final token = await _apiService.getToken();
    final userType = await _apiService.getUserType();

    debugPrint("🔑 Token: $token");
    debugPrint("👤 UserType: $userType");

    if (!mounted) return;

    if (token != null && userType != null) {
      try {
        final pusherService =
            Provider.of<PusherService>(context, listen: false);
        await pusherService.initPusher();
        debugPrint('✅ PusherService initialized from AuthCheckScreen.');
      } catch (e) {
        debugPrint('❌ خطأ تهيئة Pusher: $e');
      }

      if (userType == 'specialist') {
        debugPrint("🧪 الدخول كـ Specialist");
        try {
          final specialist = await _apiService.getSpecialistProfile();
          debugPrint("📄 نوع الأخصائي: ${specialist?.type}");
          if (!mounted) return;
          if (specialist != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MainScreen(type: specialist.type ?? ''),
              ),
            );
          } else {
            _goToRoleChooser();
          }
        } catch (e) {
          debugPrint('❌ خطأ أثناء جلب بيانات الأخصائي: $e');
          _goToRoleChooser();
        }
      } else if (userType == 'user') {
        debugPrint("🧪 الدخول كمشرف");
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserDashboardScreen()),
        );
      } else {
        debugPrint("❌ نوع مستخدم غير مدعوم: $userType");
        _goToRoleChooser();
      }
    } else {
      debugPrint("❌ لا يوجد رمز دخول أو نوع مستخدم");
      _goToRoleChooser();
    }
  }

  void _goToRoleChooser() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             CircularProgressIndicator(color: blue),
          
            SizedBox(height: ScreenSize.getHeight(2.5)),
          ],
        ),
      ),
    );
  }
}
