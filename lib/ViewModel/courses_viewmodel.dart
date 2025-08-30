import 'package:flutter/material.dart';
import 'package:youseuf_app/models/course.dart';
import 'package:youseuf_app/services/api_service.dart';

class CoursesViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  List<Course> courses = [];

  Future<void> loadCourses() async {
    isLoading = true;
    notifyListeners();

    try {
      courses = await _apiService.getCourses(); // استدعاء API
    } catch (e) {
      print('حدث خطأ أثناء تحميل الدورات: $e');
      courses = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
