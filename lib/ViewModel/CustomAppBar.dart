
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/services/api_service.dart';

/// ViewModel لإدارة حالة شريط التطبيق المخصص (CustomAppBar).
/// يستخدم هذا الـ ViewModel لجلب وتخزين بيانات المستخدم وعدد الإشعارات غير المقروءة.
class CustomAppBarViewModel extends ChangeNotifier {
  // خدمة API للتواصل مع الواجهة الخلفية (Backend).
  final ApiService _apiService = ApiService();

  // متغيرات لتخزين بيانات المستخدم وحالة التطبيق.
  String? userType;
  String? userName;
  String? type;
  int _unreadCount = 0; // جعل المتغير خاصًا لحماية التعديل المباشر.

  // مُنشئ الـ ViewModel الذي يبدأ بجلب البيانات الأساسية.
  CustomAppBarViewModel(BuildContext context) {
    fetchUserData();
    fetchUnreadCount(context);
  }

  // Getter للوصول إلى عدد الإشعارات من خارج الـ ViewModel.
  int get unreadCount => _unreadCount;

  /// إعادة تعيين عدد الإشعارات غير المقروءة إلى الصفر.
  /// يتم استدعاؤها عادةً بعد أن يقوم المستخدم بفتح صفحة الإشعارات.
  void resetUnreadCount() {
    _unreadCount = 0;
    notifyListeners();
  }

  /// تحديث جميع البيانات (بيانات المستخدم وعدد الإشعارات).
  /// يمكن استدعاؤها عند الحاجة لتحديث شامل لواجهة المستخدم.
  Future<void> refreshData(BuildContext context) async {
    await fetchUserData();
    await fetchUnreadCount(context);
  }

  /// جلب بيانات المستخدم من الخادم وتحديثها.
  /// يتم تحديث اسم المستخدم ونوعه بناءً على نوع المستخدم (specialist أو user).
  Future<void> fetchUserData() async {
    try {
      userType = await _apiService.getUserType();
      debugPrint('User Type: $userType');
      if (userType == 'specialist') {
        final specialist = await _apiService.getSpecialistProfile();
        userName = specialist?.name ?? '...';
        type = specialist?.type ?? '';
      } else {
        final user = await _apiService.getUserDashboardStats();
        userName = user?['data']?['user_name'] ?? '...';
        type = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  /// جلب عدد الإشعارات غير المقروءة من الخادم وتحديث العداد.
  /// هذه الدالة هي المسؤولة عن تحديث العداد في أيقونة الجرس.
  Future<void> fetchUnreadCount(BuildContext context) async {
    try {
      final int count = await _apiService.fetchUnreadNotificationsCount( context);

      // تجنب التحديث إذا لم تتغير القيمة لتفادي إعادة بناء الواجهة دون داعي.
      if (_unreadCount != count) {
        _unreadCount = count;
        print("📢 عدد الإشعارات: $_unreadCount");
        notifyListeners();
      }
    } catch (e) {
      // في حالة وجود خطأ، يتم تعيين العداد إلى 0 (إذا لم يكن 0 بالفعل).
      if (_unreadCount != 0) {
        _unreadCount = 0;
        notifyListeners();
      }
      print("📢 عدد الإشعارات: $_unreadCount");
    }
  }
}