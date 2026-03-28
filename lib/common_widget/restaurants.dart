import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:google_fonts/google_fonts.dart';

class Restaurants extends StatelessWidget {
  final Map rObj;
  const Restaurants({super.key, required this.rObj});

  @override
  Widget build(BuildContext context) {
    final imageUrl = rObj["image"]?.toString() ?? "";
    final isNetwork = imageUrl.startsWith("http");

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: TColor.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 12,
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: isNetwork
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: TColor.textfield,
                        child: Center(
                          child: Icon(Icons.restaurant_rounded,
                              color: TColor.placeholder, size: 40),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: TColor.textfield,
                        child: Center(
                          child: Icon(Icons.restaurant_rounded,
                              color: TColor.placeholder, size: 40),
                        ),
                      ),
                    )
                  : Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: TColor.textfield,
                        child: Center(
                          child: Icon(Icons.restaurant_rounded,
                              color: TColor.placeholder, size: 40),
                        ),
                      ),
                    ),
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rObj["name"]?.toString() ?? "",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: TColor.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Cuisine
                    if ((rObj["foodType"]?.toString() ?? "").isNotEmpty)
                      Flexible(
                        child: Text(
                          rObj["foodType"].toString(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: TColor.secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if ((rObj["foodCat"]?.toString() ?? "").isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text("•",
                            style: TextStyle(
                                color: TColor.placeholder, fontSize: 12)),
                      ),
                      Flexible(
                        child: Text(
                          rObj["foodCat"].toString(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: TColor.secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                // Rating + ETA row
                Row(
                  children: [
                    // Rating badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TColor.success,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            rObj["rate"]?.toString() ?? "0",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // ETA
                    if ((rObj["time"]?.toString() ?? "").isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 15, color: TColor.secondaryText),
                          const SizedBox(width: 4),
                          Text(
                            rObj["time"].toString(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: TColor.secondaryText,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
