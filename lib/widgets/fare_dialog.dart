
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../util/brand_colors.dart';
import 'TaxiOutlineButton.dart';


class FareDialog extends StatefulWidget
{
  double? totalFareAmount;

  FareDialog({this.totalFareAmount});

  @override
  State<FareDialog> createState() => _FareDialogState();
}




class _FareDialogState extends State<FareDialog>
{
  @override
  Widget build(BuildContext context)
  {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor: Colors.grey,
      child: Container(
        margin: const EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 20,),

            Text(
              "Fare Amount ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10,),

            const Divider(
              thickness: 4,
              color: Colors.grey,
            ),

            const SizedBox(height: 16,),

            Text(
              "\$${widget.totalFareAmount.toString()}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 35,
              ),
            ),

            const SizedBox(height: 10,),

            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Amount shown above is the total fare to be charged to the passenger.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 10,),

            Padding(
              padding: const EdgeInsets.all(18.0),
              child: TaxiOutlineButton(
                title: "Collect",
                color: BrandColors.colorGreen,
                onPressed: () {
                  Future.delayed(const Duration(milliseconds: 2000), ()
                  {
                    SystemNavigator.pop();
                  });
                },
              )

            ),

            const SizedBox(height: 4,),

          ],
        ),
      ),
    );
  }
}
