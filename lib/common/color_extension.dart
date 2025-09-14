import 'package:flutter/material.dart';

class TColor {
  static Color get primary => const Color(0xffFC6011);
  static Color get secondary => const Color(0xFF00AEEF);
  static Color get primaryText => const Color(0xff26282c);
  static Color get secondaryText => const Color(0xff868687);
  static Color get textfield => const Color(0xffF2F2F2);
  static Color get placeholder => const Color(0xffB6B7B7);
  static Color get white => const Color(0xffffffff);
  static List<Color> get primaryGradient => [
        const Color(0xffFC6011),
        const Color(0xFFF15C2E),
      ];
  static List<Color> get secondaryGradient => [
        const Color(0xFF00AEEF),
        const Color(0xff00C2CB),
      ];
  static List<Color> get whiteGradient => [
        const Color(0xffffffff),
        const Color(0xffffffff),
      ];
}
