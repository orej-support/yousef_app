import 'package:flutter/material.dart';
import 'package:youseuf_app/View/Screens/Specialist/specialist_forgot_password_screen.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/icons.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isObscured;
  final bool isLoading;
  final Future<void> Function() onLoginPressed;
  final VoidCallback onToggleObscure;

  // ✅ جديدة
  final String primaryButtonText;
  final bool showHeader; // التحكم بإظهار الشعار/العنوان
 final bool showForgotPassword;
  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isObscured,
    required this.isLoading,
    required this.onLoginPressed,
    required this.onToggleObscure,
    this.primaryButtonText = 'تسجيل الدخول',
    this.showHeader = false,
    this.showForgotPassword = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ اعرض الشعار والعنوان فقط إذا طلبت
        if (showHeader) ...[
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
          ),
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'تسجيل الدخول',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ],

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Text(
            'البريد الإلكتروني',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        TextField(
          controller: emailController,
          textAlign: TextAlign.right,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            filled: true,
            fillColor: white,
            hintTextDirection: TextDirection.rtl,
            hintText: 'اكتب البريد الإلكتروني هنا',
            hintStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: grey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Text('كلمة السر', style: TextStyle(fontSize: 16)),
        ),
        Directionality(
          textDirection: TextDirection.rtl,
          child: TextField(
            controller: passwordController,
            textAlign: TextAlign.right,
            obscureText: isObscured,
            decoration: InputDecoration(
              filled: true,
              fillColor: white,
              hintText: 'اكتب كلمة السر هنا',
              hintStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: grey,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                    isObscured ? AppIcons.visibility : Icons.visibility_off),
                onPressed: onToggleObscure,
              ),
            ),
          ),
        ),
if (showForgotPassword)
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SpecialistForgotPasswordScreen()),
              );
            },
            child: const Text('نسيت كلمة المرور؟'),
          ),
        ),

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : () async => await onLoginPressed(),
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              elevation: 5,
              shadowColor: black45,
            ),
            child: isLoading
                ? CircularProgressIndicator(color: white)
                : Text(
                    primaryButtonText,
                    style: TextStyle(fontSize: 18, color: white),
                  ),
          ),
        ),
      ],
    );
  }
}
