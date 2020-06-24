import 'package:beer_penalty/provider/BeersNetworkProvider.dart';

class BeersRepository {

  final beersProvider = BeersNetworkProvider();

  Stream getBoard() => beersProvider.fetchUsers();
}