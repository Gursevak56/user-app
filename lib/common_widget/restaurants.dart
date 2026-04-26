import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_delivery/view/menu/menu_items_view.dart';

import '../common/color_extension.dart';

class Restaurants extends StatelessWidget {
  final Map rObj;
  const Restaurants({super.key, required this.rObj});

  @override
  Widget build(BuildContext context) {
    final imageUrl = rObj["image"]?.toString() ?? "";
    final isNetwork = imageUrl.startsWith("http");
    final name = rObj["name"]?.toString() ?? "";
    final foodType = rObj["foodType"]?.toString() ?? "";
    final rate = rObj["rate"]?.toString() ?? "0";
    final time = rObj["time"]?.toString() ?? "";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MenuItemsView(mObj: rObj)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: TColor.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Image Section ───
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 170,
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
                // Rating badge
                if (rate != "0" && rate.isNotEmpty)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFFFC107), size: 16),
                          const SizedBox(width: 3),
                          Text(
                            rate,
                            style: GoogleFonts.plusJakartaSans(
                              color: TColor.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // ─── Info Section ───
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      color: TColor.primaryText,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (foodType.isNotEmpty)
                    Text(
                      foodType,
                      style: GoogleFonts.plusJakartaSans(
                        color: TColor.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 15, color: TColor.secondaryText),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: GoogleFonts.plusJakartaSans(
                            color: TColor.secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
