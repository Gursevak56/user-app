import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/common/location_service.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_textfield.dart';
import 'package:food_delivery/common_widget/start_order_button.dart';
import 'package:food_delivery/view/home/home_food_tab_view.dart';
import 'package:food_delivery/view/home/home_grocery_tab_view.dart';
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
  late TabController _tabController;

  List<Widget> get tabOptionView => [
        SingleChildScrollView(child: HomeFoodTabView()),
        SingleChildScrollView(child: HomeGroceryTabView())
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // rebuild when tab changes
    });
    
    // Fetch location seamlessly on first load.
    _fetchLocationAndData();
  }

  void _fetchLocationAndData() async {
    await LocationService.fetchAndSaveCurrentLocation();
    if (mounted) {
      setState(() {}); // Optionally rebuild if we show location name
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFoodTab = _tabController.index == 0;

    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: TColor.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.location_on_rounded,
                  color: TColor.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Delivering to",
                    style: GoogleFonts.plusJakartaSans(
                      color: TColor.secondaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
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
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (Globs.udValueBool(Globs.userLogin)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsView(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please login to see notifications")),
                );
              }
            },
            icon: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: TColor.textfield,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: TColor.primaryText,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Tab switcher area
              Container(
                color: TColor.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    // Tab control
                    SegmentedTabControl(
                      controller: _tabController,
                      barDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: TColor.textfield,
                      ),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      height: 48,
                      tabTextColor: TColor.secondaryText,
                      selectedTabTextColor: Colors.white,
                      squeezeIntensity: 2,
                      indicatorPadding: const EdgeInsets.all(4),
                      indicatorDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tabs: const [
                        SegmentTab(
                          label: 'Food',
                          gradient: TColor.foodTabGradient,
                        ),
                        SegmentTab(
                          label: 'Grocery',
                          gradient: TColor.groceryTabGradient,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Search bar
                    RoundTextfield(
                      hintText: isFoodTab
                          ? "Search for dishes or restaurants"
                          : "Search for products",
                      controller: txtSearch,
                      left: Icon(Icons.search_rounded,
                          color: TColor.placeholder, size: 22),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: tabOptionView,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: 170,
                height: 48,
                child: InkWell(
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
                    gradient: isFoodTab
                        ? TColor.foodTabGradient
                        : TColor.groceryTabGradient,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
