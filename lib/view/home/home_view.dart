import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_textfield.dart';
import 'package:food_delivery/view/more/popular_restaurants.dart';

import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../common_widget/category_cell.dart';
import '../../common_widget/most_popular_cell.dart';
import '../../common_widget/popular_resutaurant_row.dart';
import '../../common_widget/recent_item_row.dart';
import '../../common_widget/view_all_title_row.dart';
import '../more/my_order_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController txtSearch = TextEditingController();

  List catArr = [
    {"image": "assets/img/cat_offer.png", "name": "Offers"},
    {"image": "assets/img/cat_sri.png", "name": "Sri Lankan"},
    {"image": "assets/img/cat_3.png", "name": "Italian"},
    {"image": "assets/img/cat_4.png", "name": "Indian"},
  ];

  List popArr = [
    {
      "name": "Minute by tuk tuk",
      "image": "assets/img/res_1.png",
      "rate": "4.9",
      "rating": "124",
      "type": "Asian Fusion",
      "food_type": "Café"
    },
    {
      "name": "Café de Noir",
      "image": "assets/img/res_2.png",
      "rate": "4.9",
      "rating": "124",
      "type": "French",
      "food_type": "Café"
    },
    {
      "name": "Bakes by Tella",
      "image": "assets/img/res_3.png",
      "rate": "4.9",
      "rating": "124",
      "type": "Bakery",
      "food_type": "Pastries"
    },
  ];

  List mostPopArr = [
    {
      "image": "assets/img/m_res_1.png",
      "name": "Minute by tuk tuk",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafe",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/m_res_2.png",
      "name": "Café de Noir",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafe",
      "food_type": "Western Food"
    },
  ];

  List recentArr = [
    {
      "image": "assets/img/item_1.png",
      "name": "Mulberry Pizza by Josh",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafe",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/item_2.png",
      "name": "Barita",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafe",
      "food_type": "Western Food"
    },
    {
      "image": "assets/img/item_3.png",
      "name": "Pizza Rush Hour",
      "rate": "4.9",
      "rating": "124",
      "type": "Cafe",
      "food_type": "Western Food"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Good morning ${ServiceCall.userPayload[KKey.name] ?? ""}!",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyOrderView()),
                );
              },
              icon: Image.asset(
                "assets/img/shopping_cart.png",
                width: 25,
                height: 25,
                color: TColor.primary,
              ),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Delivering to",
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "Current Location",
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 25),
                    Image.asset(
                      "assets/img/dropdown.png",
                      width: 12,
                      height: 12,
                      color: TColor.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                RoundTextfield(
                  hintText: "Search Food",
                  controller: txtSearch,
                  left: Container(
                    alignment: Alignment.center,
                    width: 30,
                    child: Image.asset(
                      "assets/img/search.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Scrollable Section
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: catArr.length,
                      itemBuilder: ((context, index) {
                        var cObj = catArr[index] as Map? ?? {};
                        return CategoryCell(
                          cObj: cObj,
                          onTap: () {},
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ViewAllTitleRow(
                      title: "Popular Restaurants",
                      onView: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PopularReestaurants()));
                      },
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: popArr.length,
                    itemBuilder: ((context, index) {
                      var pObj = popArr[index] as Map? ?? {};
                      return PopularRestaurantRow(
                        pObj: pObj,
                        onTap: () {},
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ViewAllTitleRow(
                      title: "Most Popular",
                      onView: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyOrderView(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: mostPopArr.length,
                      itemBuilder: ((context, index) {
                        var mObj = mostPopArr[index] as Map? ?? {};
                        return MostPopularCell(
                          mObj: mObj,
                          onTap: () {},
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ViewAllTitleRow(
                      title: "Recent Items",
                      onView: () {},
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: recentArr.length,
                    itemBuilder: ((context, index) {
                      var rObj = recentArr[index] as Map? ?? {};
                      return RecentItemRow(
                        rObj: rObj,
                        onTap: () {},
                      );
                    }),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
