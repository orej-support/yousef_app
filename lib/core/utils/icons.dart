import 'package:flutter/material.dart';
import 'package:youseuf_app/core/theme/app_colors.dart'; // لاستخدام blue
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/theme/app_colors.dart' as C;

class AppIcons {
  // IconData ثابتة لإعادة الاستخدام
  static const IconData dashboard = Icons.dashboard; // للاقسام
  static const IconData reports = Icons.folder_copy; // للتقارير
  static const IconData person = Icons.person; // مستخدم
  static const IconData group = Icons.groups_2; //مجموعة اشخاص
  static const IconData groupAdd = Icons.group_add; // اضافة مجموعة
  static const IconData logout = Icons.logout; // تسجيل خروج
  static const IconData personAddDisabled =
      Icons.person_add_disabled; // لايمكن المستخمد اضافة
  static const IconData arrowForward = Icons.arrow_forward; // السهم للأمام
  static const IconData errorOutline = Icons.error_outline; //  خطأ
  static const IconData replay = Icons.replay; // اعادة
  static const IconData infoOutline = Icons.info_outline; // معلومة
  static const IconData addComment = Icons.add_comment; // اضافة تعليق
  static const IconData refresh = Icons.refresh; //اعادة تحميل
  static const IconData send = Icons.send; // ارسال
  static const IconData arrowBack =
      Icons.arrow_back_ios_new_rounded; // السهم للخلف
  static const IconData chevronLeft = Icons.chevron_left_rounded;
  static const IconData chevronRight = Icons.chevron_right_rounded; // سهم لليمين
  static const IconData badge = Icons.brightness_1; // شارة
  static const IconData emailOutlined = Icons.email_outlined; // ايميل
  static const IconData phone = Icons.phone; // جوال
  static const IconData personOutline = Icons.person_outline; // مستخدم فقط حدود
  static const IconData edit = Icons.edit; // تعديل
  static const IconData close = Icons.close; // اغلاق
  static const IconData description = Icons.description; // محتوى
  static const IconData powerSettingsNew = Icons.power_settings_new; // خروج
  static const IconData locationOn = Icons.location_on; // موقع
  static const IconData arrowForwardIosRounded =
      Icons.arrow_forward_ios_rounded; // سهم للأمام
  static const IconData visibility = Icons.visibility; // عين
  static const IconData libraryBooks = Icons.library_books; // مكتبة
  static const IconData wechatRounded = Icons.wechat_rounded; // محادثة
  static const IconData menuBook = Icons.menu_book; // قائمة كتب
  static const IconData personOutlineRounded =
      Icons.person_outline_rounded; // مستخدم
  static const IconData brokenImage = Icons.broken_image; // صورة
  static const IconData playCircleFill = Icons.play_circle_fill; // تشغيل فيديو
  static const IconData insertDriveFile = Icons.insert_drive_file; // ملف
  static const IconData add = Icons.add; // إضافة
  static const IconData accountCircle = Icons.account_circle; // حساب
  // مُنشئ أفاتار دائري موحّد
 static Widget circleAvatar(
    IconData icon, {
    double radius = 18,
    Color? bg,            // ← بدون default غير ثابت
    Color? iconColor,     // ← بدون default غير ثابت
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg ?? C.blue,          // ← نفرض الافتراضي هنا
      child: Icon(icon, color: iconColor ?? C.white, size: radius + 2),
    );
  }
  static Widget circleAvatarWithBadge(
    IconData icon, {
    int? badge,
    double radius = 18,
    Color? bg,
    Color? iconColor,
  }) {
    final base = circleAvatar(icon, radius: radius, bg: bg, iconColor: iconColor);
    if (badge == null || badge <= 0) return base;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        base,
        Positioned(
          top: -2, left: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: red,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color:white, width: 1),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text('$badge',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: white, height: 1.1),
            ),
          ),
        ),
      ],
    );
  }

}
