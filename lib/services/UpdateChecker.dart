// lib/services/update_checker.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  static const String versionUrl =
      "https://raw.githubusercontent.com/orej-support/update-checker/main/version.json";

  /// مهلة الشبكة
  static const Duration _timeout = Duration(seconds: 10);

  /// التحقق من وجود تحديث.
  /// يعرض Dialog عند توفر تحديث ويُرجع:
  /// - false: تم عرض نافذة التحديث (أوقف الانتقال)
  /// - true : لا يوجد تحديث (أكمل الانتقال)
  Future<bool> checkForUpdate(BuildContext context) async {
    try {
      // 1) اجلب رقم إصدار التطبيق الحالي من pubspec.yaml تلقائيًا
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version.trim();
       print("إصدار التطبيق: ${info.version}");

      // 2) اطلب ملف JSON الخاص بالتحديث
      final res = await http
          .get(Uri.parse(_cacheBusted(versionUrl)))
          .timeout(_timeout);

      if (res.statusCode != 200) {
        debugPrint("فشل قراءة version.json: status=${res.statusCode}");
        return true; // لا توقف الرحلة لو فشل جلب الملف
      }

      // 3) فك JSON
      final map = json.decode(res.body);
      final latestVersion = (map['version'] as String?)?.trim();
      final apkUrl = (map['apk_url'] as String?)?.trim();

      if (latestVersion == null || latestVersion.isEmpty || apkUrl == null || apkUrl.isEmpty) {
        debugPrint("version.json غير صالح: الحقول مفقودة");
        return true;
      }

      // 4) قارن الإصدارات بطريقة Semantic Versioning
      final cmp = _compareSemver(latestVersion, currentVersion);

      // إذا latest > current → اعرض التحديث
      if (cmp > 0) {
        await _showUpdateDialog(context, latestVersion, apkUrl);
        return false;
      }

      // لا يوجد تحديث
      return true;
    } on TimeoutException {
      debugPrint("انتهت مهلة طلب التحديث");
      return true;
    } catch (e) {
      debugPrint("خطأ أثناء التحقق من التحديث: $e");
      return true;
    }
  }

  /// Dialog التحديث مع محاولات فتح الرابط
  Future<void> _showUpdateDialog(
      BuildContext context, String latestVersion, String apkUrl) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('تحديث متاح'),
        content: Text(
          'يتوفر إصدار جديد من التطبيق ($latestVersion). هل ترغب في التحديث الآن؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // لاحقًا
            child: const Text('لاحقًا'),
          ),
          TextButton(
            onPressed: () async {
              final uri = Uri.parse(apkUrl);

              Future<bool> tryOpen(LaunchMode mode) async {
                try {
                  return await launchUrl(uri, mode: mode);
                } catch (_) {
                  return false;
                }
              }

              bool ok = await tryOpen(LaunchMode.externalApplication);
              if (!ok) ok = await tryOpen(LaunchMode.platformDefault);
              if (!ok) ok = await tryOpen(LaunchMode.inAppWebView);

              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تعذر فتح رابط التحديث')),
                );
              }

              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('تحديث الآن'),
          ),
        ],
      ),
    );
  }

  /// مقارنة إصدارات على شكل x.y.z مع دعم أطوال مختلفة.
  /// تُرجع: 1 إذا a>b، 0 إذا a=b، -1 إذا a<b
  static int _compareSemver(String a, String b) {
    List<int> pa = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> pb = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final len = (pa.length > pb.length) ? pa.length : pb.length;
    while (pa.length < len) pa.add(0);
    while (pb.length < len) pb.add(0);
    for (int i = 0; i < len; i++) {
      if (pa[i] > pb[i]) return 1;
      if (pa[i] < pb[i]) return -1;
    }
    return 0;
  }

  /// لتفادي الكاش من GitHub/CDN
  static String _cacheBusted(String url) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final sep = url.contains('?') ? '&' : '?';
    return '$url${sep}t=$ts';
  }
}
