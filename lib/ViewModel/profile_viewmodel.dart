import 'package:flutter/material.dart';
import 'package:youseuf_app/models/specialist.dart';
import 'package:youseuf_app/services/api_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  String? _userCustomId;
  int _childrenCount = 0;
  bool _isLoading = true;
  String _userName = 'unknown';

  String? get userCustomId => _userCustomId;
  int get childrenCount => _childrenCount;
  bool get isLoading => _isLoading;
  String get userName => _userName;

  Future<void> loadProfileData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // جلب بيانات الأخصائي
      final specialist = await _apiService.getSpecialistProfile();
      if (specialist != null) {
        _userCustomId = specialist.id.substring(0, 6);
        _userName = specialist.name ?? 'أخصائي';
      } else {
        _userName = 'غير معروف';
      }

      // جلب عدد الأبناء
      final childrenList = await _apiService.getMyChildren();
      _childrenCount = childrenList?.length ?? 0;
    } catch (e) {
      _userName = 'خطأ';
      debugPrint('خطأ أثناء تحميل الملف الشخصي: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
