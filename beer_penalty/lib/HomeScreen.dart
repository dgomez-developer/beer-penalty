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
          title: Text("Beer Penalty Board",
              style: TextStyle(fontFamily: 'Funtasia', fontSize: 30)),
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
            if (!snapshot.hasData)
              return new Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/beer-bg.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                      alignment: Alignment.center,
                      child: Text('Loading beers ...')));
            return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/beer-bg.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return _buildUser(context, snapshot.data.documents[index]);
                  },
                ));
          },
        ));
  }
}

Widget _buildUser(BuildContext context, DocumentSnapshot document) {
  return Container(
      color: Colors.grey.withAlpha(50),
      child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(document['userImage']),
            radius: 30,
            backgroundColor: Colors.transparent,
          ),
          title: Text(document['userName'],
              style: TextStyle(fontFamily: 'Funtasia', fontSize: 20)),
          subtitle: Column(children: [
            SizedBox(height: 10),
            (document['beers'] == 0)
                ? Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('Congratulations you have no beers!'))
                : createBeers(document['beers'], context),
            SizedBox(height: 10),
            Row(
                children: [
              GestureDetector(
                onTap:(){
                  updateBeers(document, document['beers'] + 1);
                },
                child: Icon(Icons.add, size: 25)
              ),
                  SizedBox(width: 10),

                  GestureDetector(
                  onTap:(){
                    updateBeers(document, document['beers'] - 1);
                  },
                  child: Icon(Icons.remove, size: 25)
              ),
            ])
          ])));
}

Widget createBeers(int beers, BuildContext context) {
  return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            alignment: WrapAlignment.start,
            direction: Axis.horizontal,
            children: createListOfBeerImages(beers),
          )));
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
