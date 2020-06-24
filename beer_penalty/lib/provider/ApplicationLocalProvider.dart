import 'dart:async';
import 'dart:io';

import 'package:beer_penalty/model/Notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ApplicationLocalProvider {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final _pushNotificationsController =
      StreamController<Notification>.broadcast();

  void requestPermissionsForIosIfNeeded() {
    if (!kIsWeb && Platform.isIOS) {
      _firebaseMessaging
          .requestNotificationPermissions(const IosNotificationSettings(
        badge: true,
        sound: true,
        alert: true,
      ));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
    }
  }

  Stream<Notification> listenToIncommingPushNotifications() {
    if(!kIsWeb) {
      // ignore: missing_return
      _firebaseMessaging.configure(onLaunch: (Map<String, dynamic> message) {
        print('On Launch: ' + message.toString());
        // ignore: missing_return
      }, onMessage: (Map<String, dynamic> message) {
        print('On Message: ' + message.toString());
        _pushNotificationsController.add(Notification(
            message['notification']['title'] != null
                ? message['notification']['title']
                : "",
            message['notification']['body'] != null
                ? message['notification']['body']
                : ""));
        // ignore: missing_return
      }, onResume: (Map<String, dynamic> message) {
        print('On Resume: ' + message.toString());
      });
    }
    return _pushNotificationsController.stream;
  }

  void showNotification(Notification event) {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.developer.dgomez.beer_penalty',
        'Beer penalty channel',
        'Beer penalty notifications channel',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker',
        icon: 'app_icon');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    _flutterLocalNotificationsPlugin.show(
        0, event.title, event.message, platformChannelSpecifics);
  }

  void close() {
    _pushNotificationsController.close();
  }
}
