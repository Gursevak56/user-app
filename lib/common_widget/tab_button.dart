import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/color_extension.dart';

class TabButton extends StatelessWidget {
  final String title;
  final String icon; // kept for API compatibility
  final bool isSelected;
  final VoidCallback onTap;

  const TabButton({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _iconData {
    switch (title.toLowerCase()) {
      case 'home':
        return isSelected ? Icons.home_rounded : Icons.home_outlined;
      case 'menu':
        return isSelected
            ? Icons.restaurant_menu_rounded
            : Icons.restaurant_menu_outlined;
      case 'more':
        return isSelected ? Icons.grid_view_rounded : Icons.grid_view_outlined;
      case 'offers':
        return isSelected
            ? Icons.local_offer_rounded
            : Icons.local_offer_outlined;
      case 'profile':
        return isSelected ? Icons.person_rounded : Icons.person_outline_rounded;
      default:
        return isSelected ? Icons.home_rounded : Icons.home_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: isSelected ? 48 : 40,
                height: isSelected ? 48 : 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? TColor.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconData,
                  size: isSelected ? 26 : 24,
                  color: isSelected ? TColor.primary : TColor.secondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? TColor.primary : TColor.secondaryText,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
