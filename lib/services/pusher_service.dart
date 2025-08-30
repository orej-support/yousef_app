import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:youseuf_app/services/api_service.dart';

enum UserType { user, specialist, unknown }

class PusherService {
  late final PusherChannelsFlutter _pusher;
  final String _pusherAppKey;
  final String _pusherCluster;
  final String _authBaseUrl;
  final ApiService _apiService;

  String? _authenticatedUserId;
  UserType _authenticatedUserType = UserType.unknown;

  final StreamController<PusherEvent> _eventController =
      StreamController<PusherEvent>.broadcast();
  Stream<PusherEvent> get eventsStream => _eventController.stream;

  bool get isConnected => _pusher.connectionState == 'CONNECTED';

  PusherService({
    required String pusherAppKey,
    required String pusherCluster,
    required String authBaseUrl,
    required ApiService apiService,
  })  : _pusherAppKey = pusherAppKey,
        _pusherCluster = pusherCluster,
        _authBaseUrl = authBaseUrl,
        _apiService = apiService {
    _pusher = PusherChannelsFlutter.getInstance();
  }

  /// تهيئة اتصال Pusher.
  /// هذه الدالة ستقوم بجلب التوكن ومعلومات المستخدم من ApiService.
  Future<void> initPusher() async {
    // 1. جلب معلومات المستخدم من ApiService (الذي بدوره يقرأ من SecureStorage)
    _authenticatedUserId = await _apiService.getCurrentUserId();
    final userTypeString = await _apiService.getUserType();
    _authenticatedUserType = userTypeString != null
        ? _stringToUserType(userTypeString)
        : UserType.unknown;

    // قم بقطع الاتصال الموجود قبل إعادة التهيئة لضمان اتصال نظيف
    if (_pusher.connectionState == 'CONNECTED' ||
        _pusher.connectionState == 'CONNECTING') {
      await _pusher.disconnect();
    }


    try {
      await _pusher.init(
        apiKey: _pusherAppKey,
        cluster: _pusherCluster,
        onConnectionStateChange: _onConnectionStateChange,
        onError: _onError,
        onEvent: _eventController.add,
        onSubscriptionSucceeded: _onSubscriptionSucceeded,
        onSubscriptionError: _onSubscriptionError,
        onDecryptionFailure: _onDecryptionFailure,
        onAuthorizer: (channelName, socketId, options) async {
          const String authEndpoint = 'api/broadcasting/auth';
          var url = Uri.parse("$_authBaseUrl/$authEndpoint");

          // النقطة الحاسمة: جلب التوكن مباشرة من ApiService عند محاولة المصادقة
          final String? currentAuthToken = await _apiService.getToken();

          if (currentAuthToken == null || currentAuthToken.isEmpty) {
            throw Exception('Auth Token missing for Pusher authorization.');
          }

          final requestBody = {
            'channel_name': channelName,
            'socket_id': socketId,
          };

        
          try {
            var response = await http.post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization':
                    'Bearer $currentAuthToken', // استخدام التوكن الذي تم جلبه
              },
              body: jsonEncode(requestBody), // استخدام الـ requestBody المتغير
            );

            if (response.statusCode == 200) {
              return jsonDecode(response.body);
            } else {
                            throw Exception(
                  'Failed to authenticate with Pusher: ${response.body}');
            }
          } catch (e) {
           
            rethrow;
          }
        },
      );

      await _pusher.connect();

      // الاشتراك في القناة الخاصة بالمستخدم/الأخصائي بعد الاتصال بنجاح.
      String userChannelName = '';
      if (_authenticatedUserType == UserType.user &&
          _authenticatedUserId != null) {
        userChannelName = 'user.$_authenticatedUserId';
      } else if (_authenticatedUserType == UserType.specialist &&
          _authenticatedUserId != null) {
        userChannelName = 'specialist.$_authenticatedUserId';
      }

      if (userChannelName.isNotEmpty) {
    
        await _pusher.subscribe(channelName: userChannelName);
      } else {
   
      }

    } catch (e) {
    }
  }

  /// دالة لتحديث معلومات المستخدم في PusherService بعد تسجيل الدخول أو عند الحاجة.
  /// يجب استدعاء هذه الدالة بعد نجاح تسجيل الدخول وقبل initPusher إذا لم تكن معلومات
  /// المستخدم محفوظة بعد، أو إذا تغيرت.
  Future<void> updateAuthInfoAndInitPusher() async {
    _authenticatedUserId = await _apiService.getCurrentUserId();
    final userTypeString = await _apiService.getUserType();
    _authenticatedUserType = userTypeString != null
        ? _stringToUserType(userTypeString)
        : UserType.unknown;

    // ثم قم بتهيئة Pusher بالتوكن الجديد الذي سيتم جلبه تلقائياً
    await initPusher();
  }

  /// يشترك في قناة محادثة خاصة.
  Future<void> subscribeToConversationChannel(String conversationId) async {
    if (_pusher.connectionState != 'CONNECTED') {
      return;
    }
    // هذا هو السطر الذي تم تعديله
    // تأكد أن هذا الاسم يطابق تمامًا الاسم الذي تراه في سجلات Pusher كـ 'Event Channel'
    // والذي يجب أن يكون 'private-conversation.{id}'
    String chatChannelName =
        'private-conversation.$conversationId'; // <-- التعديل هنا
    try {
      await _pusher.subscribe(
        channelName: chatChannelName,
        onEvent: _eventController.add, // <-- هذه أهم خطوة
      );

    } catch (e) {
    }
  }

  /// يلغي الاشتراك من قناة معينة.
  void unsubscribe({required String channelName}) {
    try {
      _pusher.unsubscribe(channelName: channelName);
    } catch (e) {
    }
  }

  /// يفصل الاتصال بخدمة Pusher.
  Future<void> disconnect() async {
    if (_pusher.connectionState == 'CONNECTED') {
      await _pusher.disconnect();
    } else {
    }
    _authenticatedUserId = null;
    _authenticatedUserType = UserType.unknown;
  }

  /// يجب استدعاء هذه الدالة عند التخلص من مثيل PusherService
  Future<void> dispose() async {
    await disconnect();
    if (!_eventController.isClosed) {
      await _eventController.close();
    }
  }

  // --- Callbacks for Pusher events ---
  void _onConnectionStateChange(dynamic currentState, dynamic previousState) {
  }

  void _onError(String message, int? code, dynamic e) {
  }

  void _onSubscriptionSucceeded(String channelName, dynamic data) {
  }

  void _onSubscriptionError(String message, dynamic e) {
  }

  void _onDecryptionFailure(String event, String reason) {
  }

  UserType _stringToUserType(String type) {
    switch (type.toLowerCase()) {
      case 'user':
        return UserType.user;
      case 'specialist':
        return UserType.specialist;
      default:
        return UserType.unknown;
    }
  }
}
