import 'package:flutter/material.dart';
import 'package:food_delivery/common/location_service.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_textfield.dart';
import 'package:food_delivery/common_widget/start_order_button.dart';
import 'package:food_delivery/view/home/home_food_tab_view.dart';
import 'package:food_delivery/view/notifications/notifications_view.dart';
import '../more/my_order_view.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  TextEditingController txtSearch = TextEditingController();
  late AnimationController _fabCtrl;
  late Animation<Offset> _fabSlide;

  @override
  void initState() {
    super.initState();
    _fetchLocationAndData();
    _fabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fabSlide = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fabCtrl, curve: Curves.easeOutCubic));
    // Delay the FAB entrance for a premium reveal
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _fabCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fabCtrl.dispose();
    super.dispose();
  }

  void _fetchLocationAndData() async {
    await LocationService.fetchAndSaveCurrentLocation();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = Globs.udValueString("user_name");
    final greeting = _getGreeting();

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 64,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: TColor.premiumGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.location_on_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName.isNotEmpty ? "$greeting, $userName 👋" : greeting,
                    style: GoogleFonts.plusJakartaSans(
                      color: TColor.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          Globs.udValueString(Globs.userAddress).isNotEmpty
                              ? Globs.udValueString(Globs.userAddress)
                              : "Fetching location...",
                          style: GoogleFonts.plusJakartaSans(
                            color: TColor.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: TColor.primaryText),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  if (Globs.udValueBool(Globs.userLogin)) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsView(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Please login to see notifications"),
                        backgroundColor: TColor.primaryText,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TColor.textfield,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: TColor.primaryText,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search bar area
              Container(
                color: TColor.white,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: RoundTextfield(
                  hintText: "Search dishes or restaurants...",
                  controller: txtSearch,
                  left: Icon(Icons.search_rounded,
                      color: TColor.placeholder, size: 22),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: const HomeFoodTabView(),
                ),
              ),
            ],
          ),
          // Floating My Orders button
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: SlideTransition(
                position: _fabSlide,
                child: SizedBox(
                  width: 170,
                  height: 50,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyOrderView(),
                        ),
                      );
                    },
                    child: StartOrderButton(
                      onPressed: () {},
                      gradient: TColor.foodTabGradient,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }
}
