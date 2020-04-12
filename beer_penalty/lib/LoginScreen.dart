
import 'package:beer_penalty/PushNotifications.dart';
import 'package:beer_penalty/UserProfile.dart';
import 'package:flutter/material.dart';

import 'HomeScreen.dart';
import 'Navigator.dart';
import 'SignIn.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  void initState() {
    super.initState();
    requestPermissionsForiOS();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: signInWithGoogle(),
      builder: (BuildContext context, AsyncSnapshot<UserProfile> snapshot) {
        if (snapshot.hasData) {
          navigateTo(context, HomeScreen());
          return _buildSplash();
        } else if (snapshot.hasError) {
          return _buildSplashWithLoginButton();
        } else {
          return _buildSplash();
        }
      },
    );
  }

  Scaffold _buildSplash() {
    return Scaffold(
      body: Container(
        color: Colors.teal,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/beer-icon.png', width: 150, height: 150),
            ],
          ),
        ),
      ),
    );
  }

  Scaffold _buildSplashWithLoginButton() {
    return Scaffold(
      body: Container(
        color: Colors.teal,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/beer-icon.png', width: 150, height: 150),
              SizedBox(height: 50),
              _signInButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.amber,
      onPressed: () {
        signInWithGoogle().whenComplete(() {
          navigateTo(context, HomeScreen());
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google-logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
