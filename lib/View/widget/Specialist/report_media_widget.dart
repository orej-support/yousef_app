// lib/View/widget/Specialist/report_media_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/icons.dart';
import '../../../../services/api_service.dart';

class ReportMediaWidget extends StatelessWidget {
  final String fileUrl; // قد يكون مطلق أو نسبي
  final String? storageOrigin; // اختياري: أصل التخزين إن تبغين تغييره

  const ReportMediaWidget({
    Key? key,
    required this.fileUrl,
    this.storageOrigin,
  }) : super(key: key);

  // ابني رابط مطلق بدون دومين ثابت "غلط"
  // الافتراضي: يستنتج الأصل من _baseUrl لديك (هنا نستخدم https://test.futureti.org)
  String _buildAbsoluteUrl(String raw) {
    if (raw.isEmpty) return raw;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

    // أصل التخزين (عدّليه لو عندك CDN لاحقًا)
    final origin = storageOrigin ?? 'https://mubadarat-youssef.futureti.org';

    // نظّف المسار
    var path = raw;
    if (path.startsWith('/')) path = path.substring(1);
    path = path.replaceFirst(RegExp(r'^public/'), '');

    // حالات شائعة
    if (path.startsWith('storage/')) return '$origin/$path';
    return '$origin/storage/$path';
  }

  bool _isImage(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.png') ||
        u.endsWith('.jpg') ||
        u.endsWith('.jpeg') ||
        u.endsWith('.gif') ||
        u.endsWith('.webp');
  }

  bool _isVideo(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.mp4') ||
        u.endsWith('.mov') ||
        u.endsWith('.avi') ||
        u.endsWith('.mkv') ||
        u.contains('video');
  }

  bool _isPdf(String url) => url.toLowerCase().endsWith('.pdf');

  Future<void> _openExternal(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // تحميل وفتح PDF: جرّب بدون هيدرز، لو فشل جرّب مع Authorization
  Future<void> _downloadAndOpenPdf(BuildContext context, String absUrl) async {
    try {
      http.Response res;
      try {
        res = await http.get(Uri.parse(absUrl));
      } catch (_) {
        res = http.Response('', 0);
      }

      if (res.statusCode != 200) {
        final token = await ApiService().getToken();
        final headers = (token == null || token.isEmpty)
            ? null
            : {'Authorization': 'Bearer $token', 'Accept': '*/*'};
        final res2 = await http.get(Uri.parse(absUrl), headers: headers);
        if (res2.statusCode != 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('فشل تحميل الملف: ${res.statusCode}/${res2.statusCode}'),
            ),
          );
          return;
        }
        await _saveAndOpen(res2.bodyBytes, absUrl);
        return;
      }

      await _saveAndOpen(res.bodyBytes, absUrl);
    } catch (e) {
      debugPrint('خطأ أثناء فتح PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الملف.')),
      );
    }
  }

  Future<void> _saveAndOpen(List<int> bytes, String absUrl) async {
    final dir = await getTemporaryDirectory();
    final name = absUrl.split('/').last.split('?').first;
    final f = File('${dir.path}/$name');
    await f.writeAsBytes(bytes);
    await OpenFilex.open(f.path);
  }

  @override
  Widget build(BuildContext context) {
    final absUrl = _buildAbsoluteUrl(fileUrl);

    // صور
    if (_isImage(absUrl)) {
      // استخدم الهيدرز إن احتجنا (لو التخزين خاص) — وإلا خلّيها null
      return FutureBuilder<String?>(
        future: ApiService().getToken(),
        builder: (context, snap) {
          final token = snap.data;
          final headers = (token == null || token.isEmpty)
              ? null
              : {'Authorization': 'Bearer $token', 'Accept': '*/*'};

          return CachedNetworkImage(
            imageUrl: absUrl,
            httpHeaders: headers,
            imageBuilder: (_, provider) => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image(image: provider, fit: BoxFit.cover),
            ),
            placeholder: (_, __) =>
                 Center(child: CircularProgressIndicator(color: blue)),
            errorWidget: (_, __, ___) => ListTile(
              leading: const Icon(AppIcons.brokenImage),
              title: Text(absUrl.split('/').last),
              subtitle: const Text('تعذر تحميل الصورة — اضغط للفتح الخارجي'),
              onTap: () => _openExternal(absUrl),
            ),
          );
        },
      );
    }

    // PDF
    if (_isPdf(absUrl)) {
      return Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton(
          onPressed: () => _downloadAndOpenPdf(context, absUrl),
          child: const Text('فتح الملف', style: TextStyle(fontSize: 13)),
        ),
      );
    }

    // فيديو
    if (_isVideo(absUrl)) {
  return InkWell(
    onTap: () => _openExternal(absUrl),
    borderRadius: BorderRadius.circular(12),
    child: Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: black12,
      ),
      child: const Center(
        child: Icon(AppIcons.playCircleFill, size: 56),
      ),
    ),
  );
}


    // أي نوع آخر: افتح خارجيًا
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(AppIcons.insertDriveFile),
        title: Text(absUrl.split('/').last),
        subtitle: const Text('اضغط للفتح/التنزيل'),
        onTap: () => _openExternal(absUrl),
      ),
    );
  }
}
