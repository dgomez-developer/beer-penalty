import 'package:beer_penalty/model/UserProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Repository {

  static final String ID_KEY = "ID_KEY";

  static void setUserId(String id) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString(ID_KEY, id);
  }

  static Future<String> getUserId() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    return _prefs.get(ID_KEY);
  }

  static deleteUserId() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.remove(ID_KEY);
  }

  static Future<UserProfile> getUserProfile(String id) async {
    DocumentSnapshot value =
    await Firestore.instance.collection('users').document(id).get();
    if(value.data == null || value.data.isEmpty){
      return null;
    }
    return UserProfile(
        value.data['accessToken'],
        value.data['idToken'],
        value.data['beers'],
        value.data['fcmToken'],
        value.data['userEmail'],
        value.data['userImage'],
        value.data['userName']);
  }

  static Future<UserProfile> setUserProfile(UserProfile user) async {
    DocumentReference value = await Firestore.instance.collection('users').add({
      'accessToken': user.accessToken,
      'idToken': user.idToken,
      'beers': user.beers,
      'fcmToken': user.fcmToken,
      'userEmail': user.email,
      'userImage': user.imageUrl,
      'userName': user.name,
    });
    setUserId(value.documentID);
    return user;
  }

  static Future<UserProfile> updateUserProfile(String userId, UserProfile user) async {
    await Firestore.instance.collection('users').document(userId).updateData({
      'accessToken': user.accessToken,
      'idToken': user.idToken,
      'beers': user.beers,
      'fcmToken': user.fcmToken,
      'userEmail': user.email,
      'userImage': user.imageUrl,
      'userName': user.name,
    });
    return user;
  }

  static deleteUserProfile(String userId) async {
    await Firestore.instance.collection('users').document(userId).delete();
  }

}