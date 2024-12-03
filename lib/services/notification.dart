import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/controllers/notificationController.dart';
import 'package:hair_main_street/pages/homePage.dart';
import 'package:hair_main_street/pages/notifcation.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void navigateToNotifications() {
  Get.to(() => NotificationsPage());
  // Get.offAll(() => const HomePage());
  // Get.find<BottomNavController>().changeTabIndex(1);
}

var androidChannel = const AndroidNotificationChannel(
  "hair_main_street",
  "hair_main_street",
  importance: Importance.high,
);

Future handleBackgroundNotification(RemoteMessage message) async {
  print(message.notification?.title);
  print(message.notification?.body);
  print(message.data);
  navigateToNotifications();

  // final notification = message.notification;
  // if (notification == null) {
  //   return;
  // } else {
  //   flutterLocalNotificationsPlugin.show(
  //       notification.hashCode,
  //       notification.title,
  //       notification.body,
  //       NotificationDetails(
  //         android: AndroidNotificationDetails(
  //             androidChannel.id, androidChannel.name,
  //             icon: "@drawable/std_icon"),
  //       ),
  //       payload: jsonEncode(message.toMap()));
  // }
}

class NotificationService {
  final FirebaseMessaging fCM = FirebaseMessaging.instance;

  final db = FirebaseFirestore.instance;

  final auth = FirebaseAuth.instance;

  CollectionReference userProfileCollection =
      FirebaseFirestore.instance.collection("userProfile");

  CollectionReference ordersCollection =
      FirebaseFirestore.instance.collection('orders');

  CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chat');

  Future<String?> getDeviceToken() async {
    var token = await fCM.getToken();
    print(token);
    return token;
  }

  void subscribeToTopics(String userType, String userID) async {
    await fCM.subscribeToTopic("${userType}_$userID");
  }

  Future<void> init() async {
    // Request permission for notifications (iOS only)
    await fCM.requestPermission();

    //making the settings
    var androidInitialize =
        const AndroidInitializationSettings('@drawable/hms_main');
    var iosInitialize = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    var initializationSettings =
        InitializationSettings(android: androidInitialize, iOS: iosInitialize);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) => Get.to(
        () => NotificationsPage(
          data: details.payload,
        ),
      ),
    );

    // Set up notification handlers
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground notification
      final notification = message.notification;
      if (notification == null) {
        return;
      } else {
        BigTextStyleInformation bigTextStyleInformation =
            BigTextStyleInformation(notification.body!,
                htmlFormatBigText: true,
                contentTitle: notification.title!,
                htmlFormatContentTitle: true);
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                androidChannel.id,
                androidChannel.name,
                icon: "@drawable/hms_main",
                styleInformation: bigTextStyleInformation,
              ),
              iOS: DarwinNotificationDetails(
                subtitle: notification.body,
                presentSound: true,
                presentBadge: true,
              ),
            ),
            payload: jsonEncode(message.toMap()));
      }
      print("Foreground Notification: ${message.notification!.title}");
    });

    //handles background notifications
    FirebaseMessaging.onBackgroundMessage(handleBackgroundNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      navigateToNotifications();
      // Handle notification when the app is in the background
      print("Background Notification: $message");
    });

    // Retrieve an initial notification when the app is in the terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final notification = initialMessage.notification;
      if (notification == null) {
        return;
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          navigateToNotifications();
        });
      }
      print("Terminated Notification: $initialMessage");
    }
  }

  void unsubscribeFromTopics(List<String> topics) {
    for (String topic in topics) {
      fCM.unsubscribeFromTopic(topic);
    }
  }
  // Additional methods for subscribing, unsubscribing, etc.
}
