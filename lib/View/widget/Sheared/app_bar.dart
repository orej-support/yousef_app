// // // import 'dart:math' as math;
// // // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';
// // // import 'package:youseuf_app/ViewModel/CustomAppBar.dart';
// // // import 'package:youseuf_app/core/theme/app_colors.dart';
// // // import 'package:youseuf_app/core/utils/ScreenSize.dart';
// // // import 'package:youseuf_app/core/utils/errore.dart';
// // // import 'package:youseuf_app/core/utils/icons.dart';
// // // import 'package:youseuf_app/services/api_service.dart';
// // // import 'package:youseuf_app/View/Screens/Sheared/Login/login_screen.dart';
// // // import 'package:youseuf_app/View/Screens/Sheared/notifications_screen.dart';
// // // import 'package:youseuf_app/models/branch.dart';

// // // class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
// // //   final String title;
// // //   final List<Branch>? branches;
// // //   final Future<void> Function(Branch)? onChangeBranch;
// // //   final bool enableBranchPicker;

// // //   const CustomAppBar({
// // //     super.key,
// // //     required this.title,
// // //     this.branches,
// // //     this.onChangeBranch,
// // //     this.enableBranchPicker = true,
// // //   });

// // //   @override
// // //   Size get preferredSize => const Size.fromHeight(150);

// // //   Future<bool?> _showLogoutBottomSheet(BuildContext context) {
// // //     return showModalBottomSheet<bool>(
// // //       context: context,
// // //       backgroundColor: Colors.transparent,
// // //       builder: (BuildContext context) {
// // //         return Container(
// // //           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
// // //           decoration: const BoxDecoration(
// // //             color: Colors.white,
// // //             borderRadius: BorderRadius.only(
// // //               topLeft: Radius.circular(20),
// // //               topRight: Radius.circular(20),
// // //             ),
// // //           ),
// // //           child: Column(
// // //             mainAxisSize: MainAxisSize.min,
// // //             children: <Widget>[
// // //               const Padding(
// // //                 padding: EdgeInsets.symmetric(vertical: 10.0),
// // //                 child: Text(
// // //                   'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
// // //                   textAlign: TextAlign.center,
// // //                   style: TextStyle(
// // //                     fontSize: 18,
// // //                     fontWeight: FontWeight.w500,
// // //                     color: Colors.black,
// // //                   ),
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 20),
// // //               _buildOptionButton(
// // //                 context,
// // //                 text: 'تسجيل الخروج',
// // //                 textColor: Colors.red,
// // //                 onPressed: () {
// // //                   Navigator.of(context).pop(true);
// // //                 },
// // //               ),
// // //               _buildOptionButton(
// // //                 context,
// // //                 text: 'إلغاء',
// // //                 textColor: Colors.grey,
// // //                 onPressed: () {
// // //                   Navigator.of(context).pop(false);
// // //                 },
// // //               ),
// // //             ],
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }

// // //   Widget _buildOptionButton(
// // //     BuildContext context, {
// // //     required String text,
// // //     required Color textColor,
// // //     required VoidCallback onPressed,
// // //   }) {
// // //     return SizedBox(
// // //       width: double.infinity,
// // //       child: TextButton(
// // //         onPressed: onPressed,
// // //         style: TextButton.styleFrom(
// // //           foregroundColor: textColor,
// // //           textStyle: const TextStyle(
// // //             fontSize: 16,
// // //             fontWeight: FontWeight.w600,
// // //           ),
// // //         ),
// // //         child: Text(text),
// // //       ),
// // //     );
// // //   }

// // //   Future<Branch?> showBranchPickerDialog(
// // //     BuildContext context, {
// // //     required List<Branch> branches,
// // //     String title = 'اختر الفرع',
// // //   }) {
// // //     final Size screen = MediaQuery.of(context).size;
// // //     final double dialogWidth = screen.width * 0.86;
// // //     final double maxListHeight = screen.height * 0.55;
// // //     final double rowHeight = 52.0;
// // //     final double desiredHeight =
// // //         math.min(maxListHeight, rowHeight * branches.length + 8);

