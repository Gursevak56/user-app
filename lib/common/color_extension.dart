import 'package:flutter/material.dart';

class TColor {
  static Color primary = const Color(0xFF00C2CB);
  static Color secondary = const Color(0xFFEAB308);
  static Color primaryText = const Color(0xFF1F2937);
  static Color secondaryText = const Color(0xff868687);
  static Color textfield = const Color(0xffF2F2F2);
  static Color placeholder = const Color(0xffB6B7B7);
  static Color white = const Color(0xffffffff);

  static List<Color>  primaryGradient = [
        const Color(0xFF07BAD8),
        const Color(0xFF07BAD8),
        const Color(0xFF0EB0D7),
        const Color(0xFF06E3D8),
      ];

  static const LinearGradient foodTabGradient = LinearGradient(
        colors: [
          Color(0xFF10B981),
          Color(0xFF2563EB),
        ],
      );

  static const LinearGradient groceryTabGradient = LinearGradient(
        colors: [
          Color(0xFF07BAD8),
          Color(0xFF07BAD8),
          Color(0xFF0EB0D7),
          Color(0xFF06E3D8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static const LinearGradient whiteGradient = LinearGradient(
        colors: [Color(0xffffffff), Color(0xffffffff)],
      );

  static List<Color> customGradientBackground =
      [const Color(0xFFDFF7E4), const Color(0xFFFFF8E1)];
}
