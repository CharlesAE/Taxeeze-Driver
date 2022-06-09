import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taxeeze_driver/helpers/location_methods.dart';
import 'package:taxeeze_driver/screens/trip_screen.dart';
import 'package:taxeeze_driver/widgets/TaxiOutlineButton.dart';
import 'package:taxeeze_driver/widgets/progress_dialog.dart';

import '../models/tripdetails.dart';
import '../util/brand_colors.dart';
import '../util/global.dart';

class NotificationDialog extends StatefulWidget {


  final TripDetails tripDetails;

  

  const NotificationDialog({Key? key, required this.tripDetails}) : super(key: key);

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          margin: EdgeInsets.all(4),
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 30.0,
              ),

              Image.asset(
                'assets/images/taxi.png',
                width: 100,
              ),
              SizedBox(
                height: 16.0,
              ),
              Text(
                'NEW RIDE REQUEST',
                style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 18, color: BrandColors.colorDimText),
              ),

          Padding(
            padding: const EdgeInsets.only(left:16.0, top: 10.0, bottom: 0, right: 16.0),
              child: Divider(height: 1.0, color: Color(0xFFe2e2e2), thickness: 1.0,)
          ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/pickicon.png',
                          height: 16,
                          width: 16,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(child: Container(child: Text(widget.tripDetails.pickupAddress!, style: TextStyle(fontSize: 18, color: BrandColors.colorDimText))))
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Image.asset(
                          "assets/images/desticon.png",
                          height: 16,
                          width: 16,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(child: Container(child: Text(widget.tripDetails.destinationAddress!, style: TextStyle(fontSize: 18, color: BrandColors.colorDimText))))
                      ],
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    Divider(height: 1.0, color: Color(0xFFe2e2e2), thickness: 1.0,),

                    SizedBox(
                      height: 8,
                    ),

                    Padding(padding: EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            child: TaxiOutlineButton(
                              title: "DECLINE",
                              color: BrandColors.colorLightGray,
                              onPressed: () async {
                                assetsAudioPlayer.stop();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            child: TaxiOutlineButton(
                              title: "ACCEPT",
                              color: BrandColors.colorGreen,
                              onPressed: () async {
                                assetsAudioPlayer.stop();

                                await checkAvailability(context);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkAvailability(context) async {

    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context)=> ProgressDialog(message: 'Accepting Trip Request'));

    DocumentReference tripRef = FirebaseFirestore.instance.collection('trip_requests').doc(widget.tripDetails.tripId);

    DocumentSnapshot tripSnapshot = await tripRef.get();
    var directionInformation = await LocationMethods.getDirectionDetails(widget.tripDetails.pickup!, widget.tripDetails.destination!);


    Navigator.pop(context);
    Navigator.pop(context);

    if(tripSnapshot.exists){
      Map<String,dynamic> tripData = tripSnapshot.data() as Map<String,dynamic>;

      if(tripData['status'] == 'requested'){

        //var directionInformation = await LocationMethods.getDirectionDetails(tripDetails.pickup!, tripDetails.destination!);

        //double totalFareAmount = LocationMethods.calculateFare(directionInformation!);
        setState(() {
          totalFareAmount = LocationMethods.calculateFare(directionInformation!);
        });

        print(totalFareAmount);
       tripRef.set({
         'status': 'accepted',
         'driver_name': currentUser!.name,
         'fare':totalFareAmount
       }, SetOptions(merge: true));

       LocationMethods.pauseLiveLocationUpdates();


       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => TripScreen(tripDetails: widget.tripDetails,))
       );





      } else if (tripData['status'] == 'cancelled'){

        Fluttertoast.showToast(
            msg: "Trip was cancelled",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      } else if (tripData['status'] == 'accepted'){

        Fluttertoast.showToast(
            msg: "Trip already accepted",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }

  }
}
