import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton(
      {super.key,

      required this.onPressed,
      required this.title});
  final VoidCallback onPressed;

  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(
          color: TColor.primary.withOpacity(0.3),
          spreadRadius: 4,
          blurRadius: 8,
          offset: Offset(2, 4)
        )]
      ),
      child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: TColor.white,
            // side: const BorderSide(color: Colors.white, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            foregroundColor: TColor.primary,
          ),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          )),
    );
  }
}
