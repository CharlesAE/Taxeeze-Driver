import 'package:flutter/material.dart';

import '../util/brand_colors.dart';

class TaxiOutlineButton extends StatelessWidget {

  final String title;
  final VoidCallback onPressed;
  final Color color;

  TaxiOutlineButton({required this.title, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        // borderSide: BorderSide(color: color),
        // shape: new RoundedRectangleBorder(
        //   borderRadius: new BorderRadius.circular(25.0),
        // ),
        //
        // color: color,
        // textColor: color,

      style: ElevatedButton.styleFrom(
            primary: color,
            onPrimary: Colors.white,
            onSurface: Colors.grey,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)
            )
        ),

        onPressed: this.onPressed,

        child: Container(
          height: 50.0,
          child: Center(
            child: Text(title,
                style: TextStyle(fontSize: 15.0, fontFamily: 'Brand-Bold', color: BrandColors.colorText)),
          ),
        )
    );
  }
}


