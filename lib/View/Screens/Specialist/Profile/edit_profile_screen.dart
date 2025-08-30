
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:youseuf_app/View/widget/Sheared/app_bar.dart';
// import 'package:youseuf_app/View/widget/Sheared/back_leading.dart';
// import 'package:youseuf_app/ViewModel/edit_profile_view_model.dart';
// import 'package:youseuf_app/core/theme/app_colors.dart';
// import 'package:youseuf_app/core/utils/icons.dart';
// import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد

// class EditProfileScreen extends StatelessWidget {
//   const EditProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // 💡 تهيئة كلاس الأبعاد هنا
//     ScreenSize.init(context);

//     return ChangeNotifierProvider(
//       create: (_) => EditProfileViewModel()..fetchUserData(),
//       child: Scaffold(
//         appBar: const CustomAppBar(title: 'تعديل الحساب'),
//         body: Consumer<EditProfileViewModel>(
//           builder: (context, viewModel, _) {
//             if (viewModel.isLoading) {
//               return Center(
//                 child: CircularProgressIndicator(color: blue),
//               );
//             }

//             return SingleChildScrollView(
//               // 💡 استخدام نسب مئوية للهوامش
//               padding: EdgeInsets.symmetric(
//                 horizontal: ScreenSize.getWidth(5.5),
//                 vertical: ScreenSize.getHeight(2),
//               ),
//               child: Column(
//                 textDirection: TextDirection.rtl,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // ✅ زر الرجوع أعلى الصفحة
//                   const Align(
//                     alignment: Alignment.centerLeft,
//                     child: BackLeading(),
//                   ),
//                   SizedBox(height: ScreenSize.getHeight(2.5)), // 💡 استخدام نسبة مئوية
//                   _buildInputField(
//                       'الاسم', viewModel.nameController, AppIcons.badge,
//                       enabled: false),
//                   _buildInputField(
//                       'رقم الجوال', viewModel.phoneController, AppIcons.phone),
//                   _buildInputField(
//                       'البريد الالكتروني', viewModel.emailController, AppIcons.emailOutlined,
//                       enabled: false),
//                   SizedBox(height: ScreenSize.getHeight(3.5)), // 💡 استخدام نسبة مئوية
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         bool success = await viewModel.updateUserData();
//                         if (context.mounted) {
//                           if (success) {
//                             await viewModel.fetchUserData();
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: const Text("تم حفظ البيانات بنجاح"),
//                                 duration: const Duration(seconds: 2), // 💡 إضافة مدة
//                                 backgroundColor: blue, // 💡 تحسين اللون
//                               ),
//                             );
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: const Text("فشل تحديث البيانات، حاول مرة أخرى"),
//                                 duration: const Duration(seconds: 2), // 💡 إضافة مدة
//                                 backgroundColor: Colors.red, // 💡 تحسين اللون
//                               ),
//                             );
//                           }
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: blue,
//                         // 💡 استخدام نسبة مئوية للهوامش
//                         padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(1.8)),
//                         shape: RoundedRectangleBorder(
//                           // 💡 استخدام نسبة مئوية لنصف القطر
//                           borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)),
//                         ),
//                       ),
//                       child: Text(
//                         'حفظ',
//                         style: TextStyle(
//                           fontSize: ScreenSize.getWidth(4.5), // 💡 استخدام نسبة مئوية لحجم الخط
//                           color: white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // 💡 تم تحديث الدوال المساعدة لاستخدام النسب المئوية
//   Widget _buildInputField(String label, TextEditingController controller, IconData icon, {bool enabled = true}) {
//     return Column(
//       textDirection: TextDirection.rtl,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية لحجم الخط
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: ScreenSize.getHeight(1.5)), // 💡 استخدام نسبة مئوية
//         TextField(
//           controller: controller,
//           textAlign: TextAlign.right,
//           enabled: enabled,
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: faFAFC,
//             // 💡 استخدام نسبة مئوية لحجم الأيقونة
//             suffixIcon: Icon(icon, color: blue, size: ScreenSize.getWidth(7)),
//             enabledBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: grey500),
//               // 💡 استخدام نسبة مئوية لنصف القطر
//               borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: blue),
//               // 💡 استخدام نسبة مئوية لنصف القطر
//               borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)),
//             ),
//           ),
//         ),
//         SizedBox(height: ScreenSize.getHeight(2.5)), // 💡 استخدام نسبة مئوية
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/widget/Sheared/app_bar.dart';
import 'package:youseuf_app/View/widget/Sheared/back_leading.dart';
import 'package:youseuf_app/ViewModel/edit_profile_view_model.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/icons.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);

    return ChangeNotifierProvider(
      create: (_) => EditProfileViewModel()..fetchUserData(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'تعديل الحساب'),
        body: Consumer<EditProfileViewModel>(
          builder: (context, viewModel, _) {
            // 💡 عرض رسالة الخطأ
            if (viewModel.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(ScreenSize.getWidth(5)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red, size: ScreenSize.getWidth(12)),
                      SizedBox(height: ScreenSize.getHeight(2)),
                      Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.red, fontSize: ScreenSize.getWidth(4)),
                      ),
                      SizedBox(height: ScreenSize.getHeight(2)),
                      ElevatedButton.icon(
                        onPressed: () => viewModel.fetchUserData(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (viewModel.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: blue),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenSize.getWidth(5.5),
                vertical: ScreenSize.getHeight(2),
              ),
              child: Column(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: BackLeading(),
                  ),
                  SizedBox(height: ScreenSize.getHeight(2.5)),
                  _buildInputField(
                      'الاسم', viewModel.nameController, AppIcons.badge,
                      enabled: false),
                  _buildInputField(
                      'رقم الجوال', viewModel.phoneController, AppIcons.phone),
                  _buildInputField(
                      'البريد الالكتروني', viewModel.emailController, AppIcons.emailOutlined,
                      enabled: false),
                  SizedBox(height: ScreenSize.getHeight(3.5)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        bool success = await viewModel.updateUserData();
                        if (context.mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("تم حفظ البيانات بنجاح"),
                                duration: const Duration(seconds: 2),
                                backgroundColor: blue,
                              ),
                            );
                          } else {
                            // عرض رسالة الخطأ عند فشل التحديث
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(viewModel.errorMessage ??
                                    "فشل تحديث البيانات، حاول مرة أخرى"),
                                duration: const Duration(seconds: 2),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(1.8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)),
                        ),
                      ),
                      child: Text(
                        'حفظ',
                        style: TextStyle(
                          fontSize: ScreenSize.getWidth(4.5),
                          color: white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, {bool enabled = true}) {
    return Column(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenSize.getWidth(4),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ScreenSize.getHeight(1.5)),
        TextField(
          controller: controller,
          textAlign: TextAlign.right,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: faFAFC,
            suffixIcon: Icon(icon, color: blue, size: ScreenSize.getWidth(7)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: grey500),
              borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: blue),
              borderRadius: BorderRadius.circular(ScreenSize.getWidth(3)),
            ),
          ),
        ),
        SizedBox(height: ScreenSize.getHeight(2.5)),
      ],
    );
  }
}