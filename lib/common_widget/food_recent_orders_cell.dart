import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/color_extension.dart';

class FoodRecentOrdersCell extends StatelessWidget {
  final Map fRObj;
  final VoidCallback onTap;
  const FoodRecentOrdersCell(
      {super.key, required this.fRObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = fRObj["image"]?.toString() ?? "";
    final isNetwork = imageUrl.startsWith("http");

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TColor.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 56,
                height: 56,
                child: isNetwork
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: TColor.primaryLight,
                          child: Icon(Icons.fastfood_rounded,
                              color: TColor.primary.withOpacity(0.4), size: 24),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: TColor.primaryLight,
                          child: Icon(Icons.fastfood_rounded,
                              color: TColor.primary.withOpacity(0.4), size: 24),
                        ),
                      )
                    : Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: TColor.primaryLight,
                          child: Icon(Icons.fastfood_rounded,
                              color: TColor.primary.withOpacity(0.4), size: 24),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fRObj["name"]?.toString() ?? "",
                  style: GoogleFonts.plusJakartaSans(
                    color: TColor.primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 12, color: TColor.success),
                    const SizedBox(width: 4),
                    Text(
                      "Delivered",
                      style: GoogleFonts.plusJakartaSans(
                        color: TColor.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
