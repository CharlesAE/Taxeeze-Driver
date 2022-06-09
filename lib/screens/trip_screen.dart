import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../global/app_info.dart';
import '../helpers/location_methods.dart';
import '../models/tripdetails.dart';
import '../util/brand_colors.dart';
import '../util/global.dart';
import '../widgets/TaxeezeButton.dart';
import '../widgets/fare_dialog.dart';
import '../widgets/progress_dialog.dart';

class TripScreen extends StatefulWidget {

   TripDetails? tripDetails;

   TripScreen({this.tripDetails});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  bool serviceEnabled = false;

  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? newGoogleMapController;
  LocationPermission? _locationPermission;
  BitmapDescriptor? iconAnimatedMarker;
  double mapPadding = 0;
  Position? onlineDriverCurrentPosition;
  var geoLocation = Geolocator();
  String? buttonTitle = "Arrived";
  Color? buttonColor = BrandColors.colorGreen;
  String rideStatus = "accepted";
  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};


  String durationFromOriginToDestination = "";
  bool isRequestDirectionDetails = false;

  @override
  Widget build(BuildContext context) {
    createDriverIconMarker();
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            padding: EdgeInsets.only(bottom: mapPadding),
            initialCameraPosition: VCBird,
            polylines: polyLineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              newGoogleMapController = controller;
              newGoogleMapController!.setMapStyle(darkMap());




              setState(() {
                mapPadding = 300;
              });

              var  driverLocation = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

              var userLocation = LatLng(widget.tripDetails!.pickup!.latitude, widget.tripDetails!.pickup!.longitude);
              //locateDriverPosition();
              drawPolyLine(driverLocation, userLocation);
              getRealTimeDriversLocation();
            },),
          /*
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0,
                        spreadRadius: 0.5,
                        offset: Offset(
                            0.7,
                            0.7
                        )
                    )
                  ]
              ),
              height:  255,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical:18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '14 Mins',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Brand-Bold',
                        color: BrandColors.colorAccentPurple,
                      ),
                    ),

                    SizedBox(height: 5,),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.tripDetails!.riderName!, style:  TextStyle(fontSize: 16,
                            fontFamily: 'Brand-Bold',
                        color: BrandColors.colorLightGray),),

                        Padding(padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.call, color: BrandColors.colorLightGray, size: 18,),),

                      ],
                    ),
                    SizedBox(height: 5,),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset("assets/images/pickicon.png", height: 16, width: 16),
                        SizedBox(width: 18,),
                        Expanded(child: Container(child: Text(widget.tripDetails!.pickupAddress!, style:  TextStyle(fontSize: 18, color: BrandColors.colorLightGray), overflow: TextOverflow.ellipsis,))),
                      ],
                    ),
                    SizedBox(height: 15,),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset("assets/images/desticon.png", height: 16, width: 16),
                        SizedBox(width: 18,),
                        Expanded(child: Container(child: Text(widget.tripDetails!.destinationAddress!, style:  TextStyle(fontSize: 18, color: BrandColors.colorLightGray), overflow: TextOverflow.ellipsis,))),
                      ],
                    ),

                    SizedBox(height: 25,),

                    TaxeezeButton(title: 'ARRIVED', color: BrandColors.colorGreen, onPressed: () {

                    })

                  ],
                ),
              ),
            ),
          ),
          */
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                boxShadow:
                [
                  BoxShadow(
                    color: Colors.white30,
                    blurRadius: 18,
                    spreadRadius: .5,
                    offset: Offset(0.6, 0.6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  children: [

                    //duration
                    Text(
                      durationFromOriginToDestination,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightGreenAccent,
                      ),
                    ),

                    const SizedBox(height: 18,),

                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 8,),

                    //user name - icon
                    Row(
                      children: [
                        Text(
                          widget.tripDetails!.riderName!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightGreenAccent,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.phone_android,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18,),

                    //user PickUp Address with icon
                    Row(
                      children: [
                        Image.asset("assets/images/pickicon.png", height: 16, width: 16),
                        const SizedBox(width: 14,),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.tripDetails!.pickupAddress!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20.0),

                    //user DropOff Address with icon
                    Row(
                      children: [
                        Image.asset("assets/images/desticon.png", height: 16, width: 16),
                        const SizedBox(width: 14,),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.tripDetails!.destinationAddress!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24,),

                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 10.0),

                    ElevatedButton.icon(
                      onPressed: ()  async
                      {
                        if(rideStatus == "accepted") {
                          rideStatus = "arrived";

                          DocumentReference tripRef = FirebaseFirestore.instance.collection('trip_requests').doc(widget.tripDetails!.tripId);
                          tripRef.update({
                            'status': rideStatus,
                          });

                          setState(() {
                            buttonTitle = "En Route";
                          });
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) => ProgressDialog(message: "Please Wait...",)
                          );
                          await drawPolyLine(widget.tripDetails!.pickup!, widget.tripDetails!.destination!);
                          //drawPolyLine(driverLocation, userLocation);
                          //await getRealTimeDriversLocation();
                          Navigator.pop(context);
                        }
                        else
                          if(rideStatus == "arrived") {
                            rideStatus = "enroute";

                            DocumentReference tripRef = FirebaseFirestore.instance.collection('trip_requests').doc(widget.tripDetails!.tripId);
                            tripRef.update({
                              'status': rideStatus,
                            });
                            //getRealTimeDriversLocation();
                            setState(() {
                              buttonTitle = "End Trip";
                              buttonColor = BrandColors.colorRed;
                            });
                        }
                          else if (rideStatus == "enroute"){
                            endTrip();
                          }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: buttonColor,
                      ),
                      icon: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 25,
                      ),
                      label: Text(
                        buttonTitle!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
}

  endTrip(){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Please Wait...",)
    );

    DocumentReference tripRef = FirebaseFirestore.instance.collection('trip_requests').doc(widget.tripDetails!.tripId);
    tripRef.update({
      'status': 'complete',
    });

    streamSubscriptionDriverLivePosition!.cancel();
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (BuildContext c)=> FareDialog(
        totalFareAmount: totalFareAmount,
      ),
    );
  }

  saveRideToDriverHistory()
  {

  }


  createDriverIconMarker()
  {
    if(iconAnimatedMarker == null)
    {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "assets/images/car.png").then((value)
      {
        iconAnimatedMarker = value;
      });
    }
  }
  updateDuration() async
  {
    if(isRequestDirectionDetails == false)
    {
      isRequestDirectionDetails = true;

      if(onlineDriverCurrentPosition == null)
      {
        return;
      }

      var originLatLng = LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude,
      ); //Driver current Location

      var destinationLatLng;

      if(rideStatus == "accepted")
      {
        destinationLatLng = widget.tripDetails!.pickup; //user PickUp Location
      }
      else

      {
        destinationLatLng = widget.tripDetails!.destination; //user DropOff Location
      }

      var directionInformation = await LocationMethods.getDirectionDetails(originLatLng, destinationLatLng);

      if(directionInformation != null)
      {
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
        });
      }

      isRequestDirectionDetails = false;
    }
  }
  getRealTimeDriversLocation()
  {
    LatLng oldLatLng = LatLng(0, 0);
    streamSubscriptionDriverLivePosition = Geolocator.getPositionStream()
        .listen((Position position)
    {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      LatLng latLngLiveDriverPosition = LatLng(
        onlineDriverCurrentPosition!.latitude,
        onlineDriverCurrentPosition!.longitude,
      );

      Marker animatingMarker = Marker(
        markerId: const MarkerId("AnimatedMarker"),
        position: latLngLiveDriverPosition,
        icon: iconAnimatedMarker!,
        infoWindow: const InfoWindow(title: "This is your Position"),
      );

      setState(() {
        CameraPosition cameraPosition = CameraPosition(target: latLngLiveDriverPosition, zoom: 16);
        newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markersSet.removeWhere((element) => element.markerId.value == "AnimatedMarker");
        markersSet.add(animatingMarker);
      });
      oldLatLng = latLngLiveDriverPosition;
      updateDuration();

      Map driverLatLngDataMap =
      {
        "latitude": onlineDriverCurrentPosition!.latitude.toString(),
        "longitude": onlineDriverCurrentPosition!.longitude.toString(),
      };

      DocumentReference tripRef = FirebaseFirestore.instance.collection('trip_requests').doc(widget.tripDetails!.tripId);
      tripRef.set({
        'driverLiveLocation': driverLatLngDataMap,
      }, SetOptions(merge: true));
    });
  }
  Future<void> drawPolyLine(LatLng pickup, LatLng destination) async {

    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Please Wait...",)
    );
    var directionDetails = await LocationMethods.getDirectionDetails(pickup, destination);



    Navigator.pop(context);


    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetails!.e_points!);

    pLineCoOrdinatesList.clear();

    if(decodedPolyLinePointsResultList.isNotEmpty)
    {
      for (var pointLatLng in decodedPolyLinePointsResultList) {
        pLineCoOrdinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.red,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(pickup.latitude > destination.latitude && pickup.longitude > destination.longitude)
    {
      boundsLatLng = LatLngBounds(southwest: destination, northeast: pickup);
    }
    else if(pickup.longitude > destination.longitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(pickup.latitude, destination.longitude),
        northeast: LatLng(destination.latitude, pickup.longitude),
      );
    }
    else if(pickup.latitude > destination.latitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destination.latitude, pickup.longitude),
        northeast: LatLng(pickup.latitude, destination.longitude),
      );
    }
    else
    {
      boundsLatLng = LatLngBounds(southwest: pickup, northeast: destination);
    }

    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));


    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      //infoWindow: InfoWindow(title: origin.locationName, snippet: "Origin"),
      position: pickup,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      //infoWindow: InfoWindow(title: tripDetails!.destinationAddress!, snippet: "Destination"),
      position: destination,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: pickup,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destination,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });

  }

  void setupPositionLocator() async {



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

    // await getCurrentPosition();
  }
}
