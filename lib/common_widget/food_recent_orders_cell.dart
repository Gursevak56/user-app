import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/color_extension.dart';

class FoodRecentOrdersCell extends StatelessWidget {
  final Map fRObj;
  final VoidCallback onTap;
  const FoodRecentOrdersCell(
      {super.key, required this.fRObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                offset: Offset(0, 2),
                blurRadius: 4,
                spreadRadius: -2),
            BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                offset: Offset(0, 4),
                blurRadius: 6,
                spreadRadius: -1)
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  fRObj["image"].toString(),
                  width: 64,
                  height: 64,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fRObj["name"],
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Delivered • ${fRObj["delivered_date"]}",
                      style: GoogleFonts.poppins(
                        color: TColor.primaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
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
