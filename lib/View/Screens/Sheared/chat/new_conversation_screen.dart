import 'package:flutter/material.dart';
import 'package:youseuf_app/View/Screens/Sheared/chat/chat_message_screen.dart';
import 'package:youseuf_app/View/widget/Sheared/back_leading.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد
import 'package:youseuf_app/models/user.dart';
import 'package:youseuf_app/models/specialist.dart';
import 'package:youseuf_app/models/conversation.dart';
import 'package:youseuf_app/services/api_service.dart';

class NewConversationScreen extends StatefulWidget {
  const NewConversationScreen({super.key});

  @override
  State<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _recipientsFuture;

  @override
  void initState() {
    super.initState();
    _fetchAvailableRecipients();
  }

  void _fetchAvailableRecipients() {
    setState(() {
      _recipientsFuture = _apiService.getAvailableChatRecipients();
    });
  }
void _startNewPrivateConversation(dynamic recipient) async {
  final int recipientId = recipient.id;
  final String recipientType =
      recipient is User ? 'App\\Models\\User' : 'App\\Models\\Specialist';
  try {
    final Conversation? newConversation =
        await _apiService.createPrivateConversation(
      recipientId: recipientId,
      recipientType: recipientType,
    );

    if (!mounted || newConversation == null) return;

    // ✅ عرض رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم بدء المحادثة بنجاح ✅')),
    );

    // الانتقال لصفحة المحادثة
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatMessageScreen(conversation: newConversation),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    // ✅ رسالة خطأ واضحة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('فشل بدء المحادثة. حاول مرة أخرى لاحقًا.'),
      ),
    );

    // 🔍 طباعة التفاصيل في الـ debug فقط
    debugPrint('Error starting conversation: $e');
  }
}

  // void _startNewPrivateConversation(dynamic recipient) async {
  //   final int recipientId = recipient.id;
  //   final String recipientType =
  //       recipient is User ? 'App\\Models\\User' : 'App\\Models\\Specialist';
  //   try {
  //     final Conversation? newConversation = await _apiService.createPrivateConversation(
  //       recipientId: recipientId,
  //       recipientType: recipientType,
  //     );
  //     if (!mounted) return;
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => ChatMessageScreen(conversation: newConversation!),
  //       ),
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('فشل بدء المحادثة: $e')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ زر الرجوع
            Padding(
              // 💡 استخدام نسب مئوية للهوامش
              padding: EdgeInsets.all(ScreenSize.getWidth(2)),
              child: const BackLeading(),
            ),
            // ✅ عنوان الصفحة
            Padding(
              // 💡 استخدام نسب مئوية للهوامش
              padding: EdgeInsets.symmetric(horizontal: ScreenSize.getWidth(4)),
              child: Text(
                'بدء محادثة جديدة',
                style: TextStyle(
                  // 💡 استخدام نسب مئوية لحجم الخط
                  fontSize: ScreenSize.getWidth(5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: ScreenSize.getHeight(1.5)), // 💡 استخدام نسبة مئوية
            // ✅ محتوى الصفحة
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _recipientsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return  Center(child: CircularProgressIndicator(color: blue,));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        // 💡 استخدام نسب مئوية للهوامش
                        padding: EdgeInsets.all(ScreenSize.getWidth(4)),
                        child: Text(
                          'خطأ في جلب المستلمين: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: red),
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'لا يوجد مستلمون متاحون لبدء محادثة.',
                        // 💡 استخدام نسب مئوية لحجم الخط
                        style: TextStyle(fontSize: ScreenSize.getWidth(4)),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final recipient = snapshot.data![index];
                        String name = '';
                        String subtitle = '';
                        if (recipient is User) {
                          name = recipient.name;
                          subtitle = 'مستخدم';
                        } else if (recipient is Specialist) {
                          name = recipient.name;
                          subtitle = 'أخصائي - ${recipient.type ?? 'غير محدد'}';
                        } else {
                          name = 'مستخدم غير معروف';
                        }

                        return Card(
                          // 💡 استخدام نسب مئوية للهوامش
                          margin: EdgeInsets.symmetric(
                            horizontal: ScreenSize.getWidth(2),
                            vertical: ScreenSize.getHeight(0.5),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              // 💡 استخدام نسب مئوية لنصف القطر
                              radius: ScreenSize.getWidth(5),
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: TextStyle(
                                  // 💡 استخدام نسب مئوية لحجم الخط
                                  fontSize: ScreenSize.getWidth(4),
                                ),
                              ),
                            ),
                            title: Text(
                              name,
                              style: TextStyle(
                                // 💡 استخدام نسب مئوية لحجم الخط
                                fontSize: ScreenSize.getWidth(4),
                              ),
                            ),
                            subtitle: Text(
                              subtitle,
                              style: TextStyle(
                                // 💡 استخدام نسب مئوية لحجم الخط
                                fontSize: ScreenSize.getWidth(3),
                              ),
                            ),
                            onTap: () {
                              _startNewPrivateConversation(recipient);
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}