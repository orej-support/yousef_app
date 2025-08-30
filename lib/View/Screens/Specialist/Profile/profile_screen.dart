
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/Screens/Sheared/chat/chat_message_screen.dart';
import 'package:youseuf_app/View/Screens/Specialist/contact_us_screen.dart';
import 'package:youseuf_app/View/widget/Sheared/app_bar.dart';
import 'package:youseuf_app/ViewModel/contact_us_view_model.dart';
import 'package:youseuf_app/core/utils/icons.dart';
import 'package:youseuf_app/services/api_service.dart';
import 'package:youseuf_app/View/Screens/Specialist/Profile/edit_profile_screen.dart';
import 'package:youseuf_app/View/Screens/Sheared/Login/login_screen.dart';
import 'package:youseuf_app/ViewModel/profile_viewmodel.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart'; // 💡 استيراد كلاس الأبعاد

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 💡 تهيئة كلاس الأبعاد هنا
    ScreenSize.init(context);

    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..loadProfileData(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'حسابي'),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: blue),
              );
            }

            return Column(
              textDirection: TextDirection.rtl,
              children: [
                SizedBox(height: ScreenSize.getHeight(3.5)), // 💡 استخدام نسبة مئوية
                Padding(
                  // 💡 استخدام نسب مئوية للهوامش
                  padding: EdgeInsets.all(ScreenSize.getWidth(4)),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(AppIcons.personOutline, size: ScreenSize.getWidth(9)), // 💡 استخدام نسبة مئوية لحجم الأيقونة
                      SizedBox(width: ScreenSize.getWidth(2.5)), // 💡 استخدام نسبة مئوية
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "${viewModel.userName} ",
                                  style: TextStyle(
                                    fontSize: ScreenSize.getWidth(3.5), // 💡 استخدام نسبة مئوية لحجم الخط
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: ScreenSize.getHeight(0.8)), // 💡 استخدام نسبة مئوية
                          // الكود الخاص بعدد الأبناء (ملاحظات)
                        ],
                      ),
                    ],
                  ),
                ),
                buildMenuItem(
                  icon: AppIcons.edit,
                  text: 'تعديل الحساب',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                    context.read<ProfileViewModel>().loadProfileData();
                  },
                ),
                buildMenuItem(
                  icon: AppIcons.phone,
                  text: 'تواصل معنا',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ContactUsScreen(),
                      ),
                    );
                  },
                ),
                const Spacer(),
                buildMenuItem(
                  icon: AppIcons.logout,
                  text: 'تسجيل الخروج',
                  iconColor: red300,
                  textColor: grey,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(
                          "تأكيد تسجيل الخروج",
                          style: TextStyle(fontSize: ScreenSize.getWidth(4.5)), // 💡 استخدام نسبة مئوية
                        ),
                        content: Text(
                          "هل أنت متأكد أنك تريد تسجيل الخروج؟",
                          style: TextStyle(fontSize: ScreenSize.getWidth(4)), // 💡 استخدام نسبة مئوية
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("إلغاء"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text("تسجيل الخروج", style: TextStyle(color: red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final apiService = ApiService();
                      await apiService.logoutSpecialist(context);

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 💡 تم تحديث الدوال المساعدة لاستخدام النسب المئوية
  Widget buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        // 💡 استخدام نسب مئوية للهوامش
        padding: EdgeInsets.all(ScreenSize.getWidth(5.5)),
        child: Column(
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Padding(
                  // 💡 استخدام نسب مئوية للهوامش
                  padding: EdgeInsets.symmetric(horizontal: ScreenSize.getWidth(2)),
                  child: Icon(icon, color: iconColor, size: ScreenSize.getWidth(6)), // 💡 استخدام نسبة مئوية لحجم الأيقونة
                ),
                Expanded(
                  child: Text(
                    text,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: ScreenSize.getWidth(4), // 💡 استخدام نسبة مئوية لحجم الخط
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: blue,
                  size: ScreenSize.getWidth(4.5), // 💡 استخدام نسبة مئوية لحجم الأيقونة
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}