import 'package:flutter/material.dart';

class TaxeezeButton extends StatelessWidget {

  final String title;
  final Color color;
  final VoidCallback onPressed;

  TaxeezeButton({required this.title,required this.onPressed,required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: color,
            onPrimary: Colors.white,
            onSurface: Colors.grey,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)
            )
        ),

        onPressed: onPressed,
        child: Container(
          height: 50,
          child: Center(
            child: Text(title,
              style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),),
          ),
        ));
  }
}
