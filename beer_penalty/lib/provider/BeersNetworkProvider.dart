import 'package:cloud_firestore/cloud_firestore.dart';

class BeersNetworkProvider {

  Stream fetchUsers() => Firestore.instance.collection('users').snapshots();

}