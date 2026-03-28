import 'package:flutter/material.dart';

class TColor {
  // ─── Primary Brand ───
  static Color primary = const Color(0xFFE53935);
  static Color primaryDark = const Color(0xFFC62828);
  static Color primaryLight = const Color(0xFFFFEBEE);

  // ─── Accent ───
  static Color secondary = const Color(0xFFC62828);
  static Color accent = const Color(0xFFFF6B6B);

  // ─── Text ───
  static Color primaryText = const Color(0xFF111111);
  static Color secondaryText = const Color(0xFF6B7280);

  // ─── Surface & Background ───
  static Color background = const Color(0xFFFAFAFA);
  static Color white = const Color(0xFFFFFFFF);
  static Color textfield = const Color(0xFFF5F5F5);
  static Color placeholder = const Color(0xFF9CA3AF);
  static Color border = const Color(0xFFEEEEEE);

  // ─── Semantic ───
  static Color success = const Color(0xFF22C55E);
  static Color warning = const Color(0xFFF59E0B);
  static Color error = const Color(0xFFEF4444);

  // ─── Gradients ───
  static List<Color> primaryGradient = [
    const Color(0xFFE53935),
    const Color(0xFFC62828),
  ];

  static const LinearGradient foodTabGradient = LinearGradient(
    colors: [
      Color(0xFFE53935),
      Color(0xFFC62828),
    ],
  );

  static const LinearGradient groceryTabGradient = LinearGradient(
    colors: [
      Color(0xFFE53935),
      Color(0xFFD32F2F),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient whiteGradient = LinearGradient(
    colors: [Color(0xffffffff), Color(0xffffffff)],
  );

  static List<Color> customGradientBackground = [
    const Color(0xFFFFEBEE),
    const Color(0xFFFFF8E1),
  ];
}
