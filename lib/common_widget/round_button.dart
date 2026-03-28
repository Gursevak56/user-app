import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    this.height = 54,
    this.width = double.infinity,
    this.type = RoundButtonType.bgPrimary,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.gradient = TColor.foodTabGradient,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = type == RoundButtonType.bgPrimary;
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius as BorderRadius?,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: height,
          width: width,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isPrimary ? TColor.primary : TColor.white,
            borderRadius: borderRadius,
            border: isPrimary
                ? null
                : Border.all(color: TColor.primary, width: 1.5),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: TColor.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: isPrimary ? TColor.white : TColor.primary,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
