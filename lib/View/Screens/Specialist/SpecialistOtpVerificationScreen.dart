
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:youseuf_app/View/Screens/Specialist/SpecialistSetNewPasswordScreen.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد
import '../../../../services/api_service.dart';

class SpecialistOtpVerificationScreen extends StatefulWidget {
  final String email;
  const SpecialistOtpVerificationScreen({super.key, required this.email});

  @override
  State<SpecialistOtpVerificationScreen> createState() => _SpecialistOtpVerificationScreenState();
}

class _SpecialistOtpVerificationScreenState extends State<SpecialistOtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _verifyOtp() async {
    if (_otpController.text.length != 6) {
      _showSnackBar("الرجاء إدخال رمز مكون من 6 أرقام", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ApiResponse response = await _apiService.verifyOtpSpecialist(context,widget.email, _otpController.text);
      _showSnackBar(response.message, isError: !response.status);

      if (response.status) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpecialistSetNewPasswordScreen(email: widget.email, otp: _otpController.text),
          ),
        );
      }
    } catch (e) {
      _showSnackBar("خطأ: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resendOtp() async {
    setState(() => _isLoading = true);
    try {
      final ApiResponse response = await _apiService.forgotPasswordSpecialist(context,widget.email);
      _showSnackBar(response.message, isError: !response.status);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green));
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التحقق من الرمز'),
        centerTitle: true,
      ),
      body: Padding(
        // 💡 استخدام نسب مئوية للهوامش
        padding: EdgeInsets.all(ScreenSize.getWidth(6)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "التحقق من الرمز",
              style: TextStyle(
                fontSize: ScreenSize.getWidth(5.5), // 💡 استخدام نسبة مئوية
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ScreenSize.getHeight(1.2)), // 💡 استخدام نسبة مئوية
            Text(
              "أدخل الرمز المرسل إلى ${widget.email}",
              style: TextStyle(
                color: Colors.grey,
                fontSize: ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ScreenSize.getHeight(4)), // 💡 استخدام نسبة مئوية
            Center(
              child: Pinput(
                controller: _otpController,
                length: 6,
                defaultPinTheme: PinTheme(
                  width: ScreenSize.getWidth(12.5), // 💡 استخدام نسبة مئوية
                  height: ScreenSize.getHeight(6), // 💡 استخدام نسبة مئوية
                  textStyle: TextStyle(
                    fontSize: ScreenSize.getWidth(5), // 💡 استخدام نسبة مئوية
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)), // 💡 استخدام نسبة مئوية
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              ),
            ),
            SizedBox(height: ScreenSize.getHeight(2.5)), // 💡 استخدام نسبة مئوية
            _isLoading
                ?  Center(child: CircularProgressIndicator(color: blue))
                : ElevatedButton(
                    onPressed: _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, ScreenSize.getHeight(6)), // 💡 استخدام نسبة مئوية
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)), // 💡 استخدام نسبة مئوية
                      ),
                    ),
                    child: Text(
                      "تأكيد",
                      style: TextStyle(
                        fontSize: ScreenSize.getWidth(4.5), // 💡 استخدام نسبة مئوية
                      ),
                    ),
                  ),
            SizedBox(height: ScreenSize.getHeight(1.8)), // 💡 استخدام نسبة مئوية
            TextButton(
              onPressed: _isLoading ? null : _resendOtp,
              child: Text(
                "إعادة إرسال الرمز",
                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: ScreenSize.getWidth(4)), // 💡 استخدام نسبة مئوية
              ),
            ),
          ],
        ),
      ),
    );
  }
}