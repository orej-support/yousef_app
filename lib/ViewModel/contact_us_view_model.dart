import 'package:flutter/material.dart';
import 'package:youseuf_app/models/conversation.dart';
import 'package:youseuf_app/services/api_service.dart';

class ContactUsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

 Future<Conversation?> startSupportConversation() async {
  try {
    return await _apiService.createSupportConversation();
  } catch (e) {
    debugPrint('❌ فشل بدء محادثة الدعم: $e');
    return null;
  }
}

}
