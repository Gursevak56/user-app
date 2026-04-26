import 'package:flutter/material.dart';

class TColor {
  // ─── Primary Brand (Stronger Red) ───
  static Color primary = const Color(0xFFE53935);
  static Color primaryDark = const Color(0xFFB71C1C);
  static Color primaryLight = const Color(0xFFFFEBEE);
  static Color primaryTint = const Color(0xFFFFF5F5);

  // ─── Accent ───
  static Color secondary = const Color(0xFFC62828);
  static Color accent = const Color(0xFFFF5252);

  // ─── Text ───
  static Color primaryText = const Color(0xFF1B1D2A);
  static Color secondaryText = const Color(0xFF6C7284);

  // ─── Surface & Background (Cleaner Off-White) ───
  static Color background = const Color(0xFFF5F6F8);
  static Color white = const Color(0xFFFFFFFF);
  static Color textfield = const Color(0xFFF1F2F6);
  static Color placeholder = const Color(0xFF9CA3AF);
  static Color border = const Color(0xFFE8EAF0);

  // ─── Semantic ───
  static Color success = const Color(0xFF16A34A);
  static Color warning = const Color(0xFFF59E0B);
  static Color error = const Color(0xFFEF4444);

  // ─── Premium Shadows (Deeper & More Refined) ───
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF1B1D2A).withOpacity(0.05),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: const Color(0xFF1B1D2A).withOpacity(0.02),
      blurRadius: 6,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> cardShadowLg = [
    BoxShadow(
      color: const Color(0xFF1B1D2A).withOpacity(0.08),
      blurRadius: 32,
      offset: const Offset(0, 12),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: const Color(0xFF1B1D2A).withOpacity(0.03),
      blurRadius: 8,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: const Color(0xFFE53935).withOpacity(0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> ctaShadow = [
    BoxShadow(
      color: const Color(0xFFE53935).withOpacity(0.25),
      blurRadius: 24,
      offset: const Offset(0, 10),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: const Color(0xFF1B1D2A).withOpacity(0.06),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> stickyBarShadow = [
    BoxShadow(
      color: const Color(0xFF1B1D2A).withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, -6),
      spreadRadius: -4,
    ),
  ];

  // ─── Shimmer Colors ───
  static Color shimmerBase = const Color(0xFFEAEBEE);
  static Color shimmerHighlight = const Color(0xFFF5F6F8);

  // ─── Gradients ───
  static List<Color> primaryGradient = [
    const Color(0xFFE53935),
    const Color(0xFFB71C1C),
  ];

  static const LinearGradient foodTabGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFEF5350), Color(0xFFE53935), Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient whiteGradient = LinearGradient(
    colors: [Color(0xffffffff), Color(0xffffffff)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFFF5F6F8), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static List<Color> customGradientBackground = [
    const Color(0xFFFFEBEE),
    const Color(0xFFFFF8E1),
  ];
}
