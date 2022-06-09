
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/tripdetails.dart';
import '../util/global.dart';
import '../widgets/NotificationDialog.dart';
import '../widgets/progress_dialog.dart';
import 'dart:convert';
import 'package:assets_audio_player/assets_audio_player.dart' as AssetAudioPlayer;

class PushNotificationSystem
{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static final PushNotificationSystem _instance =
  PushNotificationSystem._internal();
  static PushNotificationSystem get instance => _instance;

  Future<dynamic> Function(String? payload)? onNotificationClicked;
  PushNotificationSystem._internal() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future initializeCloudMessaging(BuildContext context) async
  {
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


      //await Firebase.initializeApp();
      //1. Terminated
      //When the app is completely closed and opened directly from the push notification
      FirebaseMessaging.instance.getInitialMessage().then((
          RemoteMessage? remoteMessage) {
        if (remoteMessage != null) {
          print("Received Push not null");
          print(remoteMessage.data);
          //display ride request information - user information who request a ride
          //readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context);
        }
      });



      //2. Foreground
      //When the app is open and it receives a push notification
      FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) async {
        RemoteNotification? notification = remoteMessage.notification;
        AndroidNotification? androidNotification = remoteMessage.notification?.android;
        print("Received Push onMessage");
        print("The trip request id:  ${remoteMessage.data}");

        var tripRequestId = await getTripId(remoteMessage.data);

        fetchTripInfo(tripRequestId,context);

      });


      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

      //3. Background
      //When the app is in the background and opened directly from the push notification.
      FirebaseMessaging.onMessageOpenedApp.listen((
          RemoteMessage remoteMessage) {
        print('A new onMessageOpenedApp event was published!');
        if (onNotificationClicked != null) {
          onNotificationClicked!.call(jsonEncode(remoteMessage.data));
        }
        //display ride request information - user information who request a ride
        //readUserRideRequestInformation(remoteMessage!.data["rideRequestId"], context);
      });


      //messaging.subscribeToTopic("allDrivers");
     // messaging.subscribeToTopic("allUsers");
    }
  }



  Future generateAndGetToken() async
  {
    String? registrationToken = await messaging.getToken();
    print("FCM Registration Token: ");
    print(registrationToken);

    DocumentReference driverRef = FirebaseFirestore.instance.collection("drivers").doc(currentFirebaseUser?.uid);

    driverRef.set({
      'message_token': registrationToken
    },SetOptions(merge : true));


    //return registrationToken;
  }
  Future<dynamic> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {

    return Future.value();
  }
  Future<String> getTripId(Map<String, dynamic> msgData) async {
    return msgData['rideRequestId'];
  }
  Future<void> onBackgroundMessage(RemoteMessage message) async {
    // log('[onBackgroundMessage] message: ${message.data}', PushNotificationsManager.TAG);
    print(message);
    return Future.value();
  }

  void fetchTripInfo(String tripId, context) async {

    showDialog(context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Fetching Details"));
    DocumentReference tripRef = FirebaseFirestore.instance.collection('trip_requests').doc(tripId);

    DocumentSnapshot snapshot = await tripRef.get();

    Navigator.pop(context);

    if(snapshot.exists) {
      Map<String,dynamic> tripData = snapshot.data() as Map<String,dynamic>;
      assetsAudioPlayer.open(
          AssetAudioPlayer.Audio("assets/music/music_notification.mp3"),
          volume: 0.5
      );
      assetsAudioPlayer.play();
      //assetsAudioPlayer.play();

      print(tripData);
      TripDetails tripDetails = TripDetails(
          tripId: snapshot.id,
          destinationAddress: tripData['dropoff_address'],
          destination: LatLng(double.parse(tripData['dropoff']['latitude']),double.parse(tripData['dropoff']['longitude']) ),

          pickupAddress: tripData['pickup_address'],
          pickup: LatLng(double.parse(tripData['pickup']['latitude']),double.parse(tripData['pickup']['longitude']) ),

          riderName: tripData['rider_name'],
          riderPhone: tripData['rider_phone'],

          paymentMethod: tripData['payment_method']

      );


      showDialog(context: context,
          barrierDismissible: true,
          builder: (context) => NotificationDialog(tripDetails: tripDetails,));
    }
  }
}