import 'dart:async';

import 'package:flutter/material.dart';
import 'package:taxeeze_driver/screens/login_screen.dart';
import 'package:taxeeze_driver/util/global.dart';

import 'helpers/auth_methods.dart';
import 'screens/mainscreen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  final AuthMethods _authMethods = AuthMethods();
  //Timer for splash screen
  startTimer() {


    Timer(const Duration(seconds: 3), () async {
      currentUser = await _authMethods.getUserDetails();
      //Send user  to main screen
      if(await fAuth.currentUser != null)
      {

        currentFirebaseUser = fAuth.currentUser;
        print("FIREBASE USER ${currentFirebaseUser}");
        Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
      }
      else
      {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
      }

    });
  }
  @override
  void initState() {
    super.initState();

    startTimer();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo.jpg"),
              const SizedBox(height: 10,),
              const Text(
                "Taxeeze",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
