import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokkha/core/localization/l10n/app_localizations.dart';
import 'package:lokkha/core/network/endpoints.dart';
import 'package:lokkha/core/utils/global.dart';
import 'package:lokkha/di/notification_provider.dart';
import 'package:lokkha/features/notifications/notifications.dart';

class _MockNotificationRepository implements NotificationRepository {
  NotificationListEntity? dataToReturn;
  bool markReadResult = true;
  bool markAllReadResult = true;

  int fetchCount = 0;
  int markReadCount = 0;
  int markAllReadCount = 0;
  int? lastMarkedId;

  _MockNotificationRepository([this.dataToReturn]);

  @override
  Future<NotificationListEntity> getNotifications({String? deviceId}) async {
    fetchCount++;
    return dataToReturn ?? const NotificationModel();
  }

  @override
  Future<bool> markAsRead({
    required int notificationId,
    String? deviceId,
    bool isRead = true,
  }) async {
    markReadCount++;
    lastMarkedId = notificationId;
    return markReadResult;
  }

  @override
  Future<bool> markAllAsRead({String? deviceId}) async {
    markAllReadCount++;
    return markAllReadResult;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleNotificationPayload = {
    "success": true,
    "message": "Notifications retrieved successfully.",
    "data": {
      "unread_count": 15,
      "notifications": [
        {
          "id": 15,
          "title": "Free Exam ",
          "body": "সময় নষ্ট না করে ফ্রী পরীক্ষা দেন\nলিংক কমেন্ট বক্সে👇",
          "image": null,
          "route": null,
          "arguments": [],
          "web_link":
              "https://lokkha.com/exam/samprtik-bishyableer-gk-upr-preeksha-1108-2026",
          "is_read": false,
          "created_at": "2026-08-11T12:15:56+06:00",
          "time_human": "2 months ago"
        },
        {
          "id": 14,
          "title": "Quiz ",
          "body": "কুইজ শুরু হয়ে গেছে এখনি  অংশগ্রহণ করুন ",
          "image": null,
          "route": null,
          "arguments": [],
          "web_link": null,
          "is_read": false,
          "created_at": "2026-05-03T13:01:05+06:00",
          "time_human": "5 months ago"
        },
        {
          "id": 12,
          "title": "ফ্রি পরীক্ষা দিন",
          "body": "📢 প্রাইমারি প্রধান শিক্ষক নিয়োগ পরীক্ষায় অংশগ্রহণ করতে প্রস্তুত তো?",
          "image": null,
          "route": null,
          "arguments": [],
          "web_link": null,
          "is_read": false,
          "created_at": "2026-03-30T13:57:23+06:00",
          "time_human": "5 months ago"
        },
        {
          "id": 1,
          "title": "ফ্রি পরীক্ষা দিন",
          "body": "চাকরির প্রতিযোগিতায় নিজেকে এগিয়ে রাখতে যেকোন একটি প্যাকেজ নিন",
          "image": null,
          "route": "/packages",
          "arguments": [],
          "web_link": "https://lokkha.com/",
          "is_read": false,
          "created_at": "2026-01-13T07:08:18+06:00",
          "time_human": "6 months ago"
        }
      ]
    }
  };

  group('Module 35: Endpoints & Serialization', () {
    test('Endpoints contains v1 notification endpoints correctly', () {
      expect(Endpoints.notifications, equals('/api/v1/notifications'));
      expect(Endpoints.notificationsReadAll, equals('/api/v1/notifications/read-all'));
      expect(Endpoints.notificationMarkRead(15), equals('/api/v1/notifications/15/read'));
      expect(Endpoints.v1Notifications, equals('/api/v1/notifications'));
      expect(Endpoints.v1NotificationsReadAll, equals('/api/v1/notifications/read-all'));
      expect(Endpoints.v1NotificationMarkRead(15), equals('/api/v1/notifications/15/read'));
    });

    test('NotificationModel parses Module 35 v1 payload correctly', () {
      final model = NotificationModel.fromJson(sampleNotificationPayload);

      expect(model.status, isTrue);
      expect(model.message, equals('Notifications retrieved successfully.'));
      expect(model.unreadCount, equals(15));
      expect(model.notifications.length, equals(4));

      final first = model.notifications[0];
      expect(first.id, equals(15));
      expect(first.title, equals('Free Exam '));
      expect(first.body, contains('সময় নষ্ট না করে ফ্রী পরীক্ষা দেন'));
      expect(first.isRead, isFalse);
      expect(first.webLink, contains('https://lokkha.com/exam'));
      expect(first.createdAt, equals('2026-08-11T12:15:56+06:00'));
      expect(first.timeHuman, equals('2 months ago'));

      final routedItem = model.notifications[3];
      expect(routedItem.id, equals(1));
      expect(routedItem.route, equals('/packages'));
      expect(routedItem.webLink, equals('https://lokkha.com/'));
    });

    test('MarkAllReadResponseModel parses read-all response correctly', () {
      final readAllPayload = {
        "success": true,
        "message": "All notifications marked as read.",
        "data": {
          "all_marked_read": true,
        }
      };

      final response = MarkAllReadResponseModel.fromJson(readAllPayload);
      expect(response.allMarkedRead, isTrue);
    });

    test('MarkReadResponseModel parses single read response correctly', () {
      final readSinglePayload = {
        "success": true,
        "message": "Notification marked as read.",
        "data": {
          "marked_read": true,
          "notification_id": 15,
        }
      };

      final response = MarkReadResponseModel.fromJson(readSinglePayload);
      expect(response.markedRead, isTrue);
      expect(response.notificationId, equals(15));
    });
  });

  group('Module 35: Clean Architecture Use Cases', () {
    test('UseCases correctly delegate calls to NotificationRepository', () async {
      final model = NotificationModel.fromJson(sampleNotificationPayload);
      final mockRepo = _MockNotificationRepository(model);

      final getUseCase = GetNotificationsUseCase(mockRepo);
      final markReadUseCase = MarkNotificationReadUseCase(mockRepo);
      final markAllUseCase = MarkAllNotificationsReadUseCase(mockRepo);

      final fetchResult = await getUseCase(deviceId: 'dev_123');
      expect(fetchResult.unreadCount, equals(15));
      expect(mockRepo.fetchCount, equals(1));

      final markResult = await markReadUseCase(notificationId: 15, deviceId: 'dev_123');
      expect(markResult, isTrue);
      expect(mockRepo.markReadCount, equals(1));
      expect(mockRepo.lastMarkedId, equals(15));

      final markAllResult = await markAllUseCase(deviceId: 'dev_123');
      expect(markAllResult, isTrue);
      expect(mockRepo.markAllReadCount, equals(1));
    });
  });

  group('Module 35: NotificationsNotifier State & Optimistic Updates', () {
    test('fetchNotifications updates state and global unReadNotificationCount', () async {
      final model = NotificationModel.fromJson(sampleNotificationPayload);
      final mockRepo = _MockNotificationRepository(model);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(notificationsNotifierProvider.notifier);
      await notifier.fetchNotifications();

      final state = container.read(notificationsNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.model.unreadCount, equals(15));
      expect(state.model.notifications.length, equals(4));
      expect(unReadNotificationCount.value, equals(15));
      await Future.delayed(Duration.zero);
    });

    test('markAsRead optimistically updates item and decrements unreadCount', () async {
      final model = NotificationModel.fromJson(sampleNotificationPayload);
      final mockRepo = _MockNotificationRepository(model);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(notificationsNotifierProvider.notifier);
      await notifier.fetchNotifications();

      // Mark notification #15 as read
      await notifier.markAsRead(15, true);

      final state = container.read(notificationsNotifierProvider);
      final item15 = state.model.notifications.firstWhere((n) => n.id == 15);
      expect(item15.isRead, isTrue);
      expect(state.model.unreadCount, equals(14));
      expect(unReadNotificationCount.value, equals(14));
      expect(mockRepo.markReadCount, equals(1));
      expect(mockRepo.lastMarkedId, equals(15));
      await Future.delayed(Duration.zero);
    });

    test('markAllAsRead optimistically marks all read and zeroes unreadCount', () async {
      final model = NotificationModel.fromJson(sampleNotificationPayload);
      final mockRepo = _MockNotificationRepository(model);

      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(notificationsNotifierProvider.notifier);
      await notifier.fetchNotifications();

      // Mark all as read
      await notifier.markAllAsRead();

      final state = container.read(notificationsNotifierProvider);
      expect(state.model.unreadCount, equals(0));
      expect(state.model.notifications.every((n) => n.isRead == true), isTrue);
      expect(unReadNotificationCount.value, equals(0));
      expect(mockRepo.markAllReadCount, equals(1));
      await Future.delayed(Duration.zero);
    });
  });

  group('Module 35: UI Widgets Tests', () {
    Widget createWidgetForTesting(Widget child, {ProviderContainer? container}) {
      final widget = ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) {
          return MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('bn'),
            ],
            home: child,
          );
        },
      );

