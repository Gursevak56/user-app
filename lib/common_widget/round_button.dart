import 'package:flutter/material.dart';

import '../common/color_extension.dart';

enum RoundButtonType { bgPrimary, textPrimary }

class RoundButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final RoundButtonType type;
  final double fontSize;
  final double height;
  final double width;
  final BorderRadiusGeometry borderRadius;
  final Gradient gradient;

  const RoundButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.fontSize = 16,
    this.height = 55,
    this.width = double.infinity,
    this.type = RoundButtonType.bgPrimary,
    this.borderRadius = const BorderRadius.all(Radius.circular(30)),
    this.gradient = TColor.foodTabGradient,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: type == RoundButtonType.bgPrimary
                ? null
                : Border.all(color: TColor.primary, width: 1),
            gradient: type == RoundButtonType.bgPrimary
                ? gradient
                : TColor.whiteGradient,
            borderRadius: borderRadius,
            // boxShadow: [
            //   BoxShadow(
            //     color: TColor.primary.withOpacity(0.3),
            //     blurRadius: 8,
            //     offset: const Offset(0, 4),
            //   ),
            // ].
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
