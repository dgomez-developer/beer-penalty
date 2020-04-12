import 'package:beer_penalty/UserProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'Repository.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
String name;
String email;
String imageUrl;

// sign in anonymously
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

Future<UserProfile> signInWithGoogle() async {

  final String userId = await Repository.getUserId();
  String accessToken = "";
  String idToken = "";
  UserProfile userProfile;
  if(userId == null) {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;
    accessToken = googleSignInAuthentication.accessToken;
    idToken = googleSignInAuthentication.idToken;
  } else {
    userProfile = await Repository.getUserProfile(userId);
    accessToken = userProfile.accessToken;
    idToken = userProfile.idToken;
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signInSilently();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;
    accessToken = googleSignInAuthentication.accessToken;
    idToken = googleSignInAuthentication.idToken;
  }

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: accessToken,
    idToken: idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);

  // Update user data
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);
  assert(user.email != null);
  assert(user.displayName != null);
  assert(user.photoUrl != null);
  name = user.displayName;
  email = user.email;
  imageUrl = user.photoUrl;

  // Only taking the first part of the name, i.e., First Name
  if (name.contains(" ")) {
    name = name.substring(0, name.indexOf(" "));
  }

  String fcmToken = await FirebaseMessaging().getToken();

  if(userId == null) {
    userProfile = new UserProfile(
        accessToken,
        idToken,
        0,
        fcmToken,
        email,
        imageUrl,
        name);
    await Repository.setUserProfile(userProfile);
  } else {
    userProfile = new UserProfile(
        accessToken,
        idToken,
        userProfile.beers,
        fcmToken,
        email,
        imageUrl,
        name);
    await Repository.updateUserProfile(userId, userProfile);
  }
  return userProfile;
}

Future signOutGoogle() async {
  await googleSignIn.signOut();
  String userId = await Repository.getUserId();
  await Repository.deleteUserProfile(userId);
  await Repository.deleteUserId();
  print("User Sign Out");
}
