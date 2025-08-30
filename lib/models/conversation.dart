// lib/models/conversation.dart
import 'package:flutter/foundation.dart';
import 'package:youseuf_app/models/specialist.dart';
import 'package:youseuf_app/models/user.dart'; // لا تنسى استيراد هذه المكتبة لـ debugPrint

class Conversation {
  final int id;
  final String? name;
  final String type;
  final bool isGroup;
  final String? lastMessageContent;
  final String? lastMessageSenderName;
  final DateTime? lastMessageCreatedAt;
  final int unreadMessagesCount;
  final List<dynamic> participants;
  final dynamic otherParticipant;
  final DateTime createdAt;
  final String? lastMessageSenderId; // ✅ جديد

  Conversation({
    this.lastMessageSenderId,
    required this.id,
    this.name,
    required this.type,
    required this.isGroup,
    this.lastMessageContent,
    this.lastMessageSenderName,
    this.lastMessageCreatedAt,
    this.unreadMessagesCount = 0,
    required this.participants,
    this.otherParticipant,
    required this.createdAt,
  });
    /// يُرجع عدد غير المقروء "الوارد فقط" بناءً على آخر مرسل معروف.
  int incomingUnreadToShow(String myId, {int? unreadIncomingCountFromApi}) {
    // لو مستقبلاً ضفت في الـ API حقل unread_incoming_count استخدمه مباشرة:
    if (unreadIncomingCountFromApi != null) return unreadIncomingCountFromApi;

    // fallback: لو آخر رسالة مني، لا تعرض عدّاد
    if ((lastMessageSenderId ?? '') == myId) return 0;

    // وإلا اعرض العدّاد القادم من API كما هو
    return unreadMessagesCount;
  }


  factory Conversation.fromJson(Map<String, dynamic> json) {
    final String conversationType = json['type'] as String? ?? 'private';
    final bool isConversationGroup = json['is_group'] as bool? ??
        false; // هذا هو السطر الذي يُحتمل أن يسبب المشكلة

    final Map<String, dynamic>? lastMessageJson = json['last_message'];
    DateTime? parsedLastMessageCreatedAt;
    if (lastMessageJson != null && lastMessageJson['created_at'] != null) {
      try {
        parsedLastMessageCreatedAt =
            DateTime.parse(lastMessageJson['created_at'] as String);
      } catch (e) {
        // debugPrint('Error parsing last_message_created_at: $e');
      }
    }

    // 3. تحليل قائمة المشاركين (participants)
    final List<dynamic> participantsJson =
        json['participants'] as List<dynamic>;
    final List<dynamic> parsedParticipants = [];
    for (var pJson in participantsJson) {
      final String participantType =
          pJson['type'] as String? ?? 'unknown'; // تأمين ضد null
      if (participantType == 'user') {
        parsedParticipants.add(User.fromJson(pJson as Map<String, dynamic>));
      } else if (participantType == 'specialist') {
        parsedParticipants
            .add(Specialist.fromJson(pJson as Map<String, dynamic>));
      }
    }

    // 4. تحليل الطرف الآخر (other_participant)
    dynamic parsedOtherParticipant;
    final Map<String, dynamic>? otherParticipantJson =
        json['other_participant'];
    if (otherParticipantJson != null) {
      final String otherParticipantType =
          otherParticipantJson['type'] as String? ?? 'unknown'; // تأمين ضد null
      if (otherParticipantType == 'user') {
        parsedOtherParticipant = User.fromJson(otherParticipantJson);
      } else if (otherParticipantType == 'specialist') {
        parsedOtherParticipant = Specialist.fromJson(otherParticipantJson);
      }
    }

    // 5. تحليل تاريخ إنشاء المحادثة نفسه (created_at)
    final DateTime parsedCreatedAt = DateTime.parse(
        json['created_at'] as String); // يفترض أن هذا الحقل موجود دائماً

    return Conversation(
      id: json['id'] as int,
      name: json['name'] as String?,
      type: conversationType,
      isGroup: isConversationGroup,
      lastMessageContent: lastMessageJson?['content'] as String?,
      lastMessageSenderName: lastMessageJson?['sender_name'] as String?,
      lastMessageCreatedAt: parsedLastMessageCreatedAt,
      lastMessageSenderId: lastMessageJson?['sender_id']?.toString(), // ✅ جديد

      unreadMessagesCount: json['unseen_messages_count'] as int? ?? 0,
      participants: parsedParticipants,
      otherParticipant: parsedOtherParticipant,
      createdAt: parsedCreatedAt,
    );
  }

}
