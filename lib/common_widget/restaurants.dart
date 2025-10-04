import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:google_fonts/google_fonts.dart';

class Restaurants extends StatelessWidget {
  final Map rObj;
  const Restaurants({super.key, required this.rObj});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: TColor.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            spreadRadius: 2,
            blurRadius: 2,
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(20),
            ),
            child: Image.asset(
              rObj["image"].toString(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rObj["name"].toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: TColor.primaryText,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "${rObj["foodType"]}",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: TColor.primaryText,
                      ),
                    ),
                    Text(
                      "•",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: TColor.primaryText,
                      ),
                    ),
                    Text(
                      "${rObj["foodCat"]}",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: TColor.primaryText,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "${rObj["rate"]}",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: TColor.primaryText,
                      ),
                    ),
                    Text(
                      "•",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: TColor.primaryText,
                      ),
                    ),
                    Text(
                      "${rObj["time"]}",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: TColor.primaryText,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 40,
                  width: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: RoundButton(
                    height: 40,
                    title: "Order",
                    onPressed: () {},
                    fontSize: 14,
                    borderRadius: BorderRadius.circular(50),
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
