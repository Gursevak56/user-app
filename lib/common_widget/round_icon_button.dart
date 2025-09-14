import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class RoundIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final String icon;
  final double fontSize;
  final FontWeight fontWeight;
  const RoundIconButton({
    super.key,
    required this.title,
    required this.icon,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w500,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: TColor.primaryGradient),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(icon, width: 15, height: 15, fit: BoxFit.contain),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: TColor.white,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
