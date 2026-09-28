import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lokkha/config/theme/light_theme_colors.dart';
import 'package:lokkha/config/theme/theme_extensions.dart';
import 'package:lokkha/utils/constants.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notification_card.dart';
import 'notification_details_view.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(
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
      body: Obx(() {
        final notifications = controller.model.value.notifications ?? [];
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (notifications.isEmpty) {
          return Center(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchNotifications(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.isDark ? context.surfaceColor : Colors.grey.shade200,
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
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(),
          child: SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationCard(
                  title: notification.title.toString(),
                  body: notification.body.toString(),
                  image: (notification.image != null &&
                          notification.image!.isNotEmpty)
                      ? AppConstants.storageUrl + notification.image!
                      : null,
                  isRead: notification.isRead ?? false,
                  humanTime: notification.timeHuman.toString(),
                  onTap: () {
                    final route = notification.route;
                    final id = notification.id;
                    if (notification.isRead != true && id != null) {
                      controller.markAsRead(id, true);
                    }

                    if (route != null && route.isNotEmpty) {
                      final args = notification.arguments;
                      if (args == null || (args is List && args.isEmpty)) {
                        Get.toNamed(route);
                      } else {
                        final argId = args['id'];
                        final params = args['params'];
                        final finalID =
                            argId != null ? int.tryParse(argId) : null;

                        final arguments = (id != null && params != null)
                            ? {params: finalID}
                            : null;
                        Get.toNamed(route, arguments: arguments);
                      }
                    } else {
                      Get.to(
                        () => NotificationDetailsPage(
                          title: notification.title ?? "",
                          body: notification.body ?? "",
                          image: notification.image,
                          webLink: notification.webLink ?? "",
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
