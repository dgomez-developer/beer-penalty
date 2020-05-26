import 'dart:async';

import 'package:beer_penalty/model/UserProfile.dart';
import 'IBloc.dart';

class UserProfileBloc implements IBloc {
  UserProfile _userProfile;
  UserProfile get selectedLocation => _userProfile;

  final _userProfileController = StreamController<UserProfile>();

  Stream<UserProfile> get userProfileStream => _userProfileController.stream;

  void setUserProfile(UserProfile userProfile) {
    _userProfile = userProfile;
    _userProfileController.sink.add(userProfile);
  }

  @override
  void dispose() {
    _userProfileController.close();
  }
}