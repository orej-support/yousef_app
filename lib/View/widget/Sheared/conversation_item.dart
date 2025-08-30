// في ملف conversation_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/icons.dart';
import 'package:youseuf_app/models/conversation.dart';

class ConversationItem extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final String? currentUserId;

  const ConversationItem({
    this.currentUserId,
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName = conversation.name ??
        conversation.otherParticipant?.name ??
        (conversation.isGroup ? 'مجموعة' : 'محادثة');

    final String lastMessage = conversation.lastMessageContent ?? '';
    final String time = conversation.lastMessageCreatedAt != null
        ? intl.DateFormat('hh:mm a').format(conversation.lastMessageCreatedAt!)
        : '';

    // تأمين المقارنة كسلاسل
    final myId = (currentUserId ?? '').toString();

    // لو لاحقًا رجّعت من الـ API unread_incoming_count مرّره هنا بدل null
    final int unreadToShow = conversation.incomingUnreadToShow(
      myId,
      // unreadIncomingCountFromApi: conversation.unreadIncomingCount,
    );

    final bool hasUnread = unreadToShow > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: hasUnread ? faFAFA : transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        child: Column(
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: blue,
                    child:  Icon(AppIcons.person, color: white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lastMessage,
                          style:  TextStyle(
                            fontSize: 12,
                            color: black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        time,
                        style:  TextStyle(
                          fontSize: 11,
                          color: grey,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:  yellow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            unreadToShow.toString(),
                            style:  TextStyle(
                              fontSize: 10,
                              color: white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 25),
          ],
        ),
      ),
    );
  }
}