// // //     return showDialog<Branch>(
// // //       context: context,
// // //       barrierDismissible: true,
// // //       builder: (ctx) {
// // //         return AlertDialog(
// // //           insetPadding:
// // //               const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
// // //           shape:
// // //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// // //           titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
// // //           contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
// // //           actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
// // //           title: Text(
// // //             title,
// // //             textAlign: TextAlign.center,
// // //             style: TextStyle(fontWeight: FontWeight.w700, color: blue),
// // //           ),
// // //           content: SizedBox(
// // //             width: dialogWidth,
// // //             height: desiredHeight.clamp(120.0, maxListHeight),
// // //             child: branches.isEmpty
// // //                 ? const Center(child: Text('لا توجد فروع متاحة.'))
// // //                 : ListView.separated(
// // //                     primary: false,
// // //                     padding: EdgeInsets.zero,
// // //                     itemCount: branches.length,
// // //                     separatorBuilder: (_, __) => const Divider(height: 1),
// // //                     itemBuilder: (_, i) {
// // //                       final b = branches[i];
// // //                       return InkWell(
// // //                         onTap: () => Navigator.of(ctx).pop(b),
// // //                         child: Padding(
// // //                           padding: const EdgeInsets.symmetric(
// // //                               horizontal: 4, vertical: 10),
// // //                           child: Center(
// // //                             child: Text(
// // //                               (b.city != null && b.city!.isNotEmpty)
// // //                                   ? '${b.name} — ${b.city!}'
// // //                                   : b.name,
// // //                               textAlign: TextAlign.right,
// // //                               style: const TextStyle(
// // //                                   fontSize: 14.5, fontWeight: FontWeight.w500),
// // //                             ),
// // //                           ),
// // //                         ),
// // //                       );
// // //                     },
// // //                   ),
// // //           ),
// // //           actions: [
// // //             TextButton(
// // //               onPressed: () => Navigator.pop(ctx),
// // //               child: const Text('إلغاء'),
// // //             ),
// // //           ],
// // //         );
// // //       },
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Consumer<CustomAppBarViewModel>(
// // //       builder: (context, vm, child) {
// // //         return Container(
// // //           width: double.infinity,
// // //           height: 150,
// // //           decoration: BoxDecoration(color: lightpink),
// // //           child: Padding(
// // //             padding: const EdgeInsets.symmetric(horizontal: 13.0),
// // //             child: Row(

// // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //               textDirection: TextDirection.rtl,
// // //               children: [
// // //                 Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.end,
// // //                   mainAxisAlignment: MainAxisAlignment.center,
// // //                   children: [
// // //                     Padding(
// // //                       padding: const EdgeInsets.only(right: 11),
// // //                       child: Row(
// // //                         crossAxisAlignment: CrossAxisAlignment.center,
// // //                         children: [
// // //                           Text(
// // //                             vm.userName ?? "...",
// // //                             style: TextStyle(
// // //                                 color: blue,
// // //                                 fontSize: 10,
// // //                                 fontWeight: FontWeight.bold),
// // //                           ),
// // //                           const SizedBox(width: 5),
// // //                           Text("مرحبا",
// // //                               style: TextStyle(
// // //                                   color: black,
// // //                                   fontWeight: FontWeight.bold,
// // //                                   fontSize: 10)),
// // //                           const SizedBox(width: 8),
// // //                           Padding(
// // //                             padding: const EdgeInsets.all(8.0),
// // //                             child: Tooltip(
// // //                               message: 'تسجيل الخروج',
// // //                               child: SizedBox(
// // //                                 width: 36,
// // //                                 height: 36,
// // //                                 child: IconButton(
// // //                                   padding: EdgeInsets.zero,
// // //                                   icon: Icon(AppIcons.powerSettingsNew,
// // //                                       color: blue, size: 20),
// // //                                   onPressed: () async {
// // //                                     final confirmLogout =
// // //                                         await _showLogoutBottomSheet(context);
// // //                                     if (confirmLogout == true) {
// // //                                       final api = ApiService();
// // //                                       final userType = await api.getUserType();
// // //                                       try {
// // //                                         if (userType == 'specialist') {
// // //                                           await api.logoutSpecialist();
// // //                                         } else {
// // //                                           await api.logoutUser();
// // //                                         }
// // //                                         if (context.mounted) {
// // //                                           Navigator.of(context)
// // //                                               .pushAndRemoveUntil(
// // //                                             MaterialPageRoute(
// // //                                                 builder: (context) =>
// // //                                                     const LoginScreen()),
// // //                                             (route) => false,
// // //                                           );
// // //                                         }
// // //                                       } catch (e) {
// // //                                         // التقاط أي استثناءات تحدث في دوال logoutUser/logoutSpecialist
// // //                                         // واستخدام الديالوج لعرض الخطأ
// // //                                         String errorMessage =
// // //                                             'فشل تسجيل الخروج: ${e.toString()}';
// // //                                         // استخدام الديالوج لعرض الخطأ
// // //                                         showErrorDialog(
// // //                                             context,
// // //                                             'خطأ في تسجيل الخروج',
// // //                                             errorMessage);
// // //                                       }
// // //                                     }
// // //                                   },
// // //                                 ),
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //                 const Spacer(),
// // //                 Column(
// // //                   mainAxisAlignment: MainAxisAlignment.center,
// // //                   mainAxisSize: MainAxisSize.min,
// // //                   children: [
// // //                     Padding(
// // //                       padding: const EdgeInsets.only(bottom: 4),
// // //                       child: Image.asset("assets/images/icon.png",
// // //                           width: ScreenSize.getWidth(15), // 15% من عرض الشاشة

// // //                           fit: BoxFit.contain),
// // //                     ),
// // //                     Text(
// // //                       title,
// // //                       style: TextStyle(
// // //                           color: blue,
// // //                           fontSize: 9,
// // //                           fontWeight: FontWeight.bold),
// // //                       textAlign: TextAlign.center,
// // //                     ),
// // //                   ],
// // //                 ),
// // //                 const Spacer(),
// // //                 Row(
// // //                   mainAxisAlignment: MainAxisAlignment.center,
// // //                   children: [
// // //                     if (enableBranchPicker && vm.userType == 'user')
// // //                       Tooltip(
// // //                         message: 'تغيير الفرع',
// // //                         child: IconButton(
// // //                           icon: Icon(AppIcons.locationOn, color: blue),
// // //                           onPressed: () async {
// // //                             if (branches == null || onChangeBranch == null)
// // //                               return;
// // //                             final selected = await showBranchPickerDialog(
// // //                               context,
// // //                               branches: branches!,
// // //                               title: 'اختر الفرع',
// // //                             );
// // //                             if (selected != null) {
// // //                               await onChangeBranch!(selected);
// // //                             }
// // //                           },
// // //                         ),
// // //                       ),
// // //                     Tooltip(
// // //                       message: 'الإشعارات',
// // //                       child: InkWell(
// // //                         onTap: () async {
// // //                           await Navigator.push(
// // //                             context,
// // //                             MaterialPageRoute(
// // //                                 builder: (context) =>
// // //                                     const NotificationsScreen()),
// // //                           );
// // //                           vm.fetchUnreadCount();
// // //                         },
// // //                         child: Padding(
// // //                           padding: const EdgeInsets.all(12.0),
// // //                           child: Stack(
// // //                             clipBehavior: Clip.none,
// // //                             children: [
// // //                               Icon(Icons.notifications, color: blue, size: 24),
// // //                               if (vm.unreadCount > 0)
// // //                                 Positioned(
// // //                                   right: -2,
// // //                                   top: -2,
// // //                                   child: Container(
// // //                                     padding: const EdgeInsets.symmetric(
// // //                                         horizontal: 5, vertical: 2),
// // //                                     decoration: BoxDecoration(
// // //                                         color: red, shape: BoxShape.circle),
// // //                                     constraints: const BoxConstraints(
// // //                                         minWidth: 16, minHeight: 16),
// // //                                     child: Text(
// // //                                       vm.unreadCount.toString(),
// // //                                       style: TextStyle(
// // //                                           color: white,
// // //                                           fontSize: ScreenSize.getWidth(3),
// // //                                           fontWeight: FontWeight.w600),
// // //                                       textAlign: TextAlign.center,
// // //                                     ),
// // //                                   ),
// // //                                 ),
// // //                             ],
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // // }
// // import 'dart:math' as math;
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:youseuf_app/ViewModel/CustomAppBar.dart';
// // import 'package:youseuf_app/core/theme/app_colors.dart';
// // import 'package:youseuf_app/core/utils/ScreenSize.dart';
// // import 'package:youseuf_app/core/utils/errore.dart';
// // import 'package:youseuf_app/core/utils/icons.dart';
// // import 'package:youseuf_app/services/api_service.dart';
// // import 'package:youseuf_app/View/Screens/Sheared/Login/login_screen.dart';
// // import 'package:youseuf_app/View/Screens/Sheared/notifications_screen.dart';
// // import 'package:youseuf_app/models/branch.dart';

// // class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
// //   final String title;
// //   final List<Branch>? branches;
// //   final Future<void> Function(Branch)? onChangeBranch;
// //   final bool enableBranchPicker;

// //   const CustomAppBar({
// //     super.key,
// //     required this.title,
// //     this.branches,
// //     this.onChangeBranch,
// //     this.enableBranchPicker = true,
// //   });

// //   @override
// //   Size get preferredSize => Size.fromHeight(ScreenSize.getHeight(18));

// //   Future<bool?> _showLogoutBottomSheet(BuildContext context) {
// //     return showModalBottomSheet<bool>(
// //       context: context,
// //       backgroundColor: Colors.transparent,
// //       builder: (BuildContext context) {
// //         return Container(
// //           padding: EdgeInsets.symmetric(
// //             horizontal: ScreenSize.getWidth(4),
// //             vertical: ScreenSize.getHeight(1.2),
// //           ),
// //           decoration: const BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.only(
// //               topLeft: Radius.circular(20),
// //               topRight: Radius.circular(20),
// //             ),
// //           ),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: <Widget>[
// //               Padding(
// //                 padding: EdgeInsets.symmetric(
// //                   vertical: ScreenSize.getHeight(1.5),
// //                 ),
// //                 child: Text(
// //                   'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     fontSize: ScreenSize.getWidth(4.2),
// //                     fontWeight: FontWeight.w500,
// //                     color: Colors.black,
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(height: ScreenSize.getHeight(2)),
// //               _buildOptionButton(
// //                 context,
// //                 text: 'تسجيل الخروج',
// //                 textColor: Colors.red,
// //                 onPressed: () {
// //                   Navigator.of(context).pop(true);
// //                 },
// //               ),
// //               _buildOptionButton(
// //                 context,
// //                 text: 'إلغاء',
// //                 textColor: Colors.grey,
// //                 onPressed: () {
// //                   Navigator.of(context).pop(false);
// //                 },
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildOptionButton(
// //     BuildContext context, {
// //     required String text,
// //     required Color textColor,
// //     required VoidCallback onPressed,
// //   }) {
// //     return SizedBox(
// //       width: double.infinity,
// //       child: TextButton(
// //         onPressed: onPressed,
// //         style: TextButton.styleFrom(
// //           foregroundColor: textColor,
// //           textStyle: TextStyle(
// //             fontSize: ScreenSize.getWidth(3.8),
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         child: Text(text),
// //       ),
// //     );
// //   }

// //   Future<Branch?> showBranchPickerDialog(
// //     BuildContext context, {
// //     required List<Branch> branches,
// //     String title = 'اختر الفرع',
// //   }) {
// //     final Size screen = MediaQuery.of(context).size;
// //     final double dialogWidth = screen.width * 0.86;
// //     final double maxListHeight = screen.height * 0.55;
// //     final double rowHeight = 52.0;
// //     final double desiredHeight =
// //         math.min(maxListHeight, rowHeight * branches.length + 8);

// //     return showDialog<Branch>(
// //       context: context,
// //       barrierDismissible: true,
// //       builder: (ctx) {
// //         return AlertDialog(
// //           insetPadding:
// //               const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
// //           shape:
// //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //           titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
// //           contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
// //           actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
// //           title: Text(
// //             title,
// //             textAlign: TextAlign.center,
// //             style: TextStyle(
// //               fontWeight: FontWeight.w700,
// //               color: blue,
// //               fontSize: ScreenSize.getWidth(4),
// //             ),
// //           ),
// //           content: SizedBox(
// //             width: dialogWidth,
// //             height: desiredHeight.clamp(120.0, maxListHeight),
// //             child: branches.isEmpty
// //                 ? const Center(child: Text('لا توجد فروع متاحة.'))
// //                 : ListView.separated(
// //                     primary: false,
// //                     padding: EdgeInsets.zero,
// //                     itemCount: branches.length,
// //                     separatorBuilder: (_, __) => const Divider(height: 1),
// //                     itemBuilder: (_, i) {
// //                       final b = branches[i];
// //                       return InkWell(
// //                         onTap: () => Navigator.of(ctx).pop(b),
// //                         child: Padding(
// //                           padding: EdgeInsets.symmetric(
// //                             horizontal: ScreenSize.getWidth(2),
// //                             vertical: ScreenSize.getHeight(1.2),
// //                           ),
// //                           child: Center(
// //                             child: Text(
// //                               (b.city != null && b.city!.isNotEmpty)
// //                                   ? '${b.name} — ${b.city!}'
// //                                   : b.name,
// //                               textAlign: TextAlign.right,
// //                               style: TextStyle(
// //                                 fontSize: ScreenSize.getWidth(3.8),
// //                                 fontWeight: FontWeight.w500,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(ctx),
// //               child: const Text('إلغاء'),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     ScreenSize.init(context);

// //     return Consumer<CustomAppBarViewModel>(
// //       builder: (context, vm, child) {
// //         return Container(
// //           width: double.infinity,
// //           height: ScreenSize.getHeight(18),
// //           decoration: BoxDecoration(color: lightpink),
// //           padding: EdgeInsets.symmetric(horizontal: ScreenSize.getWidth(3)),
// //           child: Row(
// //             textDirection: TextDirection.rtl,
// //             children: [
// //               /// القسم الأول (معلومات المستخدم + تسجيل الخروج)
// //               Expanded(
// //                 flex: 3,
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.end,
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Row(
// //                       crossAxisAlignment: CrossAxisAlignment.center,
// //                       mainAxisAlignment: MainAxisAlignment.end,
// //                       children: [
// //                         Text(
// //                           vm.userName ?? "...",
// //                           style: TextStyle(
// //                             color: blue,
// //                             fontSize: ScreenSize.getWidth(3),
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         SizedBox(width: ScreenSize.getWidth(1.5)),
// //                         Text(
// //                           "مرحبا",
// //                           style: TextStyle(
// //                             color: black,
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: ScreenSize.getWidth(3),
// //                           ),
// //                         ),
// //                         SizedBox(width: ScreenSize.getWidth(2)),
// //                         Tooltip(
// //                           message: 'تسجيل الخروج',
// //                           child: IconButton(
// //                             icon: Icon(AppIcons.powerSettingsNew,
// //                                 color: blue, size: ScreenSize.getWidth(5)),
// //                             onPressed: () async {
// //                               final confirmLogout =
// //                                   await _showLogoutBottomSheet(context);
// //                               if (confirmLogout == true) {
// //                                 final api = ApiService();
// //                                 final userType = await api.getUserType();
// //                                 try {
// //                                   if (userType == 'specialist') {
// //                                     await api.logoutSpecialist();
// //                                   } else {
// //                                     await api.logoutUser();
// //                                   }
// //                                   if (context.mounted) {
// //                                     Navigator.of(context).pushAndRemoveUntil(
// //                                       MaterialPageRoute(
// //                                           builder: (context) =>
// //                                               const LoginScreen()),
// //                                       (route) => false,
// //                                     );
// //                                   }
// //                                 } catch (e) {
// //                                   showErrorDialog(
// //                                     context,
// //                                     'خطأ في تسجيل الخروج',
// //                                     'فشل تسجيل الخروج: ${e.toString()}',
// //                                   );
// //                                 }
// //                               }
// //                             },
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               /// القسم الأوسط (الشعار + العنوان)
// //               Expanded(
// //                 flex: 4,
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Image.asset(
// //                       "assets/images/icon.png",
// //                       width: ScreenSize.getWidth(15),
// //                       fit: BoxFit.contain,
// //                     ),
// //                     Text(
// //                       title,
// //                       style: TextStyle(
// //                         color: blue,
// //                         fontSize: ScreenSize.getWidth(2.5),
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                       textAlign: TextAlign.center,
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               /// القسم الأخير (الإشعارات + الفروع)
// //               Expanded(
// //                 flex: 3,
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     if (enableBranchPicker && vm.userType == 'user')
// //                       Tooltip(
// //                         message: 'تغيير الفرع',
// //                         child: IconButton(
// //                           icon: Icon(AppIcons.locationOn,
// //                               color: blue, size: ScreenSize.getWidth(5)),
// //                           onPressed: () async {
// //                             if (branches == null || onChangeBranch == null) {
// //                               return;
// //                             }
// //                             final selected = await showBranchPickerDialog(
// //                               context,
// //                               branches: branches!,
// //                               title: 'اختر الفرع',
// //                             );
// //                             if (selected != null) {
// //                               await onChangeBranch!(selected);
// //                             }
// //                           },
// //                         ),
// //                       ),
// //                     Tooltip(
// //                       message: 'الإشعارات',
// //                       child: InkWell(
// //                         onTap: () async {
// //                           await Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                                 builder: (context) =>
// //                                     const NotificationsScreen()),
// //                           );
// //                           vm.fetchUnreadCount();
// //                         },
// //                         child: Stack(
// //                           clipBehavior: Clip.none,
// //                           children: [
// //                             Icon(
// //                               Icons.notifications,
// //                               color: blue,
// //                               size: ScreenSize.getWidth(6),
// //                             ),
// //                             if (vm.unreadCount > 0)
// //                               Positioned(
// //                                 right: -2,
// //                                 top: -2,
// //                                 child: Container(
// //                                   padding: EdgeInsets.symmetric(
// //                                     horizontal: ScreenSize.getWidth(1.5),
// //                                     vertical: ScreenSize.getHeight(0.3),
// //                                   ),
// //                                   decoration: BoxDecoration(
// //                                     color: red,
// //                                     shape: BoxShape.circle,
// //                                   ),
// //                                   constraints: BoxConstraints(
// //                                     minWidth: ScreenSize.getWidth(3.5),
// //                                     minHeight: ScreenSize.getWidth(3.5),
// //                                   ),
// //                                   child: Text(
// //                                     vm.unreadCount.toString(),
// //                                     style: TextStyle(
// //                                       color: white,
// //                                       fontSize: ScreenSize.getWidth(2.2),
// //                                       fontWeight: FontWeight.w600,
// //                                     ),
// //                                     textAlign: TextAlign.center,
// //                                   ),
// //                                 ),
// //                               ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// // import 'dart:math' as math;
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:youseuf_app/ViewModel/CustomAppBar.dart';
// // import 'package:youseuf_app/core/theme/app_colors.dart';
// // import 'package:youseuf_app/core/utils/ScreenSize.dart';
// // import 'package:youseuf_app/core/utils/errore.dart';
// // import 'package:youseuf_app/core/utils/icons.dart';
// // import 'package:youseuf_app/services/api_service.dart';
// // import 'package:youseuf_app/View/Screens/Sheared/Login/login_screen.dart';
// // import 'package:youseuf_app/View/Screens/Sheared/notifications_screen.dart';
// // import 'package:youseuf_app/models/branch.dart';

// // /// عنصر مخصص لشريط التطبيق العلوي (AppBar)
// // class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
// //   final String title; // العنوان المعروض في منتصف الـ AppBar
// //   final List<Branch>? branches; // قائمة الفروع المتاحة
// //   final Future<void> Function(Branch)? onChangeBranch; // دالة تُنفذ عند اختيار فرع جديد
// //   final bool enableBranchPicker; // التحكم بإظهار أيقونة تغيير الفرع

// //   const CustomAppBar({
// //     super.key,
// //     required this.title,
// //     this.branches,
// //     this.onChangeBranch,
// //     this.enableBranchPicker = true,
// //   });

// //   /// تحديد حجم الـ AppBar
// //   @override
// //   Size get preferredSize => Size.fromHeight(ScreenSize.getHeight(18));

// //   /// نافذة منبثقة لتأكيد تسجيل الخروج
// //   Future<bool?> _showLogoutBottomSheet(BuildContext context) {
// //     return showModalBottomSheet<bool>(
// //       context: context,
// //       backgroundColor: Colors.transparent,
// //       builder: (BuildContext context) {
// //         return Container(
// //           padding: EdgeInsets.symmetric(
// //             horizontal: ScreenSize.getWidth(4),
// //             vertical: ScreenSize.getHeight(1.2),
// //           ),
// //           decoration: const BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.only(
// //               topLeft: Radius.circular(20),
// //               topRight: Radius.circular(20),
// //             ),
// //           ),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: <Widget>[
// //               /// النص الرئيسي للتأكيد
// //               Padding(
// //                 padding: EdgeInsets.symmetric(
// //                   vertical: ScreenSize.getHeight(1.5),
// //                 ),
// //                 child: Text(
// //                   'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     fontSize: ScreenSize.getWidth(4.2),
// //                     fontWeight: FontWeight.w500,
// //                     color: Colors.black,
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(height: ScreenSize.getHeight(2)),

// //               /// زر تسجيل الخروج
// //               _buildOptionButton(
// //                 context,
// //                 text: 'تسجيل الخروج',
// //                 textColor: Colors.red,
// //                 onPressed: () {
// //                   Navigator.of(context).pop(true);
// //                 },
// //               ),

// //               /// زر إلغاء
// //               _buildOptionButton(
// //                 context,
// //                 text: 'إلغاء',
// //                 textColor: Colors.grey,
// //                 onPressed: () {
// //                   Navigator.of(context).pop(false);
// //                 },
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   /// زر عام يُستخدم داخل الـ BottomSheet (مثل تسجيل الخروج أو إلغاء)
// //   Widget _buildOptionButton(
// //     BuildContext context, {
// //     required String text,
// //     required Color textColor,
// //     required VoidCallback onPressed,
// //   }) {
// //     return SizedBox(
// //       width: double.infinity,
// //       child: TextButton(
// //         onPressed: onPressed,
// //         style: TextButton.styleFrom(
// //           foregroundColor: textColor,
// //           textStyle: TextStyle(
// //             fontSize: ScreenSize.getWidth(3.8),
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         child: Text(text),
// //       ),
// //     );
// //   }

// //   /// نافذة لاختيار الفرع (Dialog)
// //   Future<Branch?> showBranchPickerDialog(
// //     BuildContext context, {
// //     required List<Branch> branches,
// //     String title = 'اختر الفرع',
// //   }) {
// //     final Size screen = MediaQuery.of(context).size;
// //     final double dialogWidth = screen.width * 0.86;
// //     final double maxListHeight = screen.height * 0.55;
// //     final double rowHeight = 52.0;
// //     final double desiredHeight =
// //         math.min(maxListHeight, rowHeight * branches.length + 8);

// //     return showDialog<Branch>(
// //       context: context,
// //       barrierDismissible: true,
// //       builder: (ctx) {
// //         return AlertDialog(
// //           insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
// //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //           titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
// //           contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
// //           actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),

// //           /// عنوان النافذة
// //           title: Text(
// //             title,
// //             textAlign: TextAlign.center,
// //             style: TextStyle(
// //               fontWeight: FontWeight.w700,
// //               color: blue,
// //               fontSize: ScreenSize.getWidth(4),
// //             ),
// //           ),

// //           /// محتوى النافذة (قائمة الفروع)
// //           content: SizedBox(
// //             width: dialogWidth,
// //             height: desiredHeight.clamp(120.0, maxListHeight),
// //             child: branches.isEmpty
// //                 ? const Center(child: Text('لا توجد فروع متاحة.'))
// //                 : ListView.separated(
// //                     primary: false,
// //                     padding: EdgeInsets.zero,
// //                     itemCount: branches.length,
// //                     separatorBuilder: (_, __) => const Divider(height: 1),
// //                     itemBuilder: (_, i) {
// //                       final b = branches[i];
// //                       return InkWell(
// //                         onTap: () => Navigator.of(ctx).pop(b),
// //                         child: Padding(
// //                           padding: EdgeInsets.symmetric(
// //                             horizontal: ScreenSize.getWidth(2),
// //                             vertical: ScreenSize.getHeight(1.2),
// //                           ),
// //                           child: Center(
// //                             child: Text(
// //                               (b.city != null && b.city!.isNotEmpty)
// //                                   ? '${b.name} — ${b.city!}'
// //                                   : b.name,
// //                               textAlign: TextAlign.right,
// //                               style: TextStyle(
// //                                 fontSize: ScreenSize.getWidth(3.8),
// //                                 fontWeight: FontWeight.w500,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //           ),

// //           /// زر إلغاء في الأسفل
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(ctx),
// //               child: const Text('إلغاء'),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   /// البناء الرئيسي للـ AppBar
// //   @override
// //   Widget build(BuildContext context) {
// //     ScreenSize.init(context);

// //     return Consumer<CustomAppBarViewModel>(
// //       builder: (context, vm, child) {
// //         return Container(
// //           width: double.infinity,
// //           height: ScreenSize.getHeight(18),
// //           decoration: BoxDecoration(color: lightpink),
// //           child: Padding(
// //             padding: EdgeInsets.symmetric(horizontal: ScreenSize.getWidth(3)),
// //             child: Row(
// //               textDirection: TextDirection.rtl,
// //               children: [
// //                 /// القسم الأول: (الاسم + "مرحبا" + زر تسجيل الخروج)
// //                 Expanded(
// //                   flex: 3,
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.end,
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       SingleChildScrollView(
// //                         scrollDirection: Axis.horizontal,
// //                         child: Row(
// //                           crossAxisAlignment: CrossAxisAlignment.center,
// //                           mainAxisAlignment: MainAxisAlignment.end,
// //                           children: [
// //                             /// اسم المستخدم
// //                             Text(
// //                               vm.userName ?? "...",
// //                               style: TextStyle(
// //                                 color: blue,
// //                                 fontSize: ScreenSize.getWidth(3),
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                             SizedBox(width: ScreenSize.getWidth(1.5)),

// //                             /// كلمة "مرحبا"
// //                             Text(
// //                               "مرحبا",
// //                               style: TextStyle(
// //                                 color: black,
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: ScreenSize.getWidth(3),
// //                               ),
// //                             ),
// //                             SizedBox(width: ScreenSize.getWidth(2)),

// //                             /// زر تسجيل الخروج
// //                             Tooltip(
// //                               message: 'تسجيل الخروج',
// //                               child: IconButton(
// //                                 icon: Icon(AppIcons.powerSettingsNew,
// //                                     color: blue, size: ScreenSize.getWidth(5)),
// //                                 onPressed: () async {
// //                                   final confirmLogout =
// //                                       await _showLogoutBottomSheet(context);
// //                                   if (confirmLogout == true) {
// //                                     final api = ApiService();
// //                                     final userType = await api.getUserType();
// //                                     try {
// //                                       if (userType == 'specialist') {
// //                                         await api.logoutSpecialist();
// //                                       } else {
// //                                         await api.logoutUser();
// //                                       }
// //                                       if (context.mounted) {
// //                                         Navigator.of(context).pushAndRemoveUntil(
// //                                           MaterialPageRoute(
// //                                               builder: (context) =>
// //                                                   const LoginScreen()),
// //                                           (route) => false,
// //                                         );
// //                                       }
// //                                     } catch (e) {
// //                                       showErrorDialog(
// //                                         context,
// //                                         'خطأ في تسجيل الخروج',
// //                                         'فشل تسجيل الخروج: ${e.toString()}',
// //                                       );
// //                                     }
// //                                   }
// //                                 },
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),

// //                 /// القسم الثاني: (الشعار + عنوان الصفحة)
// //                 Expanded(
// //                   flex: 4,
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Image.asset(
// //                         "assets/images/icon.png",
// //                         width: ScreenSize.getWidth(15),
// //                         fit: BoxFit.contain,
// //                       ),
// //                       Text(
// //                         title,
// //                         style: TextStyle(
// //                           color: blue,
// //                           fontSize: ScreenSize.getWidth(2.5),
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                         textAlign: TextAlign.center,
// //                       ),
// //                     ],
// //                   ),
// //                 ),

// //                 /// القسم الثالث: (زر الفروع + زر الإشعارات)
// //                 Expanded(
// //                   flex: 3,
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       /// زر اختيار الفرع (للمستخدمين فقط)
// //                       if (enableBranchPicker && vm.userType == 'user')
// //                         Tooltip(
// //                           message: 'تغيير الفرع',
// //                           child: IconButton(
// //                             icon: Icon(AppIcons.locationOn,
// //                                 color: blue, size: ScreenSize.getWidth(5)),
// //                             onPressed: () async {
// //                               if (branches == null || onChangeBranch == null) {
// //                                 return;
// //                               }
// //                               final selected = await showBranchPickerDialog(
// //                                 context,
// //                                 branches: branches!,
// //                                 title: 'اختر الفرع',
// //                               );
// //                               if (selected != null) {
// //                                 await onChangeBranch!(selected);
// //                               }
// //                             },
// //                           ),
// //                         ),

// //                       /// زر الإشعارات + عداد الرسائل غير المقروءة
// //                       Tooltip(
// //                         message: 'الإشعارات',
// //                         child: InkWell(
// //                           onTap: () async {
// //                             await Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                   builder: (context) =>
// //                                       const NotificationsScreen()),
// //                             );
// //                             vm.fetchUnreadCount();
// //                           },
// //                           child: Stack(
// //                             clipBehavior: Clip.none,
// //                             children: [
// //                               Icon(
// //                                 Icons.notifications,
// //                                 color: blue,
// //                                 size: ScreenSize.getWidth(6),
// //                               ),
// //                               if (vm.unreadCount > 0)
// //                                 Positioned(
// //                                   right: -2,
// //                                   top: -2,
// //                                   child: Container(
// //                                     padding: EdgeInsets.symmetric(
// //                                       horizontal: ScreenSize.getWidth(1.5),
// //                                       vertical: ScreenSize.getHeight(0.3),
// //                                     ),
// //                                     decoration: BoxDecoration(
// //                                       color: red,
// //                                       shape: BoxShape.circle,
// //                                     ),
// //                                     constraints: BoxConstraints(
// //                                       minWidth: ScreenSize.getWidth(3.5),
// //                                       minHeight: ScreenSize.getWidth(3.5),
// //                                     ),
// //                                     child: Text(
// //                                       vm.unreadCount.toString(),
// //                                       style: TextStyle(
// //                                         color: white,
// //                                         fontSize: ScreenSize.getWidth(2.2),
// //                                         fontWeight: FontWeight.w600,
// //                                       ),
// //                                       textAlign: TextAlign.center,
// //                                     ),
// //                                   ),
// //                                 ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:youseuf_app/ViewModel/CustomAppBar.dart';
// import 'package:youseuf_app/core/theme/app_colors.dart';
// import 'package:youseuf_app/core/utils/ScreenSize.dart';
// import 'package:youseuf_app/core/utils/errore.dart';
// import 'package:youseuf_app/core/utils/icons.dart';
// import 'package:youseuf_app/services/api_service.dart';
// import 'package:youseuf_app/View/Screens/Sheared/Login/login_screen.dart';
// import 'package:youseuf_app/View/Screens/Sheared/notifications_screen.dart';
// import 'package:youseuf_app/models/branch.dart';

// /// عنصر مخصص لشريط التطبيق العلوي (AppBar)
// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title; // العنوان المعروض في منتصف الـ AppBar
//   final List<Branch>? branches; // قائمة الفروع المتاحة
//   final Future<void> Function(Branch)?
//       onChangeBranch; // دالة تُنفذ عند اختيار فرع جديد
//   final bool enableBranchPicker; // التحكم بإظهار أيقونة تغيير الفرع

//   const CustomAppBar({
//     super.key,
//     required this.title,
//     this.branches,
//     this.onChangeBranch,
//     this.enableBranchPicker = true,
//   });

//   /// تحديد حجم الـ AppBar
//   @override
//   Size get preferredSize => Size.fromHeight(ScreenSize.getHeight(18));

//   /// نافذة منبثقة لتأكيد تسجيل الخروج
//   Future<bool?> _showLogoutBottomSheet(BuildContext context) {
//     return showModalBottomSheet<bool>(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: ScreenSize.getWidth(4),
//             vertical: ScreenSize.getHeight(1.2),
//           ),
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
//               /// النص الرئيسي للتأكيد
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   vertical: ScreenSize.getHeight(1.5),
//                 ),
//                 child: Text(
//                   'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: ScreenSize.getWidth(4.2),
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               SizedBox(height: ScreenSize.getHeight(2)),

//               /// زر تسجيل الخروج
//               _buildOptionButton(
//                 context,
//                 text: 'تسجيل الخروج',
//                 textColor: Colors.red,
//                 onPressed: () {
//                   Navigator.of(context).pop(true);
//                 },
//               ),

//               /// زر إلغاء
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

//   /// زر عام يُستخدم داخل الـ BottomSheet (مثل تسجيل الخروج أو إلغاء)
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
//           textStyle: TextStyle(
//             fontSize: ScreenSize.getWidth(3.8),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         child: Text(text),
//       ),
//     );
//   }

//   /// نافذة لاختيار الفرع (Dialog)
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

//           /// عنوان النافذة
//           title: Text(
//             title,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontWeight: FontWeight.w700,
//               color: blue,
//               fontSize: ScreenSize.getWidth(4),
//             ),
//           ),

//           /// محتوى النافذة (قائمة الفروع)
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
//                           padding: EdgeInsets.symmetric(
//                             horizontal: ScreenSize.getWidth(2),
//                             vertical: ScreenSize.getHeight(1.2),
//                           ),
//                           child: Center(
//                             child: Text(
//                               (b.city != null && b.city!.isNotEmpty)
//                                   ? '${b.name} — ${b.city!}'
//                                   : b.name,
//                               textAlign: TextAlign.right,
//                               style: TextStyle(
//                                 fontSize: ScreenSize.getWidth(3.8),
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),

//           /// زر إلغاء في الأسفل
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

//   /// البناء الرئيسي للـ AppBar
//   @override
//   Widget build(BuildContext context) {
//     ScreenSize.init(context);

//     return Consumer<CustomAppBarViewModel>(
//       builder: (context, vm, child) {
//         return Container(
//           width: double.infinity,
//           height: ScreenSize.getHeight(18),
//           decoration: BoxDecoration(color: lightpink),
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: ScreenSize.getWidth(3)),
//             child: Row(
//               textDirection: TextDirection.rtl,
//               children: [
//                 /// القسم الأول: (الاسم + "مرحبا" + زر تسجيل الخروج)
//                Expanded(
//   flex: 1,
//   child: Row(
//     crossAxisAlignment: CrossAxisAlignment.center,
//     mainAxisAlignment: MainAxisAlignment.end,
//     children: [
//       /// قم بدمج اسم المستخدم وكلمة "مرحبا" داخل Flexible واحد
//       /// لمنع تجاوز المساحة.
//       Flexible(
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           textDirection: TextDirection.rtl,
//           children: [
//             Flexible(
//               child: Text(
//                 vm.userName ?? "...",
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: blue,
//                   fontSize: ScreenSize.getWidth(3),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SizedBox(width: ScreenSize.getWidth(1.5)),
//             Text(
//               "مرحبا",
//               style: TextStyle(
//                 color: black,
//                 fontWeight: FontWeight.bold,
//                 fontSize: ScreenSize.getWidth(1),
//               ),
//             ),
//           ],
//         ),
//       ),
//       SizedBox(width: ScreenSize.getWidth(2)), // مسافة بين النص والزر
//       /// زر تسجيل الخروج
//       Tooltip(
//         message: 'تسجيل الخروج',
//         child: IconButton(
//           icon: Icon(AppIcons.powerSettingsNew,
//               color: blue, size: ScreenSize.getWidth(5)),
//           onPressed: () async {
//             final confirmLogout = await _showLogoutBottomSheet(context);
//             if (confirmLogout == true) {
//               final api = ApiService();
//               final userType = await api.getUserType();
//               try {
//                 if (userType == 'specialist') {
//                   await api.logoutSpecialist();
//                 } else {
//                   await api.logoutUser();
//                 }
//                 if (context.mounted) {
//                   Navigator.of(context).pushAndRemoveUntil(
//                     MaterialPageRoute(
//                         builder: (context) => const LoginScreen()),
//                     (route) => false,
//                   );
//                 }
//               } catch (e) {
//                 showErrorDialog(
//                   context,
//                   'خطأ في تسجيل الخروج',
//                   'فشل تسجيل الخروج: ${e.toString()}',
//                 );
//               }
//             }
//           },
//         ),
//       ),
//     ],
//   ),
// ),
//                 /// القسم الثاني: (الشعار + عنوان الصفحة)
//                 Expanded(
//                   flex: 4,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Image.asset(
//                         "assets/images/icon.png",
//                         width: ScreenSize.getWidth(15),
//                         fit: BoxFit.contain,
//                       ),
//                       Text(
//                         title,
//                         style: TextStyle(
//                           color: blue,
//                           fontSize: ScreenSize.getWidth(2.5),
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),

//                 /// القسم الثالث: (زر الفروع + زر الإشعارات)
//                 Expanded(
//                   flex: 3,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       /// زر اختيار الفرع (للمستخدمين فقط)
//                       if (enableBranchPicker && vm.userType == 'user')
//                         Tooltip(
//                           message: 'تغيير الفرع',
//                           child: IconButton(
//                             icon: Icon(AppIcons.locationOn,
//                                 color: blue, size: ScreenSize.getWidth(5)),
//                             onPressed: () async {
//                               if (branches == null || onChangeBranch == null) {
//                                 return;
//                               }
//                               final selected = await showBranchPickerDialog(
//                                 context,
//                                 branches: branches!,
//                                 title: 'اختر الفرع',
//                               );
//                               if (selected != null) {
//                                 await onChangeBranch!(selected);
//                               }
//                             },
//                           ),
//                         ),

//                       /// زر الإشعارات + عداد الرسائل غير المقروءة
//                       Tooltip(
//                         message: 'الإشعارات',
//                         child: InkWell(
//                           onTap: () async {
//                             await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       const NotificationsScreen()),
//                             );
//                             vm.fetchUnreadCount();
//                           },
//                           child: Stack(
//                             clipBehavior: Clip.none,
//                             children: [
//                               Icon(
//                                 Icons.notifications,
//                                 color: blue,
//                                 size: ScreenSize.getWidth(6),
//                               ),
//                               if (vm.unreadCount > 0)
//                                 Positioned(
//                                   right: -2,
//                                   top: -2,
//                                   child: Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: ScreenSize.getWidth(1.5),
//                                       vertical: ScreenSize.getHeight(0.3),
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: red,
//                                       shape: BoxShape.circle,
//                                     ),
//                                     constraints: BoxConstraints(
//                                       minWidth: ScreenSize.getWidth(3.5),
//                                       minHeight: ScreenSize.getWidth(3.5),
//                                     ),
//                                     child: Text(
//                                       vm.unreadCount.toString(),
//                                       style: TextStyle(
//                                         color: white,
//                                         fontSize: ScreenSize.getWidth(2.2),
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/ViewModel/CustomAppBar.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart';
import 'package:youseuf_app/core/utils/error.dart';
import 'package:youseuf_app/core/utils/icons.dart';
import 'package:youseuf_app/services/api_service.dart';
import 'package:youseuf_app/View/Screens/Sheared/Login/login_screen.dart';
import 'package:youseuf_app/View/Screens/Sheared/notifications_screen.dart';
import 'package:youseuf_app/models/branch.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Branch>? branches;
  final Future<void> Function(Branch)? onChangeBranch;
  final bool enableBranchPicker;

  const CustomAppBar({
    super.key,
    required this.title,
    this.branches,
    this.onChangeBranch,
    this.enableBranchPicker = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(ScreenSize.getHeight(18));

  Future<bool?> _showLogoutBottomSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenSize.getWidth(4),
            vertical: ScreenSize.getHeight(1.2),
          ),
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
                padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(1.5)),
                child: Text(
                  'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ScreenSize.getWidth(4.2),
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: ScreenSize.getHeight(2)),
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
          textStyle: TextStyle(
            fontSize: ScreenSize.getWidth(3.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(text),
      ),
    );
  }

  Future<Branch?> showBranchPickerDialog(
    BuildContext context, {
    required List<Branch> branches,
    String title = 'اختر الفرع',
  }) {
    final Size screen = MediaQuery.of(context).size;
    final double dialogWidth = screen.width * 0.86;
    final double maxListHeight = screen.height * 0.55;
    final double rowHeight = 52.0;
    final double desiredHeight = math.min(maxListHeight, rowHeight * branches.length + 8);

    return showDialog<Branch>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: blue,
              fontSize: ScreenSize.getWidth(4),
            ),
          ),
          content: SizedBox(
            width: dialogWidth,
            height: desiredHeight.clamp(120.0, maxListHeight),
            child: branches.isEmpty
                ? const Center(child: Text('لا توجد فروع متاحة.'))
                : ListView.separated(
                    primary: false,
                    padding: EdgeInsets.zero,
                    itemCount: branches.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final b = branches[i];
                      return InkWell(
                        onTap: () => Navigator.of(ctx).pop(b),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenSize.getWidth(2),
                            vertical: ScreenSize.getHeight(1.2),
                          ),
                          child: Center(
                            child: Text(
                              (b.city != null && b.city!.isNotEmpty)
                                  ? '${b.name} — ${b.city!}'
                                  : b.name,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: ScreenSize.getWidth(3.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);

    return Consumer<CustomAppBarViewModel>(
      builder: (context, vm, child) {
        return Container(
          width: double.infinity,
          height: ScreenSize.getHeight(18),
          decoration: BoxDecoration(color: lightpink),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenSize.getWidth(3)),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                /// القسم الأول: الترحيب باسم المستخدم
                Expanded(
                  flex: 2,
                  child: Text(
                    'مرحبا ${vm.userName ?? "..."}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: black,
                      fontSize: ScreenSize.getWidth(3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                /// القسم الثاني: الشعار + العنوان
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/icon.png",
                        width: ScreenSize.getWidth(15),
                        fit: BoxFit.contain,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          color: blue,
                          fontSize: ScreenSize.getWidth(2.5),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                /// القسم الثالث: جميع الأيقونات في نفس الصف
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (enableBranchPicker && vm.userType == 'user')
                        Tooltip(
                          message: 'تغيير الفرع',
                          child: IconButton(
                            icon: Icon(AppIcons.locationOn,
                                color: blue, size: ScreenSize.getWidth(5)),
                            onPressed: () async {
                              if (branches == null || onChangeBranch == null) return;
                              final selected = await showBranchPickerDialog(
                                context,
                                branches: branches!,
                                title: 'اختر الفرع',
                              );
                              if (selected != null) await onChangeBranch!(selected);
                            },
                          ),
                        ),
                      Tooltip(
                        message: 'الإشعارات',
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.notifications,
                                color: blue,
                                size: ScreenSize.getWidth(6),
                              ),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationsScreen()),
                                );
                                vm.fetchUnreadCount(context);
                              },
                            ),
                            if (vm.unreadCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ScreenSize.getWidth(1.5),
                                    vertical: ScreenSize.getHeight(0.3),
                                  ),
                                  decoration: BoxDecoration(
                                    color: red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: ScreenSize.getWidth(3.5),
                                    minHeight: ScreenSize.getWidth(3.5),
                                  ),
                                  child: Text(
                                    vm.unreadCount.toString(),
                                    style: TextStyle(
                                      color: white,
                                      fontSize: ScreenSize.getWidth(2.2),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Tooltip(
                        message: 'تسجيل الخروج',
                        child: IconButton(
                          icon: Icon(AppIcons.powerSettingsNew,
                              color: blue, size: ScreenSize.getWidth(5)),
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
                                        builder: (context) => const LoginScreen()),
                                    (route) => false,
                                  );
                                }
                              } catch (e) {
                                showErrorDialog(
                                  context,
                                  'خطأ في تسجيل الخروج',
                                  'فشل تسجيل الخروج: ${e.toString()}',
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
