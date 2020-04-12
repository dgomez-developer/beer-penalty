import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

import 'ReceivedNotification.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();
final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

void requestPermissionsForiOS() {
  if (Platform.isIOS) {
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

void configLocalNotification() async {
  var initializationSettingsAndroid =
      new AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = new IOSInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
    didReceiveLocalNotificationSubject.add(ReceivedNotification(
        id: id, title: title, body: body, payload: payload));
  });

  var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      print('notification payload: ' + payload);
    }
    selectNotificationSubject.add(payload);
  });
}

void configureDidReceiveLocalNotificationSubject() {
  didReceiveLocalNotificationSubject.stream
      .listen((ReceivedNotification receivedNotification) async{
    String title =
        receivedNotification.title != null ? receivedNotification.title : "";
    String body =
        receivedNotification.body != null ? receivedNotification.body : "";
    String payload = receivedNotification.payload;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.dgomez.developer.beer.penalty', 'Beer penalty channel', 'Beer penalty notifications channel',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker', icon: 'app_icon');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics);
  });
}

void listenIncommingPushNotifications() {
  _firebaseMessaging.configure(onLaunch: (Map<String, dynamic> message) {
    print('On Launch: ' + message.toString());
  }, onMessage: (Map<String, dynamic> message) {
    print('On Message: ' + message.toString());
    showNotification(message);
  }, onResume: (Map<String, dynamic> message) {
    print('On Resume: ' + message.toString());
  });
  _firebaseMessaging.getToken().then((token) {
    print(token);
  });
}

void showNotification(message) async {
  String title =
  message['notification']['title'] != null ? message['notification']['title'] : "";
  String body =
  message['notification']['body'] != null ? message['notification']['body'] : "";
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.developer.dgomez.beer_penalty', 'Beer penalty channel', 'Beer penalty notifications channel',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker', icon: 'app_icon');
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(0, title,
      body, platformChannelSpecifics);
}
