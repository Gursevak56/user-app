import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/food_recent_orders_cell.dart';
import 'package:food_delivery/common_widget/food_tab_cat_cell.dart';
import 'package:food_delivery/common_widget/restaurants.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/common_widget/title_rows.dart';
import 'package:food_delivery/view/more/my_order_view.dart';
import 'package:food_delivery/view/more/popular_restaurants.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeFoodTabView extends StatefulWidget {
  const HomeFoodTabView({
    super.key,
  });

  @override
  State<HomeFoodTabView> createState() => _HomeFoodTabViewState();
}

class _HomeFoodTabViewState extends State<HomeFoodTabView> {

  final List foodRecentOrderArr = [
    {
      "image": "assets/img/paneer_butter.png",
      "name": "Paneer Butter",
      "delivered_date": "3 days ago",
    },
    {
      "image": "assets/img/veg_burger.png",
      "name": "Veg Burger",
      "delivered_date": "7 days ago",
    },
    {
      "image": "assets/img/milk.png",
      "name": "Milk",
      "delivered_date": "7 days ago",
    },
  ];

  List bannersArr = [];
  List foodCatArr = [];
  List restaurants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  void _fetchHomeData() async {
    final lat = Globs.udValueDouble(Globs.userLat).toString();
    final lng = Globs.udValueDouble(Globs.userLng).toString();
    
    // Fallbacks if lat/lng are missing (user denied location)
    final params = <String, String>{};
    if (lat != "0.0" && lng != "0.0") {
      params['lat'] = lat;
      params['lng'] = lng;
      params['radius'] = "10";
    }

    await ServiceCall.get(
      "${SVKey.restaurantBaseUrl}/api/home",
      queryParameters: params,
      isToken: true,
      withSuccess: (responseObj) async {
        if (responseObj[KKey.statusCode] == 200) {
          final data = responseObj["data"] as Map<String, dynamic>? ?? {};
          if (mounted) {
            setState(() {
              bannersArr = data["banners"] as List? ?? [];
              foodCatArr = data["categories"] as List? ?? [];
              restaurants = data["recommended_restaurants"] as List? ?? [];
              isLoading = false;
            });
          }
        }
      },
      failure: (err) async {
        if (mounted) {
          setState(() { isLoading = false; });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(20),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Flat ₹100 off",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: TColor.primaryText,
                        ),
                      ),
                      Text(
                        "on first food order",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: TColor.primaryText,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Container(
                        height: 40,
                        width: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: RoundButton(
                          title: "Grab Offer",
                          onPressed: () {},
                          fontSize: 14,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: Image.asset(
                    "assets/img/food_promotion_banner.png",
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ViewAllTitleRow(
            title: "Recent Orders",
            onView: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PopularReestaurants()));
            },
          ),
        ),
        SizedBox(
          height: 88,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: foodRecentOrderArr.length,
            itemBuilder: ((context, index) {
              var fRObj = foodRecentOrderArr[index] as Map? ?? {};
              return FoodRecentOrdersCell(
                fRObj: fRObj,
                onTap: () {},
              );
            }),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: ViewAllTitleRow(
            title: "Categories",
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
          height: 240,
          child: isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : foodCatArr.isEmpty 
                  ? const Center(child: Text("No categories available"))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 110,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: foodCatArr.length,
                      itemBuilder: ((context, index) {
                        var mObj = foodCatArr[index] as Map? ?? {};
                        // Map the API structure to the UI structure expected by FoodTabCatCell
                        var uiObj = {
                          "title": mObj["name"] ?? "",
                          "image": mObj["image_url"] ?? "assets/img/cat_3.png", // fallback local img
                        };
                        return FoodTabCatCell(
                          mObj: uiObj,
                          onTap: () {},
                        );
                      }),
                    ),
        ),
        const SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ViewAllTitleRow(
            title: "Restaurants",
            onView: () {},
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : restaurants.isEmpty
                ? const Center(child: Text("No restaurants found"))
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: restaurants.length,
                    itemBuilder: ((context, index) {
                      var rObj = restaurants[index] as Map? ?? {};
                      // Map the api properties "rating", "delivery_time", "cuisine", "image_url" to UI keys.
                      var uiObj = {
                        "image": rObj["image_url"] ?? "assets/img/pizza_hub.png",
                        "name": rObj["name"] ?? "",
                        "foodType": rObj["cuisine"] ?? "",
                        "foodCat": (rObj["tags"] as List?)?.join(", ") ?? "",
                        "rate": rObj["rating"]?.toString() ?? "0",
                        "time": rObj["delivery_time"] ?? "",
                      };
                      return Restaurants(
                        rObj: uiObj,
                      );
                    }),
                  ),
        const SizedBox(
          height: 50,
        )
      ],
    );
  }
}
