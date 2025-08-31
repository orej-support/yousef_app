import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/Screens/Sheared/splash_screen.dart';
import 'package:youseuf_app/View/Screens/Sheared/chat/chat_message_screen.dart';
import 'package:youseuf_app/ViewModel/Superviser/FamilyReportsViewModel.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/services/api_service.dart';
import 'package:youseuf_app/services/pusher_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:intl/date_symbol_data_local.dart';

// ✅ الإضافة هنا
import 'package:youseuf_app/ViewModel/CustomAppBar.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await initializeDateFormatting(
      'en', null); // أو 'ar' إذا استخدمت 'ar' في DateFormat

  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');

  final apiService = ApiService();
  final pusherService = PusherService(
    pusherAppKey: '3bfd650aec9e18344771',
    pusherCluster: 'mt1',
    authBaseUrl: 'https://mubadarat-youssef.futureti.org',
    apiService: apiService,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService),
        Provider<PusherService>(create: (_) => pusherService),
        // ✅ مزود ViewModel هنا
        ChangeNotifierProvider<CustomAppBarViewModel>(
          create: (context) => CustomAppBarViewModel(context),
        ),
         ChangeNotifierProvider(
          create: (_) => FamilyReportsViewModel(apiService: apiService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _apiService = Provider.of<ApiService>(context);
  }

  Future<void> _setupFirebaseMessaging() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        _sendFcmTokenToBackend(token);
      }

    FirebaseMessaging.onMessage.listen((message) {
  if (message.notification != null) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(
          '${message.notification!.title ?? 'إشعار'}: ${message.notification!.body ?? 'رسالة جديدة'}',
        ),
        action: SnackBarAction(
          label: 'عرض',
          onPressed: () {
            _handleNotificationTap(message.data);
          },
        ),
      ),
    );

    // 📌 تحديث عدد الإشعارات غير المقروءة
    final appBarViewModel = Provider.of<CustomAppBarViewModel>(
      navigatorKey.currentContext!,
      listen: false,
    );
    appBarViewModel.fetchUnreadCount(context);
  }
});

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _handleNotificationTap(message.data);
      });

      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage.data);
      }
    } else {
    }
  }

  Future<void> _sendFcmTokenToBackend(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final authToken = prefs.getString('auth_token');

    if (userId == null || authToken == null) return;

    try {
      final response = await http.post(
        Uri.parse('https://mubadarat-youssef.futureti.org/api/store-fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'user_id': userId, 'fcm_token': token}),
      );

      if (response.statusCode == 200) {
      } else {
      }
    } catch (e) {
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) async {
    if (data['type'] == 'chat_message' && data.containsKey('conversation_id')) {
      final conversationId = int.tryParse(data['conversation_id'].toString());
      if (conversationId != null) {
        try {
          final conversations = await _apiService.getUserConversations();
          final conversation =
              conversations.firstWhereOrNull((c) => c.id == conversationId);

          if (conversation != null) {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => ChatMessageScreen(conversation: conversation),
              ),
            );
          } else {
          }
        } catch (e) {
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Yousef',
      theme: ThemeData(
        fontFamily: 'almarai',
        scaffoldBackgroundColor: backgroundcolor,
      ),
      home: const SplashScreen(),
    );
  }
}
