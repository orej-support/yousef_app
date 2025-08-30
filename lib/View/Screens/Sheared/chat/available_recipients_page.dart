import 'package:flutter/material.dart';
import 'package:youseuf_app/View/Screens/Sheared/chat/chat_message_screen.dart';
import 'package:youseuf_app/View/Screens/Sheared/chat/create_group_chat_page.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart';
import 'package:youseuf_app/core/utils/icons.dart';
import 'package:youseuf_app/services/api_service.dart';
import 'package:youseuf_app/models/user.dart';
import 'package:youseuf_app/models/specialist.dart';
import 'package:youseuf_app/models/conversation.dart';
import 'package:provider/provider.dart';

class AvailableRecipientsPage extends StatefulWidget {
  final bool initialForGroupChat;

  const AvailableRecipientsPage({
    super.key,
    this.initialForGroupChat = false,
  });

  @override
  State<AvailableRecipientsPage> createState() =>
      _AvailableRecipientsPageState();
}

class _AvailableRecipientsPageState extends State<AvailableRecipientsPage> {
  late ApiService _apiService;

  List<dynamic> _recipients = [];
  bool _isLoading = true;
  String _errorMessage = '';

  bool _isGroupSelectionMode = false;
  bool _canCreateGroup = false;

  final List<dynamic> _selectedParticipants = [];

  @override
  void initState() {
    super.initState();
    _isGroupSelectionMode = widget.initialForGroupChat;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _apiService = Provider.of<ApiService>(context, listen: false);
      _checkUserPermissionAndFetchRecipients();
    });
  }
Future<void> _checkUserPermissionAndFetchRecipients() async {
  try {
    final currentUserType = await _apiService.getUserType();
    setState(() {
      _canCreateGroup = currentUserType == 'user';
    });
  } catch (e) {
    debugPrint('Error checking user type permission: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التحقق من صلاحيات المستخدم: $e')),
      );
    }
    setState(() {
      _canCreateGroup = false;
    });
  } finally {
    _fetchAvailableRecipients();
  }
}

