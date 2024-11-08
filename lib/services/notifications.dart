import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import 'package:motion_app/main.dart';

import 'package:intl/intl.dart';

class PushNotification {
  final _firebaseMessaging = FirebaseMessaging.instance;
  User? user = FirebaseAuth.instance.currentUser;
  final AndroidNotificationChannel _androidChannel =
      const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // name
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed('/invitationList', arguments: message);
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final FCMToken = await _firebaseMessaging.getToken();
    if (FCMToken != null && user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'fcmToken': FCMToken});
    }
    requestExactAlarmPermission();
    initPushNotifications();
    initLocalNotifications();
    scheduleDueDateNotifications();
  }

  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _localNotifications.initialize(settings);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .createNotificationChannel(_androidChannel);
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
              _androidChannel.id, _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@drawable/ic_launcher'),
        ),
      );
    });
  }

  Future<void> scheduleDueDateNotifications() async {
    final now = DateTime.now();
    final upcomingDueDateThreshold =
        now.add(Duration(days: 3)); // e.g., 3 days before

    QuerySnapshot projectsSnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .where('dueDate', isGreaterThan: now)
        .where('dueDate', isLessThanOrEqualTo: upcomingDueDateThreshold)
        .get();

    for (var projectDoc in projectsSnapshot.docs) {
      final projectData = projectDoc.data() as Map<String, dynamic>;
      final dueDate = (projectData['dueDate'] as Timestamp).toDate();
      final projectTitle = projectData['title'];

      // Calculate the scheduled notification time (e.g., 3 days before due date)
      final notificationTime =
          tz.TZDateTime.from(dueDate.subtract(Duration(days: 3)), tz.local);

      // Schedule notification
      await _localNotifications.zonedSchedule(
        projectDoc.id.hashCode,
        'Upcoming Project Due Date',
        'The project "$projectTitle" is due on ${DateFormat('yyyy-MM-dd').format(dueDate)}.',
        notificationTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode
            .exactAllowWhileIdle, // Optional if repeating at specific time
      );
    }
  }

  Future<void> requestExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isDenied) {
      // Display dialog to redirect user to settings
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: Text("Permission Required"),
          content: const Text(
            "To schedule notifications precisely, please enable the 'Exact Alarms' permission in settings.",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await openAppSettings();
                Navigator.pop(context);
              },
              child: Text("Open Settings"),
            ),
          ],
        ),
      );
    }
  }
}
