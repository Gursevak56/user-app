import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/view/main_tabview/main_tabview.dart';
import 'package:google_fonts/google_fonts.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int selectPage = 0;
  PageController controller = PageController();

  final List<Map<String, dynamic>> pageArr = [
    {
      "title": "Discover Nearby\nRestaurants 🍕",
      "subtitle":
          "Browse local favorites and find the best dishes around you, curated just for your taste.",
      "image": "assets/img/on_boarding_1.png",
      "icon": Icons.explore_rounded,
    },
    {
      "title": "Fast Delivery\nin Minutes 🚴",
      "subtitle":
          "Get your food delivered lightning-fast. Hot, fresh, and right to your doorstep.",
      "image": "assets/img/on_boarding_2.png",
      "icon": Icons.delivery_dining_rounded,
    },
    {
      "title": "Easy Checkout\n& Live Tracking 📦",
      "subtitle":
          "Seamless payments, real-time tracking, and zero hassle. Order with confidence.",
      "image": "assets/img/on_boarding_3.png",
      "icon": Icons.fact_check_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        selectPage = controller.page?.round() ?? 0;
      });
    });
  }

  void _finishOnboarding() {
    Globs.udBoolSet(true, "has_onboarded");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainTabView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: TColor.white,
      body: Column(
        children: [
          // ─── Illustration + Content Area ───
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: pageArr.length,
              itemBuilder: (context, index) {
                final pObj = pageArr[index];
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // ─── Top Illustration Area ───
                      Container(
                        width: media.width,
                        height: media.height * 0.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              TColor.primary.withOpacity(0.05),
                              TColor.primaryLight,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(48),
                            bottomRight: Radius.circular(48),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Decorative circle
                            Positioned(
                              top: media.height * 0.08,
                              child: Container(
                                width: media.width * 0.65,
                                height: media.width * 0.65,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: TColor.primary.withOpacity(0.06),
                                ),
                              ),
                            ),
                            // Main illustration
                            Padding(
                              padding: EdgeInsets.only(top: media.height * 0.06),
                              child: Image.asset(
                                pObj["image"].toString(),
                                width: media.width * 0.6,
                                height: media.width * 0.7,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Container(
                                  width: media.width * 0.4,
                                  height: media.width * 0.4,
                                  decoration: BoxDecoration(
                                    color: TColor.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    pObj["icon"] as IconData,
                                    size: 80,
                                    color: TColor.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24), // Reduced spacer slightly to help text fit naturally

                      // ─── Text Content ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            Text(
                              pObj["title"].toString(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                color: TColor.primaryText,
                                fontSize: 26, // Reduced font size by 2 for safety
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              pObj["subtitle"].toString(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                color: TColor.secondaryText,
                                fontSize: 14, // Reduced font size by 1 space for safety
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ─── Bottom Controls ───
          Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + bottomPad),
            child: Column(
              children: [
                // Progress dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pageArr.length, (index) {
                    bool isActive = index == selectPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: isActive ? 32 : 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? TColor.primary
                            : TColor.placeholder.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 28),

                // Buttons
                if (selectPage < 2) ...[
                  // Next button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.animateToPage(
                          selectPage + 1,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Next",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Skip button
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      "Skip",
                      style: GoogleFonts.plusJakartaSans(
                        color: TColor.secondaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else ...[
                  // Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _finishOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: TColor.primary.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Get Started",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
