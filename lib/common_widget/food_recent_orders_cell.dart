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

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TColor.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
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
                  width: 52,
                  height: 52,
                  child: isNetwork
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: TColor.primaryLight,
                            child: Icon(Icons.fastfood_rounded,
                                color: TColor.primary.withOpacity(0.3),
                                size: 22),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: TColor.primaryLight,
                            child: Icon(Icons.fastfood_rounded,
                                color: TColor.primary.withOpacity(0.3),
                                size: 22),
                          ),
                        )
                      : Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: TColor.primaryLight,
                            child: Icon(Icons.fastfood_rounded,
                                color: TColor.primary.withOpacity(0.3),
                                size: 22),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
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
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 13, color: TColor.success),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
