import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxeeze_driver/push_notifications/push_notification_system.dart';


import '../global/app_info.dart';
import '../util/global.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? newGoogleMapController;



  var geoLocation = Geolocator();
  bool serviceEnabled = false;
  LocationPermission? _locationPermission;
  late CollectionReference tripRequestsRef;

  String statusText = "Offline";
  Color statusColor = Colors.grey;
  bool isDriverAvailable = false;

  checkLocationPermission() async
  {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    _locationPermission = await Geolocator.checkPermission();


    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();

      if (_locationPermission == LocationPermission.denied) {
        return;
      }
    }

    if (_locationPermission == LocationPermission.deniedForever) {
      return;
    }

    /*
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied)
    {
      _locationPermission = await Geolocator.requestPermission();
    }

     */
  }
  locateDriverPosition() async {
    //gives the position of current user
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng latLgPosition = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLgPosition, zoom: 14);
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));



  }

  getCurrentDriverInfo() async {
    currentFirebaseUser = fAuth.currentUser;


    PushNotificationSystem pushNotificationSystem =  await PushNotificationSystem.instance;
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tripRequestsRef = _firestore.collection('trip_requests');
    checkLocationPermission();
    getCurrentDriverInfo();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: VCBird,
        onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            newGoogleMapController = controller;
            newGoogleMapController!.setMapStyle(darkMap());

            locateDriverPosition();
        },),
        statusText != "Online"
            ? Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          color: Colors.black87,
        )
            : Container(),
        Positioned(
          top: statusText != "Online"
              ? MediaQuery.of(context).size.height * 0.46
              : 25,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: ()
                {
                  if(isDriverAvailable != true) //offline
                      {
                    setOnline();
                    updateDriverLocation();

                    setState(() {
                      statusText = "Online";
                      isDriverAvailable = true;
                      statusColor = Colors.transparent;
                    });

                    //display Toast
                    Fluttertoast.showToast(msg: "you are Online Now");
                  }
                  else //online
                      {
                    setOffline();

                    setState(() {
                      statusText = "Offline";
                      isDriverAvailable = false;
                      statusColor = Colors.grey;
                    });

                    //display Toast
                    Fluttertoast.showToast(msg: "you are Offline Now");
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: statusColor,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: statusText != "Online"
                    ? Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.phonelink_ring,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  setOnline() async
  {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    driverCurrentPosition = pos;
    Provider.of<AppInfo>(context, listen: false).subscribeToNotifications();
    Geofire.initialize("activeDrivers");

    Geofire.setLocation(
        currentFirebaseUser!.uid,
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude
    );

    Map driverLatLngDataMap =
      {
        "latitude": driverCurrentPosition!.latitude.toString(),
        "longitude": driverCurrentPosition!.longitude.toString(),
      };

    _firestore
        .collection("drivers")
        .doc(currentFirebaseUser!.uid)
        .set({
          "rideStatus": "idle",
          'driverLocation': driverLatLngDataMap
          },SetOptions(merge : true));

  }

  updateDriverLocation()
  {
    streamSubscriptionPosition = Geolocator.getPositionStream()
        .listen((Position position)
    {
      driverCurrentPosition = position;

      if(isDriverAvailable == true)
      {
        Geofire.setLocation(
            currentFirebaseUser!.uid,
            driverCurrentPosition!.latitude,
            driverCurrentPosition!.longitude
        );
      }

      LatLng latLng = LatLng(
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  setOffline()
  {
    Geofire.removeLocation(currentFirebaseUser!.uid);
    Provider.of<AppInfo>(context, listen: false).unsubscribeFromNotifications();



    Future.delayed(const Duration(milliseconds: 2000), ()
    {

    });
  }
}
