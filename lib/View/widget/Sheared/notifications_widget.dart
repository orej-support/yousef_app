import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationWidget extends StatelessWidget {
  final String text;
  final String date;
  final bool isRead;
  final String notificationId;

  const NotificationWidget({
    super.key,
    required this.text,
    required this.date,
    required this.isRead,
    required this.notificationId,
  });

  @override
  Widget build(BuildContext context) {
    final parsedDate = DateTime.tryParse(date);
    final formattedDate = parsedDate != null
        ? DateFormat('yyyy/MM/dd HH:mm').format(parsedDate)
        : date;

    // لا حاجة لـ GestureDetector لأنه لا يوجد تفاعل عند النقر
    // يمكنك استبداله بـ Container أو أي ودجت آخر
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey.shade200 : Colors.white,
        border: Border(
          right: BorderSide(
            color: isRead ? Colors.transparent : Colors.blue,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isRead)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                "غير مقروء",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}