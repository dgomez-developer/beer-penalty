import 'package:beer_penalty/model/UserProfile.dart';
import 'package:beer_penalty/provider/UserLocalProvider.dart';
import 'package:beer_penalty/provider/UserNetworkProvider.dart';

class UserRepository {
  final userNetworkProvider = new UserNetworkProvider();
  final userLocalProvider = new UserLocalProvider();

  void init() async {
    userLocalProvider.listenForFcmTokenChanges().listen((fcmToken) async {
      String userId = await userLocalProvider.getUserId();
      if (userId != null) {
        UserProfile storedProfile =
            await userNetworkProvider.getUserProfile(userId);
        UserProfile userWithToken = UserProfile(
            storedProfile.id,
            storedProfile.accessToken,
            storedProfile.idToken,
            storedProfile.beers,
            fcmToken,
            storedProfile.email,
            storedProfile.imageUrl,
            storedProfile.name);
        await userNetworkProvider.updateUserProfile(userWithToken);
      }
    });
  }

  Future signOut() async {
    String userId = await userLocalProvider.getUserId();
    await userNetworkProvider.signOut(userId);
    userLocalProvider.deleteUserId();
  }

  Future<UserProfile> signIn() async {
    String userId = await userLocalProvider.getUserId();
    UserProfile userProfile;
    if (userId == null) {
      UserProfile createdUserProfile = await userNetworkProvider.signIn();
      String fcmToken = await userLocalProvider.getFcmToken();
      UserProfile userWithToken = UserProfile(
          createdUserProfile.id,
          createdUserProfile.accessToken,
          createdUserProfile.idToken,
          createdUserProfile.beers,
          fcmToken,
          createdUserProfile.email,
          createdUserProfile.imageUrl,
          createdUserProfile.name);
      userProfile = await userNetworkProvider.createUserProfile(userWithToken);
      userLocalProvider.setUserId(userProfile.id);
    } else {
      UserProfile storedProfile =
          await userNetworkProvider.getUserProfile(userId);
      UserProfile updatedUserProfile =
          await userNetworkProvider.autoSignIn(storedProfile);
      String fcmToken = await userLocalProvider.getFcmToken();
      UserProfile userWithToken = UserProfile(
          updatedUserProfile.id,
          updatedUserProfile.accessToken,
          updatedUserProfile.idToken,
          updatedUserProfile.beers,
          fcmToken,
          updatedUserProfile.email,
          updatedUserProfile.imageUrl,
          updatedUserProfile.name);
      userProfile = await userNetworkProvider.updateUserProfile(userWithToken);
    }
    return userProfile;
  }

  Future<UserProfile> getUserProfile() async {
    String userId = await userLocalProvider.getUserId();
    if (userId != null) {
      UserProfile storedProfile =
          await userNetworkProvider.getUserProfile(userId);
      return storedProfile;
    }
    return null;
  }

  void destroy() {
    userLocalProvider.listenForFcmTokenChanges().drain();
  }
}
