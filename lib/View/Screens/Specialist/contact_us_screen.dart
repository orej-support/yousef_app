 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/models/conversation.dart';
import 'package:youseuf_app/services/api_service.dart';
import 'package:youseuf_app/View/Screens/Sheared/chat/chat_message_screen.dart';

// ViewModel لإدارة حالة المحادثة
class ContactUsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Conversation? _conversation;
  bool _isLoading = false;
  String? _errorMessage;

  Conversation? get conversation => _conversation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSupportConversation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _conversation = await _apiService.createSupportConversation();
    } catch (e) {
      _errorMessage = '❌ فشل تحميل المحادثة: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContactUsViewModel()..loadSupportConversation(),
      child: Consumer<ContactUsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return  Scaffold(
              body: Center(child: CircularProgressIndicator(color: blue)),
            );
          }

          if (viewModel.errorMessage != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('الدعم الفني')),
              body: Center(child: Text(viewModel.errorMessage!)),
            );
          }

          if (viewModel.conversation != null) {
            return ChatMessageScreen(conversation: viewModel.conversation!);
          }

          return Scaffold(
            appBar: AppBar(title:  const Text('الدعم الفني')),
            body: const Center(child: Text('لا توجد بيانات متاحة للمحادثة.')),
          );
        },
      ),
    );
  }
}