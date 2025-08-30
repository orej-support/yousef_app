import 'package:flutter/material.dart';
import 'package:youseuf_app/View/Screens/Sheared/chat/chat_message_screen.dart';
import 'package:youseuf_app/View/Screens/Sheared/chat/new_conversation_screen.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // استيراد كلاس الأبعاد
import 'package:youseuf_app/core/utils/icons.dart';
import 'package:youseuf_app/models/conversation.dart';
import 'package:youseuf_app/services/api_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Conversation>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  void _fetchConversations() {
    setState(() {
      _conversationsFuture = _apiService.getUserConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('محادثاتي'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.addComment),
            onPressed: () async {
              final bool? conversationStarted = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewConversationScreen(),
                ),
              );
              if (conversationStarted == true) {
                _fetchConversations();
              }
            },
          ),
          IconButton(
            icon: const Icon(AppIcons.refresh),
            onPressed: _fetchConversations,
          ),
        ],
      ),
      body:
      FutureBuilder<List<Conversation>>(
  future: _conversationsFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator(color: blue));
    } else if (snapshot.hasError) {
      // عرض SnackBar فقط عند الخطأ
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في جلب المحادثات: ${snapshot.error}')),
          );
        }
      });
      // عرض واجهة فارغة بدل رسالة خطأ
      return const SizedBox.shrink();
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(ScreenSize.getWidth(4)),
          child: const Text('لا توجد محادثات حتى الآن. ابدأ واحدة جديدة!'),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          final conversation = snapshot.data![index];
          String chatTitle = conversation.isGroup
              ? conversation.name
              : conversation.participants
                  .firstWhere(
                    (p) => p.id != _apiService.getCurrentUserId(),
                    orElse: () => conversation.participants.first,
                  )
                  .name;

          return Card(
            margin: EdgeInsets.symmetric(
              horizontal: ScreenSize.getWidth(2),
              vertical: ScreenSize.getHeight(0.5),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: blueGrey,
                radius: ScreenSize.getWidth(7),
                child: Text(
                  chatTitle.isNotEmpty ? chatTitle[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: white,
                    fontSize: ScreenSize.getWidth(5),
                  ),
                ),
              ),
              title: Text(chatTitle),
              subtitle: Text(
                conversation.lastMessageContent ?? 'لا توجد رسائل سابقة',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: conversation.unreadMessagesCount > 0
                  ? Container(
                      padding: EdgeInsets.all(ScreenSize.getWidth(1.5)),
                      decoration: BoxDecoration(
                        color: red,
                        borderRadius:
                            BorderRadius.circular(ScreenSize.getWidth(2.5)),
                      ),
                      child: Text(
                        conversation.unreadMessagesCount.toString(),
                        style: TextStyle(
                          color: white,
                          fontSize: ScreenSize.getWidth(3),
                        ),
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatMessageScreen(
                      conversation: conversation,
                    ),
                  ),
                ).then((_) {
                  _fetchConversations();
                });
              },
            ),
          );
        },
      );
    }
  },
),

      //  FutureBuilder<List<Conversation>>(
      //   future: _conversationsFuture,
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return  Center(child: CircularProgressIndicator(color: blue,));
      //     } else if (snapshot.hasError) {
      //       return Center(
      //         child: Padding(
      //           // 💡 استخدام نسب مئوية للهوامش
      //           padding: EdgeInsets.all(ScreenSize.getWidth(4)),
      //           child: Text(
      //             'خطأ في جلب المحادثات: ${snapshot.error}',
      //             textAlign: TextAlign.center,
      //             style: TextStyle(color: red),
      //           ),
      //         ),
      //       );
      //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      //       return Center(
      //         // 💡 استخدام نسب مئوية للهوامش
      //         child: Padding(
      //           padding: EdgeInsets.all(ScreenSize.getWidth(4)),
      //           child: const Text('لا توجد محادثات حتى الآن. ابدأ واحدة جديدة!'),
      //         ),
      //       );
      //     } else {
      //       return ListView.builder(
      //         itemCount: snapshot.data!.length,
      //         itemBuilder: (context, index) {
      //           final conversation = snapshot.data![index];
      //           String chatTitle = conversation.isGroup
      //               ? conversation.name
      //               : conversation.participants
      //                   .firstWhere(
      //                     (p) => p.id != _apiService.getCurrentUserId(),
      //                     orElse: () => conversation.participants.first,
      //                   )
      //                   .name;

      //           return Card(
      //             margin: EdgeInsets.symmetric(
      //               // 💡 استخدام نسب مئوية للهوامش
      //               horizontal: ScreenSize.getWidth(2),
      //               vertical: ScreenSize.getHeight(0.5),
      //             ),
      //             child: ListTile(
      //               leading: CircleAvatar(
      //                 backgroundColor: blueGrey,
      //                 // 💡 استخدام نسب مئوية لنصف القطر
      //                 radius: ScreenSize.getWidth(7),
      //                 child: Text(
      //                   chatTitle.isNotEmpty ? chatTitle[0].toUpperCase() : '?',
      //                   style: TextStyle(
      //                     color: white,
      //                     // 💡 استخدام نسب مئوية لحجم الخط
      //                     fontSize: ScreenSize.getWidth(5),
      //                   ),
      //                 ),
      //               ),
      //               title: Text(chatTitle),
      //               subtitle: Text(
      //                 conversation.lastMessageContent ?? 'لا توجد رسائل سابقة',
      //                 maxLines: 1,
      //                 overflow: TextOverflow.ellipsis,
      //               ),
      //               trailing: conversation.unreadMessagesCount > 0
      //                   ? Container(
      //                       // 💡 استخدام نسب مئوية للهوامش
      //                       padding: EdgeInsets.all(ScreenSize.getWidth(1.5)),
      //                       decoration: BoxDecoration(
      //                         color: red,
      //                         // 💡 استخدام نسب مئوية لنصف قطر الحدود
      //                         borderRadius: BorderRadius.circular(ScreenSize.getWidth(2.5)),
      //                       ),
      //                       child: Text(
      //                         conversation.unreadMessagesCount.toString(),
      //                         style: TextStyle(
      //                           color: white,
      //                           // 💡 استخدام نسب مئوية لحجم الخط
      //                           fontSize: ScreenSize.getWidth(3),
      //                         ),
      //                       ),
      //                     )
      //                   : null,
      //               onTap: () {
      //                 Navigator.push(
      //                   context,
      //                   MaterialPageRoute(
      //                     builder: (context) => ChatMessageScreen(
      //                       conversation: conversation,
      //                     ),
      //                   ),
      //                 ).then((_) {
      //                   _fetchConversations();
      //                 });
      //               },
      //             ),
      //           );
      //         },
      //       );
      //     }
      //   },
      // ),
   
   
    );
  }
}