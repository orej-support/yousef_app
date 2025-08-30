// lib/View/widget/Sheared/list_item.dart

import 'package:flutter/material.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/icons.dart';

class ListItem extends StatelessWidget {
  final String? id;
  final String title;
  final String value;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? actionLabel;

  const ListItem({
    super.key,
    this.id,
    required this.title,
    required this.value,
    this.icon,
    this.onTap,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey(id),
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(
                  icon ?? AppIcons.person,
                  color: blue,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "$title: ",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: value,
                        style: TextStyle(
                          color: blue,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (onTap != null && actionLabel != null)
              TextButton(
                onPressed: onTap,
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      actionLabel!,
                      style: TextStyle(
                        color: blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(AppIcons.chevronLeft, color: blue),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
