import 'package:beer_penalty/model/UserProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserNetworkProvider {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  static const String USERS_REMOTE_DATABASE = 'users';
  static const String USER_ACCESS_TOKEN = 'accessToken';
  static const String USER_ID_TOKEN = 'idToken';
  static const String USER_BEERS = 'beers';
  static const String USER_FCM_TOKEN = 'fcmToken';
  static const String USER_EMAIL = 'userEmail';
  static const String USER_IMAGE_URL = 'userImage';
  static const String USER_NAME = 'userName';

  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signIn() async {
    // Login
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;
    String accessToken = googleSignInAuthentication.accessToken;
    String idToken = googleSignInAuthentication.idToken;
    FirebaseUser user = await authenticateUserInFirebase(accessToken, idToken);
    return new UserProfile(
        null,
        accessToken,
        idToken,
        0,
        "",
        user.email,
        user.photoUrl,
        user.displayName);
  }

  Future autoSignIn(UserProfile profile) async {
    // Login
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signInSilently();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;
    String accessToken = googleSignInAuthentication.accessToken;
    String idToken = googleSignInAuthentication.idToken;
    FirebaseUser user = await authenticateUserInFirebase(accessToken, idToken);
    return new UserProfile(
        profile.id,
        accessToken,
        idToken,
        profile.beers,
        profile.fcmToken,
        user.email,
        user.photoUrl,
        user.displayName);
  }

  Future<FirebaseUser> authenticateUserInFirebase(String accessToken, String idToken) async {
    // Auth user in Google
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: accessToken,
      idToken: idToken,
    );
    final AuthResult authResult = await _auth.signInWithCredential(credential);

    // Auth user in Firebase
    final FirebaseUser user = authResult.user;

    if(user.isAnonymous || await user.getIdToken() == null) {
      throw new Exception('Invalid Firebase user');
    }

    // Get current user information from Firebase
    final FirebaseUser currentUser = await _auth.currentUser();
    validateUserInfo(currentUser, user);

    return user;

  }

  Future signOut(String userId) async {
    await googleSignIn.signOut();
    deleteUserProfile(userId);
    print("User Sign Out");
  }

  void deleteUserProfile(String userId) async {
    await Firestore.instance
        .collection(USERS_REMOTE_DATABASE)
        .document(userId)
        .delete();
  }

  Future<UserProfile> getUserProfile(String id) async {
    DocumentSnapshot value = await Firestore.instance
        .collection(USERS_REMOTE_DATABASE)
        .document(id)
        .get();
    if (value.data == null || value.data.isEmpty) {
      return null;
    }
    return UserProfile(
        id,
        value.data[USER_ACCESS_TOKEN],
        value.data[USER_ID_TOKEN],
        value.data[USER_BEERS],
        value.data[USER_FCM_TOKEN],
        value.data[USER_EMAIL],
        value.data[USER_IMAGE_URL],
        value.data[USER_NAME]);
  }

  Future<UserProfile> createUserProfile(UserProfile user) async {
    DocumentReference value =
        await Firestore.instance.collection(USERS_REMOTE_DATABASE).add({
      USER_ACCESS_TOKEN: user.accessToken,
      USER_ID_TOKEN: user.idToken,
      USER_BEERS: user.beers,
      USER_FCM_TOKEN: user.fcmToken,
      USER_EMAIL: user.email,
      USER_IMAGE_URL: user.imageUrl,
      USER_NAME: user.name,
    });
    return UserProfile(value.documentID, user.accessToken, user.idToken,
        user.beers, user.fcmToken, user.email, user.imageUrl, user.name);
  }

  Future<UserProfile> updateUserProfile(UserProfile user) async {
    await Firestore.instance
        .collection(USERS_REMOTE_DATABASE)
        .document(user.id)
        .updateData({
      USER_ACCESS_TOKEN: user.accessToken,
      USER_ID_TOKEN: user.idToken,
      USER_BEERS: user.beers,
      USER_FCM_TOKEN: user.fcmToken,
      USER_EMAIL: user.email,
      USER_IMAGE_URL: user.imageUrl,
      USER_NAME: user.name,
    });
    return user;
  }

  validateUserInfo(FirebaseUser currentUser, FirebaseUser user) {

   String name = user.displayName;
   String email = user.email;
   String imageUrl = user.photoUrl;

   if(currentUser.uid != user.uid || name == null || name.isEmpty || imageUrl == null || email == null){
     throw new Exception('Imcomplete User profile information');
   }

   // Only taking the first part of the name, i.e., First Name
   if (name.contains(" ")) {
     name = name.substring(0, name.indexOf(" "));
   }

  }
}
