import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/tripdetails.dart';
import '../util/global.dart';
import '../widgets/NotificationDialog.dart';
import '../widgets/progress_dialog.dart';

class PushNotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  BuildContext? applicationContext;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static final PushNotificationService _instance =
  PushNotificationService._internal();
  static PushNotificationService get instance => _instance;

  Future<dynamic> Function(String? payload)? onNotificationClicked;
  PushNotificationService._internal() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }
  init(context) async {
    await Firebase.initializeApp();

    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true
    );
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher_foreground');
    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User grant permission');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        RemoteNotification? notification = message.notification;
        AndroidNotification? androidNotification = message.notification?.android;

        //var tripRequestId = await getTripId(message.data);

        //fetchTripInfo(tripRequestId,context);
        print("The trip request id:  ${message.data}");
        if(notification != null && androidNotification != null){

          const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              'messages_channel_id',
              'Chat messages',
              channelDescription: 'Chat messages will be received here',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: true,
              color: Colors.green,
              icon: 'launch_background'
          );


          // AndroidNotificationDetails(
          //     channel.id,
          //     channel.name,
          //     channelDescription: channel.description,
          //     icon: 'launch_background'
          // );
          const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              platformChannelSpecifics);
        }
      });

      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
        if (onNotificationClicked != null) {
          onNotificationClicked!.call(jsonEncode(message.data));
        }
      });



      messaging.subscribeToTopic('allDrivers');
      messaging.subscribeToTopic('allUsers');
    } else {
      print('User declined or has not accepted permission');
    }
  }


  Future<String?> getToken() async {

    String? token = await messaging.getToken();

    DocumentReference driverRef = FirebaseFirestore.instance.collection("drivers").doc(currentFirebaseUser?.uid);

    driverRef.set({
      'message_token': token
    },SetOptions(merge : true));


    return token;
  }

  Future<dynamic> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {

    return Future.value();
  }

  /*
  Future<String> getTripId(Map<String, dynamic> msgData) async {
    return msgData['trip_id'];
  }
*/
  void fetchTripInfo(String tripId, context) async {

    showDialog(context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Fetching Details"));
    DocumentReference tripRef = FirebaseFirestore.instance.collection('tripRequests').doc(tripId);

    DocumentSnapshot snapshot = await tripRef.get();

    Navigator.pop(context);

    if(snapshot.exists) {
      Map<String,dynamic> tripData = snapshot.data() as Map<String,dynamic>;
      /*assetsAudioPlayer.open(
          AssetAudioPlayer.Audio("sounds/alert.mp3"),
          volume: 0.5
      );
      assetsAudioPlayer.play();


       */

      TripDetails tripDetails = TripDetails(
          tripId: snapshot.id,
          pickupAddress: "VC Bird International Airport",
          //tripData['location']['pickup_address'],
          destinationAddress: "Sandals",
          //tripData['location']['destination_address'],
          pickup: null,
          // LatLng(tripData['location']['latitude'],tripData['location']['longitude'] ),
          destination: null,
          //LatLng(tripData['location']['latitude'],tripData['location']['longitude'] ),
          paymentMethod: tripData['paymentMethod']
      );


      showDialog(context: context,
          barrierDismissible: true,
          builder: (context) => NotificationDialog(tripDetails: tripDetails,));
    }
  }
}


Future<void> onBackgroundMessage(RemoteMessage message) async {
  // log('[onBackgroundMessage] message: ${message.data}', PushNotificationsManager.TAG);
  showNotification(message);
  return Future.value();
}

showNotification(RemoteMessage message) async {
  // log('[showNotification] message: ${message.data}',
  //     PushNotificationsManager.TAG);
  Map<String, dynamic> data = message.data;

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'messages_channel_id',
    'Chat messages',
    channelDescription: 'Chat messages will be received here',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
    color: Colors.green,
  );
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  FlutterLocalNotificationsPlugin().show(
    6543,
    "Chat sample",
    data['message'].toString(),
    platformChannelSpecifics,
    payload: jsonEncode(data),
  );

}