import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lokkha/core/network/endpoints.dart';
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

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: LightThemeColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: LightThemeColors.primaryColor,
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notifications.isEmpty) {
            return Center(
              child: RefreshIndicator(
                onRefresh: notifier.fetchNotifications,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? context.surfaceColor
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: context.textMuted,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "No Notifications Yet",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: notifier.fetchNotifications,
            child: SafeArea(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                itemCount: notifications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return NotificationCard(
                    title: notification.title.toString(),
                    body: notification.body.toString(),
                    image: (notification.image != null &&
                            notification.image!.isNotEmpty)
                        ? Endpoints.storageUrl + notification.image!
                        : null,
                    isRead: notification.isRead ?? false,
                    humanTime: notification.timeHuman.toString(),
                    onTap: () {
                      final route = notification.route;
                      final id = notification.id;
                      if (notification.isRead != true && id != null) {
                        notifier.markAsRead(id, true);
                      }

                      if (route != null && route.isNotEmpty) {
                        final args = notification.arguments;
                        if (args == null || (args is List && args.isEmpty)) {
                          context.push(route);
                        } else {
                          final argId = args['id'];
                          final params = args['params'];
                          final finalID =
                              argId != null ? int.tryParse(argId) : null;

                          final arguments = (id != null && params != null)
                              ? {params: finalID}
                              : null;
                          context.push(route, extra: arguments);
                        }
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => NotificationDetailsPage(
                              title: notification.title ?? "",
                              body: notification.body ?? "",
                              image: notification.image,
                              webLink: notification.webLink ?? "",
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
