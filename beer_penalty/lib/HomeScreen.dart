import 'package:beer_penalty/Repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'LoginScreen.dart';
import 'SignIn.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String profileImageUrl = "https://i.picsum.photos/id/1062/200/200.jpg";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Repository.getUserId().then((userId) => {
            Repository.getUserProfile(userId).then((value) => {
                  setState(() {
                    profileImageUrl = value.imageUrl;
                  })
                })
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Beer Penalty"),
          actions: <Widget>[
            PopupMenuButton(
                onSelected: (value) {
                  signOutGoogle().then((value) => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (Route<dynamic> route) => false,
                      ));
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                      new PopupMenuItem(
                          value: "doLogOut", child: Text("Sign out"))
                    ],
                icon: CircleAvatar(
                  backgroundImage: NetworkImage(profileImageUrl),
                  radius: 60,
                  backgroundColor: Colors.transparent,
                ))
          ],
        ),
        body: StreamBuilder(
          stream: Firestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading');
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                return _buildUser(context, snapshot.data.documents[index]);
              },
            );
          },
        ));
  }
}

Widget _buildUser(BuildContext context, DocumentSnapshot document) {
  return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(document['userImage']),
        radius: 30,
        backgroundColor: Colors.transparent,
      ),
      title: Text(document['userName']),
      subtitle: Column(children: [
        (document['beers'] == 0)
            ? Text('Congratulations you have no beers!')
            : createBeers(document['beers']),
        Row(children: [
          IconButton(
            icon: Icon(Icons.add, size: 20),
            onPressed: () {
              updateBeers(document, document['beers'] + 1);
            },
          ),
          IconButton(
            icon: Icon(Icons.remove, size: 20),
            onPressed: () {
              updateBeers(document, document['beers'] - 1);
            },
          )
        ])
      ]));
}

Widget createBeers(int beers) {
  return Wrap(
    alignment: WrapAlignment.start,
    runSpacing: 5.0,
    spacing: 5.0,
    children: createListOfBeerImages(beers),
  );
}

List<Widget> createListOfBeerImages(int beers) {
  List<Image> beersList = new List();
  for (int i = 0; i < beers; i++) {
    beersList.add(Image.asset('assets/beer-icon.png', width: 20, height: 20));
  }
  return beersList;
}

Future updateBeers(DocumentSnapshot document, int beers) async {
  if (beers < 0) {
    beers = 0;
  }
  Firestore.instance.runTransaction((transaction) async {
    DocumentSnapshot freshSnap = await transaction.get(document.reference);
    await transaction.update(freshSnap.reference, {'beers': beers});
  });
}
