import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLocalProvider {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final String ID_KEY = "ID_KEY";

  void setUserId(String id) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString(ID_KEY, id);
  }

  Future<String> getUserId() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    return _prefs.get(ID_KEY);
  }

  void deleteUserId() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.remove(ID_KEY);
  }

  Stream<String> listenForFcmTokenChanges() {
    return _firebaseMessaging.getToken().asStream();
  }

  Future<String> getFcmToken() async {
    // Get FCM token for this user
    return await _firebaseMessaging.getToken();
  }

}
