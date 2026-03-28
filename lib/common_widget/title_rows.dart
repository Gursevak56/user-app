import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/color_extension.dart';

class ViewAllTitleRow extends StatelessWidget {
  final String title;
  final VoidCallback onView;
  const ViewAllTitleRow({super.key, required this.title, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: onView,
          style: TextButton.styleFrom(
            foregroundColor: TColor.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "See all",
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: TColor.primary),
            ],
          ),
        ),
      ],
    );
  }
}

class SeeAllIconTitleRow extends StatelessWidget {
  final String title;
  final VoidCallback onView;
  final IconData icon;
  const SeeAllIconTitleRow(
      {super.key,
      required this.title,
      required this.onView,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: TColor.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: TColor.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: onView,
          style: TextButton.styleFrom(
            foregroundColor: TColor.primary,
          ),
          child: Text(
            "See all",
            style: GoogleFonts.plusJakartaSans(
              color: TColor.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class IconTitleRow extends StatelessWidget {
  final String title;
  final VoidCallback onView;
  final IconData icon;
  const IconTitleRow(
      {super.key,
      required this.title,
      required this.onView,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        IconButton(
          onPressed: onView,
          icon: Icon(icon),
          iconSize: 24,
          color: TColor.primaryText,
        )
      ],
    );
  }
}
