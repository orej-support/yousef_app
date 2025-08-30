import 'package:flutter/material.dart';
import 'package:youseuf_app/View/Screens/Specialist/WebViewScreen.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';

class CourseCardWidget extends StatelessWidget {
  final String image;
  final String title;
  final String link;
  final String? subtitle;

  const CourseCardWidget({
    Key? key,
    required this.image,
    required this.title,
    required this.link,
    this.subtitle,
  }) : super(key: key);

  void _openWebView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: link, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Material(
          color: white,
          elevation: 1.5,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _openWebView(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              constraints: const BoxConstraints(minHeight: 70),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ الصورة أولاً (تظهر يمين في RTL)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      image,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/course1.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // النص + الزر (يسار)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end, // يسار في RTL
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left, // تأكيد أنه يسار
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: black87,
                          ),
                        ),
                        if ((subtitle ?? '').isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 12,
                              color: darkgrey,
                              height: 1.1,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft, // زر يسار البطاقة
                          child: SizedBox(
                            height: 30,
                            child: OutlinedButton(
                              onPressed: () => _openWebView(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: blue, width: 1),
                                foregroundColor: blue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 0),
                                shape: const StadiumBorder(),
                                textStyle: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                minimumSize: const Size(68, 30),
                              ),
                              child: const Text('ابدأ'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
