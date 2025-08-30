
import 'package:flutter/material.dart';
import 'package:youseuf_app/View/Screens/Sheared/Login/auth_check_screen.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد
import 'package:youseuf_app/services/UpdateChecker.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool canProceed = await UpdateChecker().checkForUpdate(context);
      if (canProceed && mounted) {
        await Future.delayed(const Duration(seconds: 1));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthCheckScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    // 💡 تحديد المتغيرات بناءً على نسب مئوية من حجم الشاشة
    final circleTopPosition = ScreenSize.getHeight(6);
    final circleRightPosition = ScreenSize.getWidth(-33);
    final circleBottomPosition = ScreenSize.getHeight(8.5);
    final circleLeftPosition = ScreenSize.getWidth(-37);
    final circleRadius = ScreenSize.getWidth(25);

    return Scaffold(
      backgroundColor: white,
      body: Stack(
        children: [
          Positioned(
            // 💡 استخدام المتغيرات المحدثة
            top: circleTopPosition,
            right: circleRightPosition,
            child: CircleAvatar(
              radius: circleRadius,
              backgroundColor: blue,
            ),
          ),
          Positioned(
            // 💡 استخدام المتغيرات المحدثة
            bottom: circleBottomPosition,
            left: circleLeftPosition,
            child: CircleAvatar(
              radius: circleRadius,
              backgroundColor: blue,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: ScreenSize.getWidth(80),
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  height: ScreenSize.getHeight(10),
                ),
                CircularProgressIndicator(
                  color: blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
