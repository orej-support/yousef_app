
import 'package:flutter/material.dart';
import 'package:youseuf_app/View/Screens/Sheared/chat/chat_message_screen.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/icons.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد
import 'package:youseuf_app/models/user.dart';
import 'package:youseuf_app/models/specialist.dart';
import 'package:youseuf_app/services/api_service.dart';
import 'package:youseuf_app/models/conversation.dart';
import 'package:provider/provider.dart';

class CreateGroupChatPage extends StatefulWidget {
  final List<dynamic> selectedParticipants;

  const CreateGroupChatPage({super.key, required this.selectedParticipants});

  @override
  State<CreateGroupChatPage> createState() => _CreateGroupChatPageState();
}

class _CreateGroupChatPageState extends State<CreateGroupChatPage> {
  final TextEditingController _groupNameController = TextEditingController();
  late ApiService _apiService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 💡 تهيئة ApiService هنا في initState
    _apiService = ApiService();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }
Future<void> _createGroupChat() async {
  final apiService = Provider.of<ApiService>(context, listen: false);

  if (_groupNameController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('الرجاء إدخال اسم للمجموعة.')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final List<Map<String, dynamic>> participantsData = [];
    final String? currentUserId = await apiService.getCurrentUserId();
    final String? currentUserType = await apiService.getUserType();

    for (var p in widget.selectedParticipants) {
      if (p is User) {
        participantsData.add({'id': p.id, 'type': 'App\\Models\\User'});
      } else if (p is Specialist) {
        participantsData.add({'id': p.id, 'type': 'App\\Models\\Specialist'});
      }
    }

    if (currentUserId != null && currentUserType != null) {
      bool alreadyIncluded = participantsData.any(
        (p) => p['id'].toString() == currentUserId,
      );
      if (!alreadyIncluded) {
        participantsData.add({
          'id': int.parse(currentUserId),
          'type': currentUserType,
        });
      }
    }

    final Conversation? newConversation = await apiService.createGroupConversation(
      name: _groupNameController.text.trim(),
      participants: participantsData,
    );

    if (!mounted || newConversation == null) return;

    // ✅ تنبيه بالنجاح
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إنشاء المحادثة بنجاح ✅')),
    );

    Navigator.pop(context, true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatMessageScreen(conversation: newConversation),
      ),
    );
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل إنشاء المحادثة الجماعية. حاول لاحقاً.')),
      );
    }
    debugPrint('Error creating group chat: $e');
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  // Future<void> _createGroupChat() async {
  //   final apiService = Provider.of<ApiService>(context, listen: false);

  //   if (_groupNameController.text.trim().isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('الرجاء إدخال اسم للمجموعة.')),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final List<Map<String, dynamic>> participantsData = [];
  //     final String? currentUserId = await apiService.getCurrentUserId();
  //     final String? currentUserType = await apiService.getUserType();

  //     for (var p in widget.selectedParticipants) {
  //       String type;
  //       if (p is User) {
  //         type = 'App\\Models\\User';
  //       } else if (p is Specialist) {
  //         type = 'App\\Models\\Specialist';
  //       } else {
  //         continue;
  //       }
  //       participantsData.add({'id': p.id, 'type': type});
  //     }

  //     if (currentUserId != null && currentUserType != null) {
  //       bool isCurrentUserAlreadySelected =
  //           participantsData.any((p) => p['id'].toString() == currentUserId);
  //       if (!isCurrentUserAlreadySelected) {
  //         participantsData
  //             .add({'id': int.parse(currentUserId), 'type': currentUserType});
  //       }
  //     }

  //     final Conversation? newConversation = await apiService.createGroupConversation(
  //       name: _groupNameController.text.trim(),
  //       participants: participantsData,
  //     );

  //     if (!mounted) return;

  //     Navigator.pop(context, true);
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => ChatMessageScreen(conversation: newConversation!),
  //       ),
  //     );
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('فشل إنشاء المحادثة الجماعية: ${e.toString()}'),
  //         ),
  //       );
  //     }
  //     debugPrint('Error creating group chat: $e');
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إنشاء محادثة جماعية جديدة',
          style: TextStyle(color: white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: white),
      ),
      body: Padding(
        // 💡 استخدام نسب مئوية للهوامش
        padding: EdgeInsets.all(ScreenSize.getWidth(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'اسم المجموعة',
                border: OutlineInputBorder(
                  // 💡 استخدام نسب مئوية لنصف القطر
                  borderRadius: BorderRadius.circular(ScreenSize.getWidth(2.5)),
                ),
              ),
            ),
            SizedBox(height: ScreenSize.getHeight(2.5)), // 💡 استخدام نسبة مئوية
            Text(
              'المشاركون المختارون (${widget.selectedParticipants.length}):',
              style: TextStyle(
                // 💡 استخدام نسب مئوية لحجم الخط
                fontSize: ScreenSize.getWidth(4),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ScreenSize.getHeight(1.2)), // 💡 استخدام نسبة مئوية
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedParticipants.length,
                itemBuilder: (context, index) {
                  final participant = widget.selectedParticipants[index];
                  String participantName = participant.name ?? 'غير معروف';
                  String participantType = participant is User
                      ? 'مستخدم'
                      : (participant is Specialist ? 'أخصائي' : '');

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).secondaryHeaderColor,
                      // 💡 استخدام نسب مئوية لنصف القطر
                      radius: ScreenSize.getWidth(6),
                      child: Text(
                        participantName.isNotEmpty
                            ? participantName[0].toUpperCase()
                            : '?',
                        style: TextStyle(color: white),
                      ),
                    ),
                    title: Text(participantName),
                    subtitle: Text(participantType),
                  );
                },
              ),
            ),
            SizedBox(height: ScreenSize.getHeight(2.5)),
            _isLoading
                ?  Center(child: CircularProgressIndicator(color: blue,))
                : ElevatedButton.icon(
                    onPressed: _createGroupChat,
                    icon: const Icon(AppIcons.groupAdd),
                    label: const Text('إنشاء محادثة جماعية'),
                    style: ElevatedButton.styleFrom(
                      // 💡 استخدام نسب مئوية للأبعاد
                      minimumSize: Size(
                        ScreenSize.getWidth(90),
                        ScreenSize.getHeight(6),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: white,
                      shape: RoundedRectangleBorder(
                        // 💡 استخدام نسب مئوية لنصف القطر
                        borderRadius: BorderRadius.circular(ScreenSize.getWidth(2.5)),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}