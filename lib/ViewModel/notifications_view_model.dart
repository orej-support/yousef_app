import 'package:flutter/material.dart';
import 'package:youseuf_app/services/api_service.dart';

class NotificationsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;

  int _currentPage = 1;
  int _lastPage = 1;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  bool get hasMoreNotifications => _currentPage < _lastPage;

  // ضفها داخل class NotificationsViewModel
  void clearError({bool notify = false}) {
    if (_errorMessage != null) {
      _errorMessage = null;
      if (notify)
        notifyListeners(); // غالباً ما نحتاجها false لتفادي إعادة بناء إضافية
    }
  }

Future<void> fetchNotifications(BuildContext context, {bool isInitialFetch = true}) async {
  if (_isLoading) return; // منع جلب البيانات إذا كانت عملية أخرى قيد التنفيذ

  if (isInitialFetch) {
    _currentPage = 1;
    _notifications.clear();
    _errorMessage = null; // إعادة تعيين رسالة الخطأ في الجلب الأولي
  } else {
    if (!hasMoreNotifications) {
      debugPrint('No more notifications to load.');
      return;
    }
    _currentPage++;
  }

  _isLoading = true;
  notifyListeners(); // إخطار الواجهة بأن التحميل قد بدأ

  try {
    // حاول جلب البيانات من الـ API
    final response = await _apiService.fetchNotifications(page: _currentPage);

    if (response != null && response['notifications'] != null) {
      final newNotifications = List<Map<String, dynamic>>.from(response['notifications']);

      if (isInitialFetch) {
        _notifications = newNotifications; // استبدال القائمة بالإشعارات الجديدة
      } else {
        _notifications.addAll(newNotifications); // إضافة الإشعارات الجديدة إلى القائمة الحالية
      }

      _errorMessage = null; // مسح رسالة الخطأ عند النجاح

      if (response['pagination'] != null) {
        _lastPage = response['pagination']['last_page'] ?? 1;
      }
      
      // فرز الإشعارات بعد كل جلب
      _sortNotifications(context);
      
    } else {
      // التعامل مع حالة عدم وجود بيانات أو استجابة غير متوقعة
      if (isInitialFetch) {
        _notifications = [];
      }
      _errorMessage = response?['message'] ?? 'فشل تحميل الإشعارات.';
    }
  } catch (e) {
    // 💡 التعديل هنا: تحديد رسالة الخطأ عند فشل الاتصال
    if (e.toString().contains('Failed host lookup')) {
      _errorMessage = 'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك.';
    } else {
      _errorMessage = 'حدث خطأ: ${e.toString().replaceFirst("Exception: ", "")}';
    }
    
    // إذا كان هذا جلبًا أوليًا، قم بمسح القائمة
    if (isInitialFetch) {
      _notifications = [];
    }
    debugPrint('خطأ في جلب الإشعارات: $e');
  } finally {
    _isLoading = false;
    await fetchUnreadCount(context); // تحديث عدد الإشعارات غير المقروءة
    notifyListeners(); // إخطار الواجهة بأن التحميل قد انتهى
  }
}
  // Future<void> fetchNotifications(BuildContext context ,{bool isInitialFetch = true}) async {
  //   if (_isLoading) return;

  //   if (isInitialFetch) {
  //     _currentPage = 1;
  //     _notifications.clear();
  //     _errorMessage = null;
  //   } else {
  //     if (!hasMoreNotifications) {
  //       debugPrint('No more notifications to load.');
  //       return;
  //     }
  //     _currentPage++;
  //   }

  //   _isLoading = true;
  //   notifyListeners();

  //   try {
  //     final response = await _apiService.fetchNotifications(page: _currentPage);

  //     if (response != null && response['notifications'] != null) {
  //       final newNotifications =
  //           List<Map<String, dynamic>>.from(response['notifications']);

  //       // إذا كان هذا جلبًا أوليًا، استبدل القائمة
  //       if (isInitialFetch) {
  //         _notifications = newNotifications;
  //       } else {
  //         // بخلاف ذلك، أضف الإشعارات الجديدة
  //         _notifications.addAll(newNotifications);
  //       }

  //       _errorMessage = null;

  //       if (response['pagination'] != null) {
  //         _lastPage = response['pagination']['last_page'] ?? 1;
  //       }

  //       // <--- إضافة: فرز الإشعارات هنا بعد كل جلب ---
  //       _sortNotifications(context);
  //       // --- نهاية الإضافة ---
  //     } else {
  //       _errorMessage = response?['message'] ?? 'فشل تحميل الإشعارات.';
  //       if (isInitialFetch) {
  //         _notifications = [];
  //       }
  //     }
  //   } catch (e) {
  //     _errorMessage = 'حدث خطأ: ${e.toString()}';
  //     if (isInitialFetch) {
  //       _notifications = [];
  //     }
  //     debugPrint('خطأ في جلب الإشعارات: $e');
  //   } finally {
  //     _isLoading = false;
  //     await fetchUnreadCount(context);
  //     notifyListeners();
  //   }
  // }

  // <--- إضافة: دالة الفرز الجديدة ---
  void _sortNotifications(BuildContext context) {
    _notifications.sort((a, b) {
      final bool aIsRead = a['is_read'] ?? false;
      final bool bIsRead = b['is_read'] ?? false;

      // الإشعارات غير المقروءة (false) تأتي قبل المقروءة (true)
      if (aIsRead != bIsRead) {
        return aIsRead
            ? 1
            : -1; // إذا كانت A مقروءة و B غير مقروءة، فـ B تأتي أولاً (-1)
      }

      // إذا كانت كلتاهما مقروءتين أو غير مقروءتين، فرز حسب تاريخ الإنشاء (الأحدث أولاً)
      // تذكر أن API الخاص بك قد يعيدها بالترتيب الزمني.
      // إذا كان API يعيد الأحدث أولاً، استخدم هذا:
      final DateTime aDate = DateTime.parse(a['created_at']);
      final DateTime bDate = DateTime.parse(b['created_at']);
      return bDate.compareTo(aDate); // الأحدث أولاً
    });
  }
  // --- نهاية الإضافة ---

  Future<void> markAllAsRead(BuildContext context) async {
    try {
      // قم باستدعاء API لتعليم جميع الإشعارات كمقروءة دفعة واحدة (إذا كان API يدعم ذلك)
      // await _apiService.markAllNotificationsAsRead();

      // أو قم بالمرور على كل إشعار واحد تلو الآخر
      for (var notification in _notifications) {
        final id = notification['id'];
        final isAlreadyRead = isNotificationRead(notification);
        if (!isAlreadyRead) {
          await markAsRead(context,id); // سيقوم هذا بتحديث العداد تلقائياً ويقوم بالفرز
        }
      }
      // بعد الانتهاء، قم بالفرز النهائي
      _sortNotifications(context);
      notifyListeners();
    } catch (e) {
      debugPrint("markAllAsRead error: $e");
    }
  }

  Future<void> fetchUnreadCount(BuildContext context) async {
    try {
      _unreadCount = await _apiService.fetchUnreadNotificationsCount(context);
    } catch (e) {
      debugPrint('Error in ViewModel fetching unread count: $e');
      _unreadCount = 0;
    }
  }

  Future<void> markAsRead(BuildContext context,int notificationId) async {
    // تحديث الواجهة بشكل افتراضي (optimistic update)
    final int index =
        _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1 && !_notifications[index]['is_read']) {
      _notifications[index]['is_read'] = true;
      _notifications[index]['read_at'] = DateTime.now().toIso8601String();
      // لا تستدعي notifyListeners() هنا مباشرةً بعد التحديث الافتراضي
      // سنستدعيها بعد الفرز
    }

    try {
      final success = await _apiService.markNotificationAsRead(notificationId);
      if (!success) {
        // إذا فشل استدعاء الـ API، قم بإلغاء التحديث الافتراضي أو عرض رسالة خطأ
        if (index != -1) {
          _notifications[index]['is_read'] = false;
          _notifications[index]['read_at'] = null;
        }
        _errorMessage = 'فشل تحديد الإشعار كمقروء.';
      } else {
        _errorMessage = null;
      }
    } catch (e) {
      // إلغاء التغيير عند وجود خطأ
      if (index != -1) {
        _notifications[index]['is_read'] = false;
        _notifications[index]['read_at'] = null;
      }
      _errorMessage = 'حدث خطأ أثناء تحديد الإشعار كمقروء: ${e.toString()}';
      debugPrint('خطأ في تحديد الإشعار كمقروء: $e');
    } finally {
      await fetchUnreadCount(context);
      // <--- إضافة: فرز الإشعارات بعد التحديث ---
      _sortNotifications(context);
      // --- نهاية الإضافة ---
      notifyListeners(); // إبلاغ المستمعين بعد الفرز وتحديث العدد
    }
  }

  bool isNotificationRead(Map<String, dynamic> notification) {
    return notification['is_read'] == true;
  }
}
