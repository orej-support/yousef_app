import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/Screens/Sheared/chat/chat_message_screen.dart';
import 'package:youseuf_app/View/widget/Sheared/app_bar.dart';
import 'package:youseuf_app/View/widget/Sheared/conversation_item.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/icons.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد
import 'package:youseuf_app/models/conversation.dart';
import 'package:youseuf_app/services/api_service.dart';
import 'package:youseuf_app/services/pusher_service.dart';
import 'package:youseuf_app/View/Screens/Sheared/chat/available_recipients_page.dart';

class ConversationsListPage extends StatefulWidget {
  const ConversationsListPage({super.key});

  @override
  State<ConversationsListPage> createState() => _ConversationsListPageState();
}

class _ConversationsListPageState extends State<ConversationsListPage> {
  final ApiService _apiService = ApiService();
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isSpecialist = false;
  String? _currentUserId;

  StreamSubscription? _pusherSubscription;

  @override
  void initState() {
    super.initState();
    _checkUserType();
    _loadCurrentUserId();
    _fetchConversations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pusherService = Provider.of<PusherService>(context, listen: false);
      _pusherSubscription = pusherService.eventsStream.listen((event) {
        if (event.channelName.startsWith("private-conversation.")) {
          debugPrint("🔔 New message event received in ConversationsListPage");
          _fetchConversations();
        }
      });
    });
  }

  void _loadCurrentUserId() async {
    final id = await _apiService.getCurrentUserId();
    setState(() {
      _currentUserId = id;
    });
  }

  void _checkUserType() async {
    String? type = await _apiService.getUserType();
    setState(() {
      _isSpecialist = type == 'specialist';
    });
  }

  @override
  void dispose() {
    _pusherSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchConversations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final List<Conversation> conversations =
          await _apiService.getUserConversations();

      if (!mounted) return;
      setState(() {
        _conversations = conversations;
      });
    } catch (e) {
      if (!mounted) return;

      // ❌ لا نخزن رسالة الخطأ في المتغير
      // ✅ نعرض SnackBar فقط
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل جلب المحادثات: ${e.toString()}')),
          );
        }
      });

      debugPrint('Error fetching conversations: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Future<void> _fetchConversations() async {
  //   // 1. تحقق من mounted قبل أول setState
  //   if (!mounted) return;

  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = '';
  //   });
  //   try {
  //     final List<Conversation> conversations =
  //         await _apiService.getUserConversations();
  //     // 2. تحقق من mounted قبل ثاني setState
  //     if (!mounted) return;

  //     setState(() {
  //       _conversations = conversations;
  //     });
  //   } catch (e) {
  //     // 3. تحقق من mounted قبل ثالث setState
  //     if (!mounted) return;

  //     setState(() {
  //       _errorMessage = 'فشل جلب المحادثات: ${e.toString()}';
  //     });
  //     debugPrint('Error fetching conversations: $e');
  //   } finally {
  //     // 4. تحقق من mounted قبل آخر setState
  //     if (!mounted) return;

  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  // Future<void> _fetchConversations() async {
  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = '';
  //   });
  //   try {
  //     final List<Conversation> conversations = await _apiService.getUserConversations();
  //     setState(() {
  //       _conversations = conversations;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = 'فشل جلب المحادثات: ${e.toString()}';
  //     });
  //     debugPrint('Error fetching conversations: $e');
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    return Scaffold(
      appBar: _isSpecialist ? const CustomAppBar(title: 'المحادثات') : null,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: blue,
            ))
          : _errorMessage.isNotEmpty
              ? _buildErrorContent()
              : _conversations.isEmpty
                  ? _buildEmptyContent()
                  : _buildConversationList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AvailableRecipientsPage()),
          ).then((_) => _fetchConversations());
        },
        backgroundColor: blue,
        shape: const CircleBorder(),
        elevation: ScreenSize.getHeight(0.8), // 💡 استخدام نسبة مئوية
        child: Icon(AppIcons.addComment, color: white),
      ),
    );
  }
Widget _buildErrorContent() {
  return Center(
    child: Padding(
      padding: EdgeInsets.all(ScreenSize.getWidth(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.errorOutline,
            color: red,
            size: ScreenSize.getWidth(12),
          ),
          SizedBox(height: ScreenSize.getHeight(2)),
          ElevatedButton.icon(
            onPressed: _fetchConversations,
            icon: const Icon(AppIcons.replay),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    ),
  );
}

  // Widget _buildErrorContent() {
  //   return Center(
  //     child: Padding(
  //       // 💡 استخدام نسب مئوية للهوامش
  //       padding: EdgeInsets.all(ScreenSize.getWidth(5)),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             AppIcons.errorOutline,
  //             color: red,
  //             size: ScreenSize.getWidth(12), // 💡 استخدام نسبة مئوية
  //           ),
  //           SizedBox(height: ScreenSize.getHeight(2)), // 💡 استخدام نسبة مئوية
  //           Text(
  //             _errorMessage,
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               color: red,
  //               fontSize: ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية
  //             ),
  //           ),
  //           SizedBox(height: ScreenSize.getHeight(2)),
  //           ElevatedButton.icon(
  //             onPressed: _fetchConversations,
  //             icon: const Icon(AppIcons.replay),
  //             label: const Text('إعادة المحاولة'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildEmptyContent() {
    return Center(
      child: Padding(
        // 💡 إضافة هوامش لضمان عدم التصاق النص بحواف الشاشة
        padding: EdgeInsets.all(ScreenSize.getWidth(5)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.infoOutline,
              color: grey,
              size: ScreenSize.getWidth(12), // 💡 استخدام نسبة مئوية
            ),
            SizedBox(height: ScreenSize.getHeight(2)),
            Text(
              'لا توجد محادثات حتى الآن. ابدأ واحدة جديدة!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ScreenSize.getWidth(4.5), // 💡 استخدام نسبة مئوية
                color: darkgrey,
              ),
            ),
            SizedBox(height: ScreenSize.getHeight(2)),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AvailableRecipientsPage()),
                ).then((_) => _fetchConversations());
              },
              icon: const Icon(AppIcons.addComment),
              label: const Text('ابدأ محادثة جديدة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationList() {
    return ListView.builder(
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return ConversationItem(
          currentUserId: _currentUserId,
          conversation: conversation,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatMessageScreen(conversation: conversation),
              ),
            ).then((_) => _fetchConversations());
          },
        );
      },
    );
  }
}
