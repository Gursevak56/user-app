import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: Text(
          "About Us",
          style: GoogleFonts.plusJakartaSans(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Brand card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: TColor.premiumGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: TColor.primaryShadow,
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      "assets/img/app-logo-update.png",
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.restaurant_rounded,
                        size: 36,
                        color: TColor.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Mangaale",
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Delicious food, delivered fast",
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Mission section
            _buildSectionCard(
              icon: Icons.flag_rounded,
              title: "Our Mission",
              body:
                  "We believe everyone deserves access to great food from the best local restaurants. Mangaale connects hungry customers with top restaurants in their area, delivering exceptional meals right to their doorstep with lightning-fast speed.",
            ),

            const SizedBox(height: 12),

            // What We Do
            _buildSectionCard(
              icon: Icons.restaurant_menu_rounded,
              title: "What We Do",
              body:
                  "From browsing curated menus to tracking your delivery in real-time, Mangaale provides a seamless food ordering experience. We partner with the finest local restaurants to bring you fresh, delicious meals every day.",
            ),

            const SizedBox(height: 12),

            // Why Choose Us
            _buildSectionCard(
              icon: Icons.stars_rounded,
              title: "Why Choose Us",
              body:
                  "Fast delivery, secure payments, real-time order tracking, and a wide variety of cuisines — all in one beautiful app. Our commitment to quality and convenience sets us apart from the rest.",
            ),

            const SizedBox(height: 12),

            // Contact
            _buildSectionCard(
              icon: Icons.support_agent_rounded,
              title: "Contact & Support",
              body:
                  "Have a question or need help with your order? Our support team is available 24/7 to assist you. Reach out to us through the app or visit our website for more information.",
            ),

            const SizedBox(height: 32),

            // Version info
            Text(
              "Version 1.0.0",
              style: GoogleFonts.plusJakartaSans(
                color: TColor.placeholder,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: TColor.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TColor.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: TColor.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: GoogleFonts.plusJakartaSans(
              color: TColor.secondaryText,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
