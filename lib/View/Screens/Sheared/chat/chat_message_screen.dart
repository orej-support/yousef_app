
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/icons.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد
import 'package:youseuf_app/models/conversation.dart';
import 'package:youseuf_app/models/message.dart';
import 'package:youseuf_app/services/api_service.dart';
import 'package:youseuf_app/services/pusher_service.dart';
import 'package:youseuf_app/View/widget/Sheared/back_leading.dart';

class ChatMessageScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatMessageScreen({super.key, required this.conversation});

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  final List<Message> _messages = [];
  late final PusherService _pusherService;
  StreamSubscription? _pusherSubscription;

  String? _currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    _pusherService = Provider.of<PusherService>(context, listen: false);
    _currentUserId = await _apiService.getCurrentUserId();
    await _fetchMessages();
    await _markConversationAsRead();

    await _pusherService.subscribeToConversationChannel(
      widget.conversation.id.toString(),
    );

    _pusherSubscription = _pusherService.eventsStream.listen((event) {
      if (event.channelName ==
          'private-conversation.${widget.conversation.id}') {
        debugPrint('📨 Received event: ${event.eventName}');
        debugPrint('📦 Event data: ${event.data}');
        _handleIncomingMessage(event.data);
      }
    });

    setState(() => _isLoading = false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }
Future<void> _fetchMessages() async {
  try {
    final messages = await _apiService.getConversationMessages(
        widget.conversation.id);

    messages.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    setState(() {
      _messages.clear();
      _messages.addAll(messages);
      _isLoading = false;
    });

    _scrollToBottom();
  } catch (e) {
    debugPrint("Error fetching messages: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل جلب الرسائل: $e')),
      );
    }
    setState(() => _isLoading = false);
  }
}

  // Future<void> _fetchMessages() async {
  //   try {
  //     final messages = await _apiService.getConversationMessages(
  //         widget.conversation.id);

  //     messages.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
  //     setState(() {
  //       _messages.clear();
  //       _messages.addAll(messages);
  //       _isLoading = false;
  //     });

  //     _scrollToBottom();
  //   } catch (e) {
  //     debugPrint("Error fetching messages: $e");
  //   }
  // }

  Future<void> _markConversationAsRead() async {
    debugPrint('ChatMessageScreen: _markConversationAsRead started.');
    try {
      if (widget.conversation.id != null) {
        await _apiService.markConversationAsRead(widget.conversation.id!);
        debugPrint(
            'ChatMessageScreen: Conversation ${widget.conversation.id} marked as read.');
      }
    } catch (e) {
      debugPrint('ChatMessageScreen: Error marking conversation as read: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل وسم المحادثة كمقروءة: ${e.toString()}')),
        );
      }
    }
    debugPrint('ChatMessageScreen: _markConversationAsRead finished.');
  }

  void _handleIncomingMessage(String jsonData) {
  try {
    final decoded = json.decode(jsonData);
    final newMessage = Message.fromJson(decoded);

    bool isAlreadyAdded = _messages.any((msg) => msg.id == newMessage.id);

    if (!isAlreadyAdded) {
      setState(() {
        _messages.add(newMessage);
      });
      _scrollToBottom();
      debugPrint(
          'Received and added new message from Pusher: ${newMessage.content}');
    }
  } catch (e) {
    debugPrint("Error parsing incoming message: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في استلام الرسالة: $e')),
      );
    }
  }
}

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // Future<void> _sendMessage() async {
  //   final text = _messageController.text.trim();
  //   if (text.isEmpty) return;
  //   try {
  //     await _apiService.sendMessage(
  //       conversationId: widget.conversation.id,
  //       content: text,
  //     );
  //     _messageController.clear();
  //     await Future.delayed(const Duration(seconds: 3));
  //     debugPrint(
  //         "⌛ Message sent. Waiting to see if it will be received again from Pusher...");
  //   } catch (e) {
  //     debugPrint("Error sending message: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('فشل إرسال الرسالة: ${e.toString()}')),
  //     );
  //   }
  // }
