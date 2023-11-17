import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings,

    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification(int id, String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'channelId', 'channelName',
        importance: Importance.max, priority: Priority.high
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(id, title, body, platformDetails);
  }
}
