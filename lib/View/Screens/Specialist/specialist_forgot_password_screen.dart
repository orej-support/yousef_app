
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/Screens/Specialist/SpecialistOtpVerificationScreen.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/services/api_service.dart';

// ViewModel لإدارة منطق الشاشة
class SpecialistForgotPasswordViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> submitForgotPassword(String email, BuildContext context) async {
    // التحقق من صحة البريد الإلكتروني
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar(context, 'الرجاء إدخال بريد إلكتروني صالح.', isError: true);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final ApiResponse response = await _apiService.forgotPasswordSpecialist(context,email);
      _showSnackBar(context, response.message, isError: !response.status);

      if (response.status) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpecialistOtpVerificationScreen(email: email),
          ),
        );
      }
    } on ApiException catch (e) {
      _showSnackBar(context, e.message, isError: true);
    } catch (e) {
      _showSnackBar(context, 'حدث خطأ غير متوقع: ${e.toString()}', isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}

class SpecialistForgotPasswordScreen extends StatelessWidget {
  const SpecialistForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SpecialistForgotPasswordViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'نسيت كلمة المرور',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Consumer<SpecialistForgotPasswordViewModel>(
          builder: (context, viewModel, _) {
            final TextEditingController _emailController = TextEditingController();

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "نسيت كلمة المرور",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "أدخل بريدك الإلكتروني لإرسال رمز إعادة التعيين",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "البريد الإلكتروني",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  viewModel.isLoading
                      ?  Center(child: CircularProgressIndicator(color: blue))
                      : ElevatedButton(
                          onPressed: () => viewModel.submitForgotPassword(_emailController.text, context),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("إرسال", style: TextStyle(fontSize: 18)),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
