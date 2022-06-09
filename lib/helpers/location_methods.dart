
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../global/app_info.dart';
import '../models/direction_details.dart';
import '../models/directions.dart';
import '../util/global.dart';
import 'request_methods.dart';

class LocationMethods {
  static Future<String>  searchAddressForPosition(Position position,  context) async {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String readable = "";
    var requestResponse =  await RequestMethods.receiveRequest(apiUrl);
    if(requestResponse != "Error")
    {
      readable = requestResponse["results"][0]["formatted_address"];
      Directions pickupAddress = Directions();
      pickupAddress.locationLat = position.latitude;
      pickupAddress.locationLng = position.longitude;
      pickupAddress.locationName = readable;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocation(pickupAddress);
    }
    return  readable;
  }


  static Future<DirectionDetails?> getDirectionDetails(LatLng origin, LatLng destination) async{
    String urlObtainOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$mapKey";

    var directionResponse = await RequestMethods.receiveRequest(urlObtainOriginToDestinationDirectionDetails);
    if(directionResponse ==  "Error Occurred, Failed. No Response.") {
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.e_points = directionResponse["routes"][0]["overview_polyline"]["points"];
    directionDetails.distance_text = directionResponse["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distance_value = directionResponse["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.duration_text = directionResponse["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.duration_value = directionResponse["routes"][0]["legs"][0]["duration"]["value"];
    return directionDetails;
  }

  static pauseLiveLocationUpdates(){
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(currentFirebaseUser!.uid);
  }

  static resumeLiveLocationUpdates(){
    streamSubscriptionPosition!.resume();
    Geofire.setLocation(currentFirebaseUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
  }

  static double calculateFare(DirectionDetails  directionDetails){
    double timeTraveledFareAmountPerMinute = (directionDetails.duration_value! / 60) * 5;
    double distanceTraveledFareAmountPerKilometer = (directionDetails.duration_value! / 1000) * 5;

    //USD
    double totalFareAmount = timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;
    return totalFareAmount.truncate().toDouble();
  }

}