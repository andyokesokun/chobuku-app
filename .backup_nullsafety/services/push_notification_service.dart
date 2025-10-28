import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/screens/order_details.dart';
import 'package:active_ecommerce_flutter/screens/login.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/repositories/profile_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:active_ecommerce_flutter/services/navigation_service.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';

final FirebaseMessaging _fcm = FirebaseMessaging.instance;

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  '0', // id
  'High Importance Notifications', // title
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class PushNotificationService {
  Future initialise() async {
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    String? fcmToken = await _fcm.getToken();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    if (fcmToken != null && is_logged_in.$ == true) {
      await ProfileRepository().getDeviceTokenUpdateResponse(fcmToken);
    }

    FirebaseMessaging.onMessage.listen((event) {
      _showMessage(event);

      RemoteNotification? notification = event.notification;
      AndroidNotification? android = event.notification?.android;
      var initializationSettingsAndroid =
          const AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      flutterLocalNotificationsPlugin.initialize(initializationSettings);

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: android.smallIcon,
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onResume: $message");
      _serialiseAndNavigate(message.data);
    });
  }

  void _showMessage(RemoteMessage message) {
    showDialog(
      context: NavigationService.context,
      builder: (context) => AlertDialog(
        content: ListTile(
          title: Text(message.notification?.title ?? ''),
          subtitle: Text(message.notification?.body ?? ''),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('GO'),
            onPressed: () {
              if (is_logged_in.$ == false) {
                ToastComponent.showDialog(
                  "You are not logged in",
                  gravity: Toast.top,
                  duration: Toast.lengthLong,
                );
                return;
              }
              Navigator.of(context).pop();
              if (message.data['item_type'] == 'order') {
                NavigationService.push(
                  MaterialPageRoute(
                    builder: (_) => OrderDetails(
                      id: int.parse(message.data['item_type_id']),
                      from_notification: true,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _serialiseAndNavigate(Map<String, dynamic> message) {
    if (is_logged_in.$ == false) {
      showDialog(
        context: NavigationService.context,
        builder: (context) => AlertDialog(
          title: const Text("You are not logged in"),
          content: const Text("Please log in"),
          actions: <Widget>[
            TextButton(
              child: const Text('close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Login'),
              onPressed: () {
                Navigator.of(context).pop();
                NavigationService.push(
                  MaterialPageRoute(builder: (_) => Login()),
                );
              },
            ),
          ],
        ),
      );
      return;
    }

    if (message['item_type'] == 'order') {
      NavigationService.push(
        MaterialPageRoute(
          builder: (_) => OrderDetails(
            id: int.parse(message['item_type_id']),
            from_notification: true,
          ),
        ),
      );
    }
  }
}
