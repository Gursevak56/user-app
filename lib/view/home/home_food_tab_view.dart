import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  List foodRecentOrderArr = [];

  List bannersArr = [];
  List foodCatArr = [];
  List restaurants = [];
  bool isLoading = true;
  bool isLoadingRecent = true;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
    if (Globs.udValueBool(Globs.userLogin)) {
      _fetchRecentOrders();
    } else {
      isLoadingRecent = false;
    }
  }

  void _fetchRecentOrders() async {
    await ServiceCall.get(
      "${SVKey.restaurantBaseUrl}/api/orders/recent",
      isToken: true,
      withSuccess: (responseObj) async {
        if (responseObj[KKey.statusCode] == 200) {
          final data = responseObj["data"] as Map<String, dynamic>? ?? {};
          if (mounted) {
            setState(() {
              foodRecentOrderArr = data["recent_orders"] as List? ?? [];
              isLoadingRecent = false;
            });
          }
        }
      },
      failure: (err) async {
        if (mounted) {
          setState(() { isLoadingRecent = false; });
        }
      },
    );
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
      isToken: Globs.udValueBool(Globs.userLogin),
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
        // ─── Banner Card ───
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [TColor.primary, TColor.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: TColor.primary.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          bannersArr.isNotEmpty
                              ? bannersArr[0]['title'] ?? "Special Offer"
                              : "Flat ₹100 off",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bannersArr.isNotEmpty
                              ? bannersArr[0]['subtitle'] ?? "Grab it now"
                              : "on first food order",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Grab Offer",
                            style: GoogleFonts.plusJakartaSans(
                              color: TColor.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (bannersArr.isNotEmpty && bannersArr[0]['image_url'] != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: bannersArr[0]['image_url'],
                      fit: BoxFit.cover,
                      width: 130,
                      height: double.infinity,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.local_offer_rounded,
                      size: 60,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ─── Recent Orders ───
        if (Globs.udValueBool(Globs.userLogin)) ...[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: isLoadingRecent
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: TColor.primary,
                      ),
                    ),
                  )
                : foodRecentOrderArr.isEmpty
                    ? Center(
                        child: Text(
                          "No recent orders yet",
                          style: GoogleFonts.plusJakartaSans(
                            color: TColor.secondaryText,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: foodRecentOrderArr.length,
                        itemBuilder: ((context, index) {
                          var fRObj = foodRecentOrderArr[index] as Map? ?? {};
                          var uiObj = {
                            "image": fRObj["image_url"] ?? fRObj["image"] ?? "assets/img/paneer_butter.png",
                            "name": fRObj["name"] ?? "",
                            "delivered_date": fRObj["delivered_date"] ?? "",
                          };
                          return FoodRecentOrdersCell(
                            fRObj: uiObj,
                            onTap: () {},
                          );
                        }),
                      ),
          ),
        ],

        // ─── Categories ───
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
        const SizedBox(height: 8),
        SizedBox(
          height: 240,
          child: isLoading 
              ? Center(
                  child: CircularProgressIndicator(
                    color: TColor.primary,
                    strokeWidth: 2.5,
                  ),
                )
              : foodCatArr.isEmpty 
                  ? Center(
                      child: Text(
                        "No categories available",
                        style: GoogleFonts.plusJakartaSans(
                          color: TColor.secondaryText,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 110,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: foodCatArr.length,
                      itemBuilder: ((context, index) {
                        var mObj = foodCatArr[index] as Map? ?? {};
                        var uiObj = {
                          "title": mObj["name"] ?? "",
                          "image": mObj["image_url"] ?? "assets/img/cat_3.png",
                        };
                        return FoodTabCatCell(
                          mObj: uiObj,
                          onTap: () {},
                        );
                      }),
                    ),
        ),

        // ─── Restaurants ───
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ViewAllTitleRow(
            title: "Restaurants",
            onView: () {},
          ),
        ),
        const SizedBox(height: 8),
        isLoading
            ? Padding(
                padding: const EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  color: TColor.primary,
                  strokeWidth: 2.5,
                ),
              )
            : restaurants.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: TColor.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 48,
                          color: TColor.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Coming Soon! 🚀",
                        style: GoogleFonts.plusJakartaSans(
                          color: TColor.primaryText,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "We are not currently serving in your area, but we're working hard to get there!\nStay tuned for delicious updates.",
                          style: GoogleFonts.plusJakartaSans(
                            color: TColor.secondaryText,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: restaurants.length,
                    itemBuilder: ((context, index) {
                      var rObj = restaurants[index] as Map? ?? {};
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
          height: 70,
        )
      ],
    );
  }
}
