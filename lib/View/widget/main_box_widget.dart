import 'package:flutter/material.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';

// ويدجت MainBox لعرض صندوق رئيسي يحتوي على أيقونة، نص ورقم مع إمكانية التفاعل عند الضغط
class MainBox extends StatelessWidget {
  const MainBox({
    super.key,
    required this.icon, // مسار أيقونة الصورة (asset)
    required this.text, // النص الرئيسي الذي سيُعرض (مثل عنوان الصندوق)
    required this.number, // الرقم الذي سيُعرض أسفل النص
    this.onTap, // دالة يتم استدعاؤها عند الضغط على الصندوق (اختياري)
  });

  final String icon;
  final String text;
  final String number;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          onTap, // يضيف إمكانية الضغط على الصندوق مع استدعاء دالة onTap إذا وُجدت
      child: Container(
        width: 370, // عرض الصندوق ثابت
        height: 130, // ارتفاع الصندوق ثابت
        decoration: BoxDecoration(
          color: white, // خلفية بيضاء
          border: Border.all(
            // لون الحدود أزرق فاتح مع شفافية 58%
            // تعليق ignore لأن اللون قد يكون من مكتبة قديمة أو تحذير غير مهم
            color: lightBlue.withOpacity(.58),
          ),
          borderRadius: BorderRadius.circular(10), // زوايا دائرية بقطر 10
          boxShadow: [
            BoxShadow(
              blurRadius: 4, // مقدار التمويه للظل
              // لون الظل أسود مع شفافية 25%
              color: Color(0xff000000).withOpacity(.25),
              offset: Offset(0, 4), // موقع الظل أسفل العنصر بمقدار 4 بكسل
            )
          ],
        ),
        child: Center(
          child: Row(
            textDirection:
                TextDirection.rtl, // ترتيب المحتويات من اليمين إلى اليسار
            mainAxisAlignment:
                MainAxisAlignment.start, // بدء المحاذاة من اليمين
            children: [
              SizedBox(width: 17), // مساحة فارغة قبل الأيقونة
              Image.asset(
                icon, // عرض صورة الأيقونة
                width: 70,
                height: 70,
              ),
              SizedBox(width: 15), // مساحة فارغة بين الأيقونة والنص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .center, // محاذاة النصوص في المنتصف عرضيًا
                  mainAxisAlignment: MainAxisAlignment
                      .center, // محاذاة النصوص في المنتصف عموديًا
                  children: [
                    Text(
                      text, // عرض النص الأساسي
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                        color: blue, // اللون أزرق
                      ),
                    ),
                    Text(
                      number, // عرض الرقم
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: lightBlue, // لون أفتح من الأزرق
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
