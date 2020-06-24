

class UserProfile {

  final String accessToken;
  final String idToken;
  final int beers;
  final String fcmToken;
  final String email;
  final String imageUrl;
  final String name;
  final String id;

  UserProfile(
      this.id,
      this.accessToken,
      this.idToken,
      this.beers,
      this.fcmToken,
      this.email,
      this.imageUrl,
      this.name);

}