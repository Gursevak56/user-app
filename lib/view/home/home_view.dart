import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_textfield.dart';
import 'package:food_delivery/common_widget/start_order_button.dart';
import 'package:food_delivery/view/home/home_food_tab_view.dart';
import 'package:food_delivery/view/home/home_grocery_tab_view.dart';
import '../more/my_order_view.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // decide gradient + hint based on tab
    final isFoodTab = _tabController.index == 0;

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.location_on_sharp),
            Text(
              "Roorkee, UP",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications,
                    color: TColor.primaryText,
                    size: 24,
                  ),
                ),
                const SizedBox(
                  height: 34,
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/img/profile.png"),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: TColor.textfield,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                            onPressed: () {},
                            icon: Image.asset(
                              "assets/img/tab_home.png",
                              color: const Color(0xFF1F2937),
                              height: 20,
                              width: 20,
                            ))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SegmentedTabControl(
                        controller: _tabController,
                        barDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: TColor.textfield,
                        ),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                        height: 50,
                        tabTextColor: TColor.secondaryText,
                        selectedTabTextColor: Colors.white,
                        squeezeIntensity: 2,
                        indicatorPadding: const EdgeInsets.all(4),
                        indicatorDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
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
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoundTextfield(
                      hintText: isFoodTab
                          ? "Search for dishes or restaurants"
                          : "Search for products",
                      controller: txtSearch,
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
              child: Container(
                width: 190,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
