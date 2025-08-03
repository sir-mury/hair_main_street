import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hair_main_street/pages/notifcation.dart';
import 'package:logger/logger.dart';

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

@pragma('vm:entry-point')
Future handleBackgroundNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification != null) {
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannel.id,
          androidChannel.name,
          icon: "@drawable/hms_main",
        ),
      ),
      payload: jsonEncode(message.toMap()),
    );
  }
  navigateToNotifications();
}

class NotificationService {
  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 50, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
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
    try {
      var token = await fCM.getToken();
      return token;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<String?> getAPNSToken() async {
    String? token = await fCM.getAPNSToken();
    debugPrint("token: $token");
    return token;
  }

  Future<void> deleteToken() async {
    await fCM.deleteToken();
  }

  handleTokenRefresh() {
    fCM.onTokenRefresh.listen((token) {
      //update the current users token
      var user = auth.currentUser;
      if (user != null) {
        userProfileCollection.doc(user.uid).update({
          "token": token,
        });
      } else {
        logger.e("error updating token");
      }
    }).onError((error) {
      logger.e("There was an error", error: error);
    });
  }

  void subscribeToTopics(String userType, String userID) async {
    await _connectivitySubscription?.cancel();
    try {
      _connectivitySubscription = Connectivity()
          .onConnectivityChanged
          .listen((List<ConnectivityResult> results) async {
        if (results.contains(ConnectivityResult.none)) {
          logger.i("Not Connected to the internet");
        } else if (results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.ethernet) ||
            results.contains(ConnectivityResult.wifi)) {
          if (Platform.isIOS) {
            final apnsToken = await getAPNSToken();
            if (apnsToken != null) {
              // APNS token is available, make FCM plugin API requests...
              try {
                await fCM.subscribeToTopic("${userType}_$userID");
              } catch (e) {
                logger.e("Error subscribing to topic: $e", error: e);
              }
            } else {
              logger
                  .e("Error obtaining APNS tokens while subscribing to topic");
              // Handle the error, maybe retry or log it
              return;
            }
          } else {
            await fCM.subscribeToTopic("${userType}_$userID");
          }
        }
      });
    } catch (e) {
      logger.e("error subscribing to topic $e", error: e);
    }
  }

  _showNotification(RemoteMessage message) {
    final notification = message.notification;
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        notification!.body!,
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

  _notificationHandlers() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground notification
      final notification = message.notification;
      if (notification == null) {
        return;
      } else {
        _showNotification(message);
        logger.i("Foreground Notification: ${message.notification!.title}");
      }
    });

    //handles background notifications
    FirebaseMessaging.onBackgroundMessage(handleBackgroundNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      navigateToNotifications();
      // Handle notification when the app is in the background
      logger.i("Background Notification: ${message.data.toString()}");
    });

    // Retrieve an initial notification when the app is in the terminated state
    RemoteMessage? initialMessage = await fCM.getInitialMessage();
    if (initialMessage != null) {
      final notification = initialMessage.notification;
      if (notification == null) {
        return;
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          navigateToNotifications();
        });
      }
      logger.i("Terminated Notification: $initialMessage");
    }
  }

  Future<void> init() async {
    try {
      // Request permission for notifications (iOS only)
      final settings = await fCM.requestPermission(
        alert: true,
        sound: true,
        badge: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        logger.i("Permission Denied");
        return;
      }

      //handle token refreshes
      handleTokenRefresh();

      //making the settings
      var androidInitialize =
          const AndroidInitializationSettings('@drawable/hms_main');
      var iosInitialize = const DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      var initializationSettings = InitializationSettings(
          android: androidInitialize, iOS: iosInitialize);

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) => Get.to(
          () => NotificationsPage(
            data: details.payload,
          ),
        ),
      );

      if (Platform.isIOS) {
        final apnsToken = await getAPNSToken();
        if (apnsToken != null) {
          // APNS token is available, make FCM plugin API requests...
          logger.i("APNS Token: $apnsToken");
        } else {
          logger.e("Error obtaining APNS tokens");
          return;
        }
      }
      await _notificationHandlers();

      logger.i("Notification Initialized");
    } catch (e) {
      logger.e("FCM error: $e", error: e);
    }
  }

  Future<void> unsubscribeFromTopics(List<String> topics) async {
    try {
      await Future.wait(topics.map((topic) => fCM.unsubscribeFromTopic(topic)));
    } catch (e) {
      logger.e("Error unsubscribing from topics: $e", error: e);
    }
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    logger.i("connectivity subscription disposed");
  }
  // Additional methods for subscribing, unsubscribing, etc.
}
