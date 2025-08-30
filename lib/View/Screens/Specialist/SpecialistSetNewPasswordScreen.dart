
import 'package:flutter/material.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد
import '../../../../services/api_service.dart';

class SpecialistSetNewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const SpecialistSetNewPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<SpecialistSetNewPasswordScreen> createState() => _SpecialistSetNewPasswordScreenState();
}

class _SpecialistSetNewPasswordScreenState extends State<SpecialistSetNewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _obscure1 = true, _obscure2 = true;

  void _submitResetPassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar("كلمة المرور غير متطابقة", isError: true);
      return;
    }
    if (_newPasswordController.text.length < 8) {
      _showSnackBar("كلمة المرور يجب أن لا تقل عن 8 أحرف", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final ApiResponse response = await _apiService.resetPasswordSpecialist(
        context,
        widget.email,
        widget.otp,
        _newPasswordController.text,
        _confirmPasswordController.text,
      );
      _showSnackBar(response.message, isError: !response.status);

      if (response.status) {
        // العودة إلى شاشة تسجيل الدخول
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعيين كلمة مرور جديدة'),
        centerTitle: true,
      ),
      body: Padding(
        // 💡 استخدام نسب مئوية للهوامش
        padding: EdgeInsets.all(ScreenSize.getWidth(6)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "تعيين كلمة مرور جديدة",
                style: TextStyle(
                  fontSize: ScreenSize.getWidth(5.5), // 💡 استخدام نسبة مئوية
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ScreenSize.getHeight(1.2)), // 💡 استخدام نسبة مئوية
              Text(
                "أدخل كلمة مرور جديدة لحسابك (${widget.email})",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ScreenSize.getHeight(4)), // 💡 استخدام نسبة مئوية
              TextField(
                controller: _newPasswordController,
                obscureText: _obscure1,
                decoration: InputDecoration(
                  hintText: "كلمة المرور الجديدة",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)), // 💡 استخدام نسبة مئوية
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure1 ? Icons.visibility : Icons.visibility_off,
                      size: ScreenSize.getWidth(5), // 💡 استخدام نسبة مئوية
                    ),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                ),
                keyboardType: TextInputType.visiblePassword,
              ),
              SizedBox(height: ScreenSize.getHeight(2.5)), // 💡 استخدام نسبة مئوية
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscure2,
                decoration: InputDecoration(
                  hintText: "تأكيد كلمة المرور",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)), // 💡 استخدام نسبة مئوية
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure2 ? Icons.visibility : Icons.visibility_off,
                      size: ScreenSize.getWidth(5), // 💡 استخدام نسبة مئوية
                    ),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
                keyboardType: TextInputType.visiblePassword,
              ),
              SizedBox(height: ScreenSize.getHeight(4)), // 💡 استخدام نسبة مئوية
              _isLoading
                  ?  Center(child: CircularProgressIndicator(color: blue))
                  : ElevatedButton(
                      onPressed: _submitResetPassword,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, ScreenSize.getHeight(6)), // 💡 استخدام نسبة مئوية
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)), // 💡 استخدام نسبة مئوية
                        ),
                      ),
                      child: Text(
                        "تأكيد",
                        style: TextStyle(fontSize: ScreenSize.getWidth(4.5)), // 💡 استخدام نسبة مئوية
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}