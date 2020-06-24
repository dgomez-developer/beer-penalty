import 'package:beer_penalty/model/Notification.dart';
import 'package:beer_penalty/provider/ApplicationLocalProvider.dart';

class ApplicationRepository {

  final applicationLocalProvider = ApplicationLocalProvider();

  void initApp() {
    applicationLocalProvider.requestPermissionsForIosIfNeeded();

  }

  Stream<Notification> listenPushNotifications() {
    return applicationLocalProvider.listenToIncommingPushNotifications();
  }

  void showNotification(Notification event) {
    applicationLocalProvider.showNotification(event);
  }

  void destroy() {
    applicationLocalProvider.close();
  }
}