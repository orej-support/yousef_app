import 'package:flutter/material.dart';
import 'package:youseuf_app/models/note_model.dart';
import 'package:youseuf_app/services/api_service.dart';

class NotesViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<NoteModel> _notes = [];
  bool isLoading = false;
  String? errorMessage;

  List<NoteModel> get notes => _notes;
  // في NotesViewModel
Future<List<NoteModel>> fetchNotes(String childId) async {
  isLoading = true;
  errorMessage = null;
  notifyListeners();

  try {
    final data = await _apiService.getChildReportsAndNotes(childId);

    if (data != null && data['general_notes'] != null) {
      final notesData = data['general_notes'] as List<dynamic>;
      _notes = notesData.map((note) => NoteModel.fromMap(note)).toList();
      if (_notes.isEmpty) {
        errorMessage = 'لا توجد ملاحظات متاحة.';
      }
    } else {
      _notes = [];
      errorMessage = 'لا توجد ملاحظات متاحة.';
    }
  } catch (e) {
    // 💡 هذا الجزء هو المسؤول عن رسائل الخطأ
    // إذا كان الخطأ من نوع `Exception`
    if (e.toString().contains('Failed to connect')) {
      errorMessage = 'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك.';
    } else {
      errorMessage = 'حدث خطأ: ${e.toString().replaceFirst("Exception: ", "")}';
    }
    _notes = [];
  }

  isLoading = false;
  notifyListeners();
  return _notes;
}

//  Future<List<NoteModel>> fetchNotes(String childId) async {
//   isLoading = true;
//   errorMessage = null;
//   notifyListeners();

//   try {
//     final data = await _apiService.getChildReportsAndNotes(childId);

//     if (data != null) {
//       final notesData = data['general_notes'] as List<dynamic>? ?? [];

//       _notes = notesData.map((note) => NoteModel.fromMap(note)).toList();
//       print("استجابة الملاحظات: $notesData");
//     } else {
//       _notes = [];
//       errorMessage = 'لا توجد ملاحظات متاحة.';
//     }
//   } catch (e) {
//     errorMessage = e.toString().replaceFirst("Exception: ", "");
//     _notes = [];
//   }

//   isLoading = false;
//   notifyListeners();
//   return _notes;
// }

}