      if (container != null) {
        return UncontrolledProviderScope(
          container: container,
          child: widget,
        );
      }
      return ProviderScope(child: widget);
    }

    testWidgets('NotificationCard renders title, body, human time, and unread dot',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        createWidgetForTesting(
          NotificationCard(
            title: 'Free Exam',
            body: 'সময় নষ্ট না করে ফ্রী পরীক্ষা দেন',
            isRead: false,
            humanTime: '2 months ago',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Free Exam'), findsOneWidget);
      expect(find.text('সময় নষ্ট না করে ফ্রী পরীক্ষা দেন'), findsOneWidget);
      expect(find.text('2 months ago'), findsOneWidget);

      await tester.tap(find.byType(NotificationCard));
      expect(tapped, isTrue);
    });

    testWidgets('NotificationsView renders notifications list, unread badge, and mark-all button',
        (tester) async {
      final model = NotificationModel.fromJson(sampleNotificationPayload);
      final mockRepo = _MockNotificationRepository(model);
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        createWidgetForTesting(
          const NotificationsView(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('নোটিফিকেশন'), findsOneWidget);
      expect(find.text('15'), findsOneWidget); // unread badge in app bar
      expect(find.byIcon(Icons.done_all_rounded), findsOneWidget); // mark all button
      expect(find.text('Free Exam'), findsOneWidget);
      expect(find.text('Quiz'), findsOneWidget);

      // Tap on mark all as read icon
      await tester.tap(find.byIcon(Icons.done_all_rounded));
      await tester.pumpAndSettle();

      expect(mockRepo.markAllReadCount, equals(1));
    });

    testWidgets('NotificationsView renders empty state when notifications is empty',
        (tester) async {
      const emptyModel = NotificationModel(
        status: true,
        unreadCount: 0,
        notifications: [],
      );
      final mockRepo = _MockNotificationRepository(emptyModel);
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        createWidgetForTesting(
          const NotificationsView(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('কোন নোটিফিকেশন নেই'), findsOneWidget);
      expect(find.text('আপনার নতুন সব নোটিফিকেশন এখানে প্রদর্শিত হবে।'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
    });
  });
}
