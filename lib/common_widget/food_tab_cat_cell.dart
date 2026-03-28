import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../common/color_extension.dart';

class FoodTabCatCell extends StatelessWidget {
  final Map mObj;
  final VoidCallback onTap;
  const FoodTabCatCell({super.key, required this.mObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = mObj["image"]?.toString() ?? "";
    final isNetwork = imageUrl.startsWith("http");

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: isNetwork
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: TColor.primaryLight,
                          child: Center(
                            child: Icon(Icons.fastfood_rounded,
                                color: TColor.primary.withOpacity(0.3),
                                size: 32),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: TColor.primaryLight,
                          child: Center(
                            child: Icon(Icons.fastfood_rounded,
                                color: TColor.primary.withOpacity(0.3),
                                size: 32),
                          ),
                        ),
                      )
                    : Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: TColor.primaryLight,
                          child: Center(
                            child: Icon(Icons.fastfood_rounded,
                                color: TColor.primary.withOpacity(0.3),
                                size: 32),
                          ),
                        ),
                      ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.55),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              // Title
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  mObj["title"]?.toString() ?? "",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
