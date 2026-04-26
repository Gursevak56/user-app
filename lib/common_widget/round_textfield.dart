import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/color_extension.dart';

class RoundTextfield extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Color? bgColor;
  final Widget? left;
  final ValueChanged<String>? onChanged;

  const RoundTextfield({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.bgColor,
    this.left,
    this.obscureText = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor ?? TColor.textfield,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColor.border, width: 1),
      ),
      child: Row(
        children: [
          if (left != null)
            Padding(padding: const EdgeInsets.only(left: 14), child: left!),
          Expanded(
            child: TextField(
              autocorrect: false,
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              onChanged: onChanged,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                color: TColor.primaryText,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: hintText,
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: TColor.placeholder,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoundTitleTextfield extends StatelessWidget {
  final TextEditingController? controller;
  final String title;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final Color? bgColor;
  final Widget? left;

  const RoundTitleTextfield({
    super.key,
    required this.title,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.bgColor,
    this.left,
    this.obscureText = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: bgColor ?? TColor.textfield,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColor.border, width: 1),
      ),
      child: Row(
        children: [
          if (left != null)
            Padding(padding: const EdgeInsets.only(left: 14), child: left!),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 58,
                  margin: const EdgeInsets.only(top: 8),
                  alignment: Alignment.topLeft,
                  child: TextField(
                    autocorrect: false,
                    controller: controller,
                    obscureText: obscureText,
                    keyboardType: keyboardType,
                    readOnly: readOnly,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: TColor.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: hintText,
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: TColor.placeholder,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 58,
                  margin: const EdgeInsets.only(top: 10, left: 16),
                  alignment: Alignment.topLeft,
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      color: TColor.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
