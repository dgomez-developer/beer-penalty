import 'dart:async';

import 'package:beer_penalty/model/User.dart';
import 'package:beer_penalty/bloc/state/BeersBlocState.dart';
import 'package:beer_penalty/repository/ApplicationRepository.dart';
import 'package:beer_penalty/repository/BeersRepository.dart';
import 'package:beer_penalty/repository/UserRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BeersBloc {
  final _repository = BeersRepository();
  final _applicationRepository = ApplicationRepository();
  final _userRepository = UserRepository();
  BeersBlocState _currentState;
  StreamSubscription<List<User>> _fetchUsersSub;

  final _beersController = StreamController<BeersBlocState>.broadcast();

  Stream<BeersBlocState> get beersStream => _beersController.stream;

  BeersBloc() {
    _currentState = BeersBlocState.empty();
  }

  void init() {
    listenPushNotifications();
  }

  getUserProfilePicture() {
    _userRepository.getUserProfile().then((profile) {
      if(profile != null) {
        _currentState.profile = profile.imageUrl;
        _beersController.add(_currentState);
      }
    });
  }

  fetchBoard() {
    _fetchUsersSub?.cancel();

    _currentState.loading = true;
    _beersController.add(_currentState);

    _repository.getBoard().listen((dynamic snapshot) {
      if (!snapshot.hasData) {
        _currentState.loading = true;
      } else {
        _currentState.loading = false;
        _currentState.users = map(snapshot.data.documents);
      }
      _beersController.add(_currentState);
    });
  }

  List<User> map(List<DocumentSnapshot> documents) {
    List<User> users = new List<User>();
    for (int i = 0; i < documents.length; i++) {
      users.add(new User(documents[i]['userName'], documents[i]['beers'],
          documents[i]['userImage']));
    }
    return users;
  }

  void listenPushNotifications() {
    _applicationRepository.listenPushNotifications().listen((event) {
      // Show a notification
      _applicationRepository.showNotification(event);
    });
  }

  void dispose() async {
    await _beersController.stream.drain();
    _beersController.close();
    await _applicationRepository.listenPushNotifications().drain();
    _applicationRepository.destroy();
  }
}
