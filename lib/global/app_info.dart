import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../models/directions.dart';

class AppInfo extends ChangeNotifier
{
  Directions? userPickUpLocation, userDropOffLocation;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  void updatePickUpLocation(Directions userPickUpAddress){
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }
  void updateDropOffLocation(Directions userDropOffAddress){
    userDropOffLocation = userDropOffAddress;
    notifyListeners();
  }

  void cancelRide(){
    userDropOffLocation = null;
    notifyListeners();
  }

  void subscribeToNotifications(){
    messaging.subscribeToTopic("allDrivers");
    notifyListeners();
  }
  void unsubscribeFromNotifications(){
    messaging.unsubscribeFromTopic("allDrivers");
    notifyListeners();
  }
}