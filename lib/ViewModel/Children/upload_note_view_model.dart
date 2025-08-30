import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class UploadNoteViewModel extends ChangeNotifier {
  bool isLoading = false;
  String errorMessage = '';

  Future<bool> saveNote({
    required String noteTitle,
    required String noteContent,
    required String childrenId,
    
  }) async {
    if (noteTitle.trim().isEmpty) {
      errorMessage = "الرجاء إدخال عنوان الملاحظة";
      notifyListeners();
      return false;
    }

    if (noteContent.trim().isEmpty) {
      errorMessage = "الرجاء إدخال محتوى الملاحظة";
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final api = ApiService();
      await api.createNote(
       
        childrenId,
        noteTitle,
        noteContent,
        // String childId, String title, String content
      );

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