Future<void> _fetchAvailableRecipients() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });
  try {
    final List<dynamic> fetchedRecipients =
        await _apiService.getAvailableChatRecipients();
    setState(() {
      _recipients = fetchedRecipients;
      _recipients.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    });
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل جلب جهات الاتصال: $e')),
      );
    }
    setState(() {
      _errorMessage = 'فشل جلب جهات الاتصال: ${e.toString()}';
    });
    debugPrint('Error fetching recipients: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  // Future<void> _checkUserPermissionAndFetchRecipients() async {
  //   try {
  //     final currentUserType = await _apiService.getUserType();
  //     setState(() {
  //       _canCreateGroup = currentUserType == 'user';
  //     });
  //   } catch (e) {
  //     debugPrint('Error checking user type permission: $e');
  //     setState(() {
  //       _canCreateGroup = false;
  //     });
  //   } finally {
  //     _fetchAvailableRecipients();
  //   }
  // }

  // Future<void> _fetchAvailableRecipients() async {
  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = '';
  //   });
  //   try {
  //     final List<dynamic> fetchedRecipients =
  //         await _apiService.getAvailableChatRecipients();
  //     setState(() {
  //       _recipients = fetchedRecipients;
  //       _recipients.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = 'فشل جلب جهات الاتصال: ${e.toString()}';
  //     });
  //     debugPrint('Error fetching recipients: $e');
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  void _createIndividualChat(dynamic recipient) async {
    try {
      final String recipientId = recipient.id.toString();
      String recipientType;

      if (recipient is User) {
        recipientType = 'user';
      } else if (recipient is Specialist) {
        recipientType = 'specialist';
      } else {
        throw Exception('نوع المستلم غير معروف.');
      }

      final Conversation? newConversation =
          await _apiService.createPrivateConversation(
        recipientId: recipientId,
        recipientType: recipientType,
      );

      // 💡 تأكد أن الشاشة لا تزال موجودة قبل القيام بأي عملية تنقل
      if (!mounted) return;

      // Navigator.pop(context); // ⚠️ إزالة هذا السطر لأن pushReplacement سيقوم بالمهمة
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChatMessageScreen(conversation: newConversation!),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل بدء المحادثة: ${e.toString()}')),
        );
      }
      debugPrint('Error creating individual chat: $e');
    }
  }

  void _navigateToCreateGroupChatPage() async {
    final List<dynamic> selectedUsers =
        _selectedParticipants.whereType<User>().toList();

    if (selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('الرجاء اختيار مستخدم واحد على الأقل للمجموعة.')),
      );
      return;
    }

    if (!mounted) return;
    final bool? groupChatCreated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateGroupChatPage(selectedParticipants: selectedUsers),
      ),
    );

    if (groupChatCreated == true) {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 قم بتهيئة كلاس ScreenSize هنا
    ScreenSize.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isGroupSelectionMode
              ? 'اختر المشاركين للمجموعة'
              : 'جهات اتصال جديدة',
          style: TextStyle(color: blue),
        ),
        backgroundColor: lightPink,
        iconTheme: IconThemeData(color: blue),
        actions: [
          if (_canCreateGroup)
            IconButton(
              icon: Icon(
                _isGroupSelectionMode
                    ? AppIcons.personAddDisabled
                    : AppIcons.groupAdd,
                color: blue,
              ),
              tooltip: _isGroupSelectionMode
                  ? 'العودة للمحادثات الفردية'
                  : 'بدء محادثة جماعية',
              onPressed: () {
                setState(() {
                  _isGroupSelectionMode = !_isGroupSelectionMode;
                  _selectedParticipants.clear();
                });
              },
            ),
          if (_isGroupSelectionMode && _selectedParticipants.isNotEmpty)
            IconButton(
              icon: Icon(AppIcons.arrowForward, color: blue),
              onPressed: _navigateToCreateGroupChatPage,
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: blue,
            ))
          : _errorMessage.isNotEmpty
              ? Center(
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
                        SizedBox(height: ScreenSize.getHeight(3)),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: red,
                            fontSize:
                                ScreenSize.getWidth(4.5), // تم تحويل القيمة
                          ),
                        ),
                        SizedBox(
                            height: ScreenSize.getHeight(3)), // تم تحويل القيمة
                        ElevatedButton.icon(
                          onPressed: _fetchAvailableRecipients,
                          icon: const Icon(AppIcons.replay),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : _recipients.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppIcons.infoOutline,
                            color: grey,
                            size: ScreenSize.getWidth(12),
                          ),
                          SizedBox(height: ScreenSize.getHeight(3)),
                          Text(
                            'لا يوجد أخصائيون أو مستخدمون متاحون للبدء محادثة معهم.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize:
                                  ScreenSize.getWidth(4.5), // تم تحويل القيمة
                              color: darkgrey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _recipients.length,
                      itemBuilder: (context, index) {
                        final recipient = _recipients[index];
                        if (recipient.id == null || recipient.name == null) {
                          return const SizedBox.shrink();
                        }

                        final isSelected =
                            _selectedParticipants.contains(recipient);
                        String name = recipient.name;
                        String subtitle = '';
                        String avatarText =
                            name.isNotEmpty ? name[0].toUpperCase() : '?';

                        if (recipient is User) {
                          subtitle = 'مستخدم';
                        } else if (recipient is Specialist) {
                          subtitle = recipient.type ?? 'أخصائي';
                        }

                        return Directionality(
                          textDirection: TextDirection.rtl,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).secondaryHeaderColor,
                              // استخدام نسبة مئوية لنصف قطر الدائرة لضمان التجاوب
                              radius: ScreenSize.getWidth(6),
                              child: Text(
                                avatarText,
                                style: TextStyle(
                                  color: white,
                                  fontSize: ScreenSize.getWidth(5),
                                ),
                              ),
                            ),
                            title: Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(subtitle),
                            trailing: _isGroupSelectionMode && _canCreateGroup
                                ? Checkbox(
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedParticipants.add(recipient);
                                        } else {
                                          _selectedParticipants
                                              .remove(recipient);
                                        }
                                      });
                                    },
                                  )
                                : null,
                            onTap: () {
                              if (_isGroupSelectionMode && _canCreateGroup) {
                                setState(() {
                                  if (isSelected) {
                                    _selectedParticipants.remove(recipient);
                                  } else {
                                    _selectedParticipants.add(recipient);
                                  }
                                });
                              } else {
                                _createIndividualChat(recipient);
                              }
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: _isGroupSelectionMode &&
              _selectedParticipants.isNotEmpty &&
              _canCreateGroup
          ? FloatingActionButton.extended(
              onPressed: _navigateToCreateGroupChatPage,
              label: Text('متابعة لإنشاء المجموعة',
                  style: TextStyle(color: white)),
              icon: Icon(AppIcons.arrowForward, color: blue),
              backgroundColor: Theme.of(context).primaryColor,
            )
          : null,
    );
  }
}
