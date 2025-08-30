// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:youseuf_app/ViewModel/CustomAppBar.dart';
// import 'package:youseuf_app/core/theme/app_colors.dart';
// import 'package:youseuf_app/core/utils/errore.dart';
// import 'package:youseuf_app/core/utils/icons.dart';
// import '../../../../services/api_service.dart';
// import 'package:youseuf_app/View/Screens/Sheared/Login/login_screen.dart';
// import 'package:youseuf_app/View/Screens/Sheared/notifications_screen.dart';
// import 'package:youseuf_app/models/branch.dart';

// class SuperviseAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final List<Branch>? branches;
//   final Future<void> Function(Branch)? onChangeBranch;
//   final bool enableBranchPicker;
//   final VoidCallback? onRefresh;

//   const SuperviseAppBar({
//     super.key,
//     required this.title,
//     this.branches,
//     this.onChangeBranch,
//     this.enableBranchPicker = true,
//     this.onRefresh,
//   });

//   @override
//   Size get preferredSize => const Size.fromHeight(150);

//   Future<bool?> _showLogoutBottomSheet(BuildContext context) {
//     return showModalBottomSheet<bool>(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 10.0),
//                 child: Text(
//                   'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               _buildOptionButton(
//                 context,
//                 text: 'تسجيل الخروج',
//                 textColor: Colors.red,
//                 onPressed: () {
//                   Navigator.of(context).pop(true);
//                 },
//               ),
//               _buildOptionButton(
//                 context,
//                 text: 'إلغاء',
//                 textColor: Colors.grey,
//                 onPressed: () {
//                   Navigator.of(context).pop(false);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildOptionButton(
//     BuildContext context, {
//     required String text,
//     required Color textColor,
//     required VoidCallback onPressed,
//   }) {
//     return SizedBox(
//       width: double.infinity,
//       child: TextButton(
//         onPressed: onPressed,
//         style: TextButton.styleFrom(
//           foregroundColor: textColor,
//           textStyle: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         child: Text(text),
//       ),
//     );
//   }

//   Future<Branch?> showBranchPickerDialog(
//     BuildContext context, {
//     required List<Branch> branches,
//     String title = 'اختر الفرع',
//   }) {
//     final Size screen = MediaQuery.of(context).size;
//     final double dialogWidth = screen.width * 0.86;
//     final double maxListHeight = screen.height * 0.55;
//     final double rowHeight = 52.0;
//     final double desiredHeight =
//         math.min(maxListHeight, rowHeight * branches.length + 8);

//     return showDialog<Branch>(
//       context: context,
//       barrierDismissible: true,
//       builder: (ctx) {
//         return AlertDialog(
//           insetPadding:
//               const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
//           contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
//           actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
//           title: Text(
//             title,
//             textAlign: TextAlign.center,
//             style: TextStyle(fontWeight: FontWeight.w700, color: blue),
//           ),
//           content: SizedBox(
//             width: dialogWidth,
//             height: desiredHeight.clamp(120.0, maxListHeight),
//             child: branches.isEmpty
//                 ? const Center(child: Text('لا توجد فروع متاحة.'))
//                 : ListView.separated(
//                     primary: false,
//                     padding: EdgeInsets.zero,
//                     itemCount: branches.length,
//                     separatorBuilder: (_, __) => const Divider(height: 1),
//                     itemBuilder: (_, i) {
//                       final b = branches[i];
//                       return InkWell(
//                         onTap: () => Navigator.of(ctx).pop(b),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 4, vertical: 10),
//                           child: Center(
//                             child: Text(
//                               (b.city != null && b.city!.isNotEmpty)
//                                   ? '${b.name} — ${b.city!}'
//                                   : b.name,
//                               textAlign: TextAlign.right,
//                               style: const TextStyle(
//                                   fontSize: 14.5, fontWeight: FontWeight.w500),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(ctx),
//               child: const Text('إلغاء'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final vm = Provider.of<CustomAppBarViewModel>(context);

//     return Container(
//       width: double.infinity,
//       height: 150,
//       decoration: BoxDecoration(color: lightpink),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 13.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           textDirection: TextDirection.rtl,
//           children: [
//             // 🟢 يمين: الترحيب + خروج
//             Expanded(
//               child: Row(
//                 textDirection: TextDirection.rtl,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       'مرحبا ${vm.userName ?? "..."}',
//                       overflow: TextOverflow.ellipsis,
//                       textDirection: TextDirection.rtl,
//                       style: TextStyle(
//                         color: black,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon:
//                         Icon(AppIcons.powerSettingsNew, color: blue, size: 22),
//                     onPressed: () async {
//                       final confirmLogout =
//                           await _showLogoutBottomSheet(context);
//                       if (confirmLogout == true) {
//                         final api = ApiService();
//                         final userType = await api.getUserType();
//                         try {
//                           if (userType == 'specialist') {
//                             await api.logoutSpecialist();
//                           } else {
//                             await api.logoutUser();
//                           }
//                           if (context.mounted) {
//                             Navigator.of(context).pushAndRemoveUntil(
//                               MaterialPageRoute(
//                                 builder: (context) => const LoginScreen(),
//                               ),
//                               (route) => false,
//                             );
//                           }
//                         } catch (e) {
//                           showErrorDialog(
//                               context, 'خطأ في تسجيل الخروج', e.toString());
//                         }
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             // 🟡 الوسط: الشعار + العنوان
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     "assets/images/icon.png",
//                     width: 50,
//                     fit: BoxFit.contain,
//                   ),
//                   Text(
//                     title,
//                     style: TextStyle(
//                       color: blue,
//                       fontSize: 11,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),

