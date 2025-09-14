import 'package:flutter/material.dart';

import '../common/color_extension.dart';

enum RoundButtonType { bgPrimary, textPrimary }

class RoundButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final RoundButtonType type;
  final double fontSize;

  final dynamic onTap;
  const RoundButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.fontSize = 16,
    this.type = RoundButtonType.bgPrimary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: type == RoundButtonType.bgPrimary
              ? null
              : Border.all(color: TColor.primary, width: 1),
          gradient: LinearGradient(
            colors: type == RoundButtonType.bgPrimary
                ? TColor.primaryGradient
                : TColor.whiteGradient,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
                BoxShadow(
                  color: TColor.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
          ]
        ),
        child: Text(
          title,
          style: TextStyle(
            color: type == RoundButtonType.bgPrimary
                ? TColor.white
                : TColor.primary,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