Future<void> _sendMessage() async {
  final text = _messageController.text.trim();
  if (text.isEmpty) return;
  try {
    await _apiService.sendMessage(
      conversationId: widget.conversation.id,
      content: text,
    );
    _messageController.clear();
    await Future.delayed(const Duration(seconds: 3));
    debugPrint("⌛ Message sent. Waiting to see if it will be received again from Pusher...");
  } catch (e) {
    debugPrint("Error sending message: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إرسال الرسالة: $e')),
      );
    }
  }
}

  @override
  void dispose() {
    _pusherSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMessageItem(Message message) {
    final isMe = message.senderId.toString() == (_currentUserId ?? '').toString();
    final formattedTime = message.createdAt != null
        ? DateFormat('dd\\MM\\yyyy - h:mm a').format(message.createdAt!)
        : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        // 💡 استخدام نسب مئوية للهوامش
        margin: EdgeInsets.symmetric(
          vertical: ScreenSize.getHeight(0.5),
          horizontal: ScreenSize.getWidth(3),
        ),
        // 💡 استخدام نسب مئوية للهوامش الداخلية
        padding: EdgeInsets.all(ScreenSize.getWidth(3)),
        decoration: BoxDecoration(
          color: isMe ? lightBlue : grey300,
          // 💡 استخدام نسب مئوية لنصف القطر
          borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content ?? '',
              // 💡 استخدام نسب مئوية لحجم الخط
              style: TextStyle(fontSize: ScreenSize.getWidth(4)),
            ),
            SizedBox(height: ScreenSize.getHeight(0.5)),
            Text(
              formattedTime,
              style: TextStyle(
                // 💡 استخدام نسب مئوية لحجم الخط
                fontSize: ScreenSize.getWidth(2.5),
                color: grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    final displayName = widget.conversation.name ?? 'المحادثة';

    return Scaffold(
      backgroundColor: backgroundcolor,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ رأس الصفحة المخصص
            Container(
              // 💡 استخدام نسب مئوية للهوامش
              padding: EdgeInsets.only(
                top: ScreenSize.getHeight(2),
                bottom: ScreenSize.getHeight(1.5),
              ),
              color: lightPink,
              child: Column(
                children: [
                  SizedBox(height: ScreenSize.getHeight(1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        // 💡 استخدام نسب مئوية للهوامش
                        padding: EdgeInsets.only(bottom: ScreenSize.getHeight(1)),
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: BackLeading(),
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: blue,
                        // 💡 استخدام نسب مئوية لنصف القطر
                        radius: ScreenSize.getWidth(4),
                        child: Icon(
                          AppIcons.person,
                          color: white,
                          // 💡 استخدام نسب مئوية لحجم الأيقونة
                          size: ScreenSize.getWidth(4.5),
                        ),
                      ),
                      SizedBox(width: ScreenSize.getWidth(2)),
                      Text(
                        displayName,
                        // 💡 استخدام نسب مئوية لحجم الخط
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenSize.getWidth(4.5)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ?  Center(child: CircularProgressIndicator(color: blue,))
                  : Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.only(
                          top: ScreenSize.getHeight(1.5),
                          bottom: ScreenSize.getHeight(1.5),
                        ),
                        itemCount: _buildGroupedMessages().length,
                        itemBuilder: (context, index) {
                          final item = _buildGroupedMessages()[index];
                          if (item is String) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: ScreenSize.getHeight(1.5)),
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ScreenSize.getWidth(3),
                                    vertical: ScreenSize.getHeight(0.7),
                                  ),
                                  decoration: BoxDecoration(
                                    color: grey200,
                                    borderRadius: BorderRadius.circular(ScreenSize.getWidth(5)),
                                  ),
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      color: black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: ScreenSize.getWidth(3.5),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else if (item is Message) {
                            return _buildMessageBubble(item);
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenSize.getWidth(3),
                vertical: ScreenSize.getHeight(1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: ScreenSize.getWidth(3)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ScreenSize.getWidth(7.5)),
                        color: white,
                        border: Border.all(color: grey300),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "اكتب هنا...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenSize.getWidth(2)),
                  CircleAvatar(
                    backgroundColor: lightBlue2,
                    // 💡 استخدام نسب مئوية لنصف القطر
                    radius: ScreenSize.getWidth(6),
                    child: IconButton(
                      icon: Icon(AppIcons.send, color: white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _buildGroupedMessages() {
    final Map<String, List<Message>> grouped = {};
    for (var msg in _messages) {
      final dateKey = DateFormat('dd/MM/yyyy').format(msg.createdAt!);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(msg);
    }
    final List<dynamic> result = [];
    grouped.forEach((date, messages) {
      result.add(date);
      result.addAll(messages);
    });
    return result;
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.senderId.toString() == (_currentUserId ?? '');
    final formattedTime = message.createdAt != null
        ? DateFormat('hh:mm a').format(message.createdAt!)
        : '';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ScreenSize.getWidth(3),
          vertical: ScreenSize.getHeight(0.5),
        ),
        padding: EdgeInsets.all(ScreenSize.getWidth(3)),
        // 💡 استخدام نسبة مئوية بدلاً من قيمة ثابتة لـ maxWidth
        constraints: BoxConstraints(
          maxWidth: ScreenSize.getWidth(70),
        ),
        decoration: BoxDecoration(
          color: isMe ? lightBlue2 : lightPink,
          borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content ?? '',
              style: TextStyle(
                fontSize: ScreenSize.getWidth(4),
                color: isMe ? white : black,
              ),
            ),
            SizedBox(height: ScreenSize.getHeight(0.5)),
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: ScreenSize.getWidth(2.5),
                color: isMe ? white70 : grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