//             // 🔵 اليسار: اختيار الفرع + الإشعارات + تحديث
//             // 🔵 SuperviseAppBar بعد التعديل
//             // 🔵 اليسار: اختيار الفرع + الإشعارات + تحديث
//             Expanded(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (enableBranchPicker && vm.userType == 'user')
//                     IconButton(
//                       icon: Icon(AppIcons.locationOn, color: blue, size: 20),
//                       onPressed: () async {
//                         if (branches == null || onChangeBranch == null) return;
//                         final selected = await showBranchPickerDialog(
//                           context,
//                           branches: branches!,
//                           title: 'اختر الفرع',
//                         );
//                         if (selected != null) {
//                           await onChangeBranch!(selected);
//                         }
//                       },
//                     ),
//                   IconButton(
//                     icon: Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         Icon(Icons.notifications, color: blue, size: 20),
//                         if (vm.unreadCount > 0)
//                           Positioned(
//                             right: -2,
//                             top: -2,
//                             child: Container(
//                               padding: const EdgeInsets.all(2),
//                               decoration: BoxDecoration(
//                                   color: red, shape: BoxShape.circle),
//                               constraints: const BoxConstraints(
//                                   minWidth: 14, minHeight: 14),
//                               child: Text(
//                                 vm.unreadCount.toString(),
//                                 style: TextStyle(
//                                   color: white,
//                                   fontSize: 9,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                     onPressed: () async {
//                       await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const NotificationsScreen(),
//                         ),
//                       );
//                       vm.fetchUnreadCount();
//                     },
//                   ),
//                   IconButton(
//                     icon: Icon(AppIcons.refresh, color: blue, size: 20),
//                     onPressed: () {
//                       if (onRefresh != null) {
//                         onRefresh!();
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:youseuf_app/View/Screens/Superviser/user_dashboard_screen.dart';
import 'package:youseuf_app/ViewModel/CustomAppBar.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/error.dart';
import 'package:youseuf_app/core/utils/icons.dart';
import '../../../../services/api_service.dart';
import 'package:youseuf_app/View/Screens/Sheared/Login/login_screen.dart';
import 'package:youseuf_app/View/Screens/Sheared/notifications_screen.dart';
import 'package:youseuf_app/models/branch.dart';

class SuperviseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Branch>? branches;
  final Future<void> Function(Branch)? onChangeBranch;
  final bool enableBranchPicker;
  final VoidCallback? onRefresh;

  const SuperviseAppBar({
    super.key,
    required this.title,
    this.branches,
    this.onChangeBranch,
    this.enableBranchPicker = true,
    this.onRefresh,
  });

  @override
  Size get preferredSize => const Size.fromHeight(150);

  Future<bool?> _showLogoutBottomSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildOptionButton(
                context,
                text: 'تسجيل الخروج',
                textColor: Colors.red,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              _buildOptionButton(
                context,
                text: 'إلغاء',
                textColor: Colors.grey,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required String text,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: textColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(text),
      ),
    );
  }

  Future<Branch?> showBranchPickerBottomSheet(
    BuildContext context, {
    required List<Branch> branches,
    String title = 'اختر الفرع',
  }) {
    return showModalBottomSheet<Branch>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 🔽 قائمة الفروع
              if (branches.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text("لا توجد فروع متاحة."),
                )
              else
                ...branches.map(
                  (b) => _buildOptionButton(
                    ctx,
                    text: (b.city != null && b.city!.isNotEmpty)
                        ? '${b.name} — ${b.city!}'
                        : b.name,
                    textColor: Colors.black,
                    onPressed: () => Navigator.of(ctx).pop(b),
                  ),
                ),

              const Divider(height: 20),

              // زر الإلغاء
              _buildOptionButton(
                ctx,
                text: 'إلغاء',
                textColor: Colors.grey,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CustomAppBarViewModel>(context);

    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(color: lightpink),
      padding: const EdgeInsets.symmetric(horizontal: 13.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🟢 جهة اليمين: الترحيب
          Expanded(
            child: Text(
              'مرحبا ${vm.userName ?? "..."}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 🟡 الوسط: الشعار + العنوان
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/icon.png",
                  width: 50,
                  fit: BoxFit.contain,
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: blue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 🔵 جهة اليسار: جميع الأيقونات في نفس الصف
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (enableBranchPicker && vm.userType == 'user')
                IconButton(
                  icon: Icon(AppIcons.locationOn, color: blue, size: 20),
                  onPressed: () async {
                    if (branches == null || onChangeBranch == null) return;
                    final selected = await showBranchPickerBottomSheet(
                      context,
                      branches: branches!,
                      title: 'اختر الفرع',
                    );
                    if (selected != null) {
                      await onChangeBranch!(selected);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const UserDashboardScreen()),
                      );
                    }
                  },
                ),
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.notifications, color: blue, size: 20),
                    if (vm.unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration:
                              BoxDecoration(color: red, shape: BoxShape.circle),
                          constraints:
                              const BoxConstraints(minWidth: 14, minHeight: 14),
                          child: Text(
                            vm.unreadCount > 99
                                ? '99+'
                                : vm.unreadCount.toString(),
                            style: TextStyle(
                              color: white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                  vm.fetchUnreadCount(context);
                },
              ),
              IconButton(
                icon: Icon(AppIcons.powerSettingsNew, color: blue, size: 22),
                onPressed: () async {
                  final confirmLogout = await _showLogoutBottomSheet(context);
                  if (confirmLogout == true) {
                    final api = ApiService();
                    final userType = await api.getUserType();
                    try {
                      if (userType == 'specialist') {
                        await api.logoutSpecialist(context);
                      } else {
                        await api.logoutUser();
                      }
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      showErrorDialog(
                          context, 'خطأ في تسجيل الخروج',e.toString());
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
