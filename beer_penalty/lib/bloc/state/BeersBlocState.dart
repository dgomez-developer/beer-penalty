import 'package:beer_penalty/model/User.dart';

class BeersBlocState {
  bool loading;
  List<User> users;
  String profile;

  BeersBlocState(this.loading, this.users, this.profile);

  BeersBlocState.empty() {
    loading = false;
    users = null;
    profile = "https://i.picsum.photos/id/1062/200/200.jpg";
  }
}