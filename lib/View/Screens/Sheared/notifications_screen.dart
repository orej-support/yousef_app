
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youseuf_app/View/widget/Sheared/notifications_widget.dart';
import 'package:youseuf_app/ViewModel/notifications_view_model.dart';
import 'package:youseuf_app/ViewModel/CustomAppBar.dart';
import 'package:youseuf_app/core/theme/app_colors.dart';
import 'package:youseuf_app/core/utils/ScreenSize.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  late NotificationsViewModel _viewModel;

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _viewModel.hasMoreNotifications &&
        !_viewModel.isLoading) {
      _viewModel.fetchNotifications(context,isInitialFetch: false);
    }
  }

  @override
  void initState() {
    super.initState();
    _viewModel = NotificationsViewModel();
    _scrollController.addListener(_onScroll);
    _viewModel.fetchNotifications(context,isInitialFetch: true).then((_) async {
      try {
        await _viewModel.markAllAsRead(context);
        if (!mounted) return;
        await context.read<CustomAppBarViewModel>().fetchUnreadCount(context);
      } catch (e) {
        debugPrint("❗خطأ أثناء تعليم جميع الإشعارات: $e");
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }
  // في NotificationsScreen
@override
Widget build(BuildContext context) {
  ScreenSize.init(context);

  return ChangeNotifierProvider<NotificationsViewModel>.value(
    value: _viewModel,
    child: Scaffold(
      appBar: AppBar(title: const Text("الإشعارات")),
      body: Consumer<NotificationsViewModel>(
        builder: (context, viewModel, _) {
          // 💡 التعديل: عرض الخطأ أولاً
          if (viewModel.errorMessage != null && viewModel.notifications.isEmpty) {
            return Center(
              child: Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: ScreenSize.getWidth(4), color: Colors.red),
              ),
            );
          }

          if (viewModel.isLoading && viewModel.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = viewModel.notifications;
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                'لا توجد إشعارات حاليًا',
                style: TextStyle(fontSize: ScreenSize.getWidth(4)),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: notifications.length + (viewModel.hasMoreNotifications ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == notifications.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: ScreenSize.getHeight(2)),
                  child: Center(
                    child: viewModel.isLoading
                        ? CircularProgressIndicator(color: blue)
                        : const SizedBox.shrink(),
                  ),
                );
              }
              final n = notifications[index];
              return NotificationWidget(
                notificationId: n['id'].toString(),
                text: n['message'],
                date: n['created_at'],
                isRead: n['is_read'] == true,
              );
            },
          );
        },
      ),
    ),
  );
}

  // @override
  // Widget build(BuildContext context) {


  //   ScreenSize.init(context);

  //   return ChangeNotifierProvider<NotificationsViewModel>.value(
  //     value: _viewModel,
  //     child: Scaffold(
  //       appBar: AppBar(title: const Text("الإشعارات")),
  //       body: Consumer<NotificationsViewModel>(
  //         builder: (context, viewModel, _) {
  //           // ✅ عرض Snackbar عند وجود خطأ
  //           if (viewModel.errorMessage != null) {
  //             WidgetsBinding.instance.addPostFrameCallback((_) {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text(viewModel.errorMessage!),
  //                   backgroundColor: red,
  //                 ),
  //               );
  //               // تفريغ الخطأ بعد عرضه حتى لا يتكرر
  //               viewModel.clearError();
  //             });
  //           }

  //           if (viewModel.isLoading && viewModel.notifications.isEmpty) {
  //             return const Center(child: CircularProgressIndicator());
  //           }

  //           final notifications = viewModel.notifications;
  //           if (notifications.isEmpty) {
  //             return Center(
  //               child: Text(
  //                 'لا توجد إشعارات حاليًا',
  //                 style: TextStyle(fontSize: ScreenSize.getWidth(4)),
  //               ),
  //             );
  //           }

  //           return ListView.builder(
  //             controller: _scrollController,
  //             itemCount: notifications.length +
  //                 (viewModel.hasMoreNotifications ? 1 : 0),
  //             itemBuilder: (context, index) {
  //               if (index == notifications.length) {
  //                 return Padding(
  //                   padding:
  //                       EdgeInsets.symmetric(vertical: ScreenSize.getHeight(2)),
  //                   child: Center(
  //                     child: viewModel.isLoading
  //                         ? CircularProgressIndicator(color: blue)
  //                         : const SizedBox.shrink(),
  //                   ),
  //                 );
  //               }
  //               final n = notifications[index];
  //               return NotificationWidget(
  //                 notificationId: n['id'].toString(),
  //                 text: n['message'],
  //                 date: n['created_at'],
  //                 isRead: n['is_read'] == true,
  //               );
  //             },
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

}

