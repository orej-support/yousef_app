import 'package:flutter/material.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/icons.dart';

// قيمة ثابتة لتحديد عرض الأيقونة مع النص في AppBar
const double kBackLeadingWidth = 120.0;

class BackLeading extends StatelessWidget {
  const BackLeading({super.key});

  @override
  Widget build(BuildContext context) {
    // التحقق من اتجاه النص الحالي
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final Color color = blue;

    // تحديد اتجاه الأيقونة بناءً على اتجاه النص (RTL/LTR)
    final IconData arrowIcon =
        isRTL ? AppIcons.arrowForwardIosRounded : AppIcons.arrowBack;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).maybePop(),
        child:
        Icon(
              arrowIcon,
              color: color,
            ),
      ),
    );
  }
}