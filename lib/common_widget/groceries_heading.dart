import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';

class GroceriesHeading extends StatelessWidget {
  final String headingTitle;
  final String subtitle;
  const GroceriesHeading(
      {super.key, required this.headingTitle, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headingTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: TColor.primaryText,
          ),
        ),
      ],
    );
  }
}
