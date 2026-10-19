import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokkha/app/theme/app_theme.dart';
import '../providers/notifications_notifier.dart';
import '../widgets/notification_card.dart';
import 'notification_details_view.dart';

class NotificationsView extends ConsumerWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsNotifierProvider);
    final notifier = ref.read(notificationsNotifierProvider.notifier);
    final notifications = state.model.notifications;
    final unreadCount = state.model.unreadCount ?? 0;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "নোটিফিকেশন",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17.sp,
              ),
            ),
            if (unreadCount > 0) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF006A4E),
        elevation: 0,
        actions: [
          if (notifications.isNotEmpty && unreadCount > 0)
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: state.isMarkingAllRead
                  ? Center(
                      child: SizedBox(
                        width: 18.r,
                        height: 18.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : IconButton(
                      tooltip: "সবগুলো পড়া হয়েছে",
                      icon: const Icon(
                        Icons.done_all_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () {
                        notifier.markAllAsRead();
                      },
                    ),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF006A4E),
              ),
            );
          }

          if (notifications.isEmpty) {
            return RefreshIndicator(
              color: const Color(0xFF006A4E),
              onRefresh: notifier.fetchNotifications,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(22.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFF006A4E).withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_off_outlined,
                            size: 54.sp,
                            color: const Color(0xFF006A4E),
                          ),
                        ),
                        SizedBox(height: 18.h),
                        Text(
                          "কোন নোটিফিকেশন নেই",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "আপনার নতুন সব নোটিফিকেশন এখানে প্রদর্শিত হবে।",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF006A4E),
            onRefresh: notifier.fetchNotifications,
            child: SafeArea(
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final String title = notification.title?.trim() ?? "বিজ্ঞপ্তি";
                  final String body = notification.body?.trim() ?? "";
                  final bool isRead = notification.isRead ?? false;
                  final String humanTime =
                      notification.timeHuman ?? notification.createdAt ?? "";

                  return NotificationCard(
                    title: title,
                    body: body,
                    image: notification.image,
                    isRead: isRead,
                    humanTime: humanTime,
                    onTap: () {
                      final id = notification.id;
                      if (!isRead && id != null) {
                        notifier.markAsRead(id, true);
                      }

                      final route = notification.route;
                      if (route != null &&
                          route.isNotEmpty &&
                          GoRouter.maybeOf(context) != null) {
                        final args = notification.arguments;
                        if (args == null ||
                            (args is List && args.isEmpty) ||
                            (args is Map && args.isEmpty)) {
                          context.push(route);
                        } else if (args is Map) {
                          context.push(route, extra: args);
                        } else {
                          context.push(route);
                        }
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => NotificationDetailsPage(
                              title: title,
                              body: body,
                              image: notification.image,
                              webLink: notification.webLink,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
