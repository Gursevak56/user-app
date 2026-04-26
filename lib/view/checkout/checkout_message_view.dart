import 'package:flutter/material.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/view/main_tabview/main_tabview.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../common/color_extension.dart';

class CheckoutMessageView extends StatefulWidget {
  const CheckoutMessageView({super.key});

  @override
  State<CheckoutMessageView> createState() => _CheckoutMessageViewState();
}

class _CheckoutMessageViewState extends State<CheckoutMessageView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      width: media.width,
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: TColor.placeholder.withOpacity(0.5),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: TColor.white,
              shape: BoxShape.circle,
              boxShadow: TColor.cardShadow,
            ),
            child: Image.asset(
              "assets/img/app-logo-update.png",
              width: 80,
              height: 80,
              errorBuilder: (_, __, ___) => Icon(
                Icons.check_circle_rounded,
                color: TColor.success,
                size: 60,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            "Thank You!",
            style: GoogleFonts.plusJakartaSans(
              color: TColor.primaryText,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "for your order",
            style: GoogleFonts.plusJakartaSans(
              color: TColor.primaryText,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Your order is now being processed. We will let you know once the order is picked from the outlet. Check the status of your order.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: TColor.secondaryText,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 35),
          RoundButton(
            title: "Track My Order",
            onPressed: () {
              Navigator.pop(context); // close modal before routing
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainTabView()),
                (route) => false,
              );
            },
            child: Text(
              "Back To Home",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: TColor.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
