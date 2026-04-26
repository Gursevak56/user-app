import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/food_recent_orders_cell.dart';
import 'package:food_delivery/common_widget/food_tab_cat_cell.dart';
import 'package:food_delivery/common_widget/restaurants.dart';
import 'package:food_delivery/common_widget/shimmer_block.dart';
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
          setState(() {
            isLoadingRecent = false;
          });
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
          setState(() {
            isLoading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        // ─── Hero Banner ───
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildHeroBanner(),
        ),

        // ─── Recent Orders ───
        if (Globs.udValueBool(Globs.userLogin)) ...[
          const SizedBox(height: 24),
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
          const SizedBox(height: 10),
          SizedBox(
            height: 78,
            child: isLoadingRecent
                ? _buildRecentOrdersShimmer()
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
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        physics: const BouncingScrollPhysics(),
                        itemCount: foodRecentOrderArr.length,
                        itemBuilder: ((context, index) {
                          var fRObj =
                              foodRecentOrderArr[index] as Map? ?? {};
                          var uiObj = {
                            "image": fRObj["image_url"] ?? 
                                fRObj["image"] ?? "assets/img/paneer_butter.png",
                            "name": (fRObj["items"] as List?)?.isNotEmpty == true
                                ? ((fRObj["items"] as List).first as Map)["name"]?.toString() ?? "Your Order"
                                : "Order #${fRObj['order_id'] ?? ''}",
                            "delivered_date": fRObj["created_at"] ?? fRObj["delivered_date"] ?? "",
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
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ViewAllTitleRow(
            title: "Categories",
            onView: () {
              // No dedicated categories page yet
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 240,
          child: isLoading
              ? _buildCategoriesShimmer()
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                          "image":
                              mObj["image_url"] ?? "assets/img/cat_3.png",
                        };
                        return FoodTabCatCell(
                          mObj: uiObj,
                          onTap: () {},
                        );
                      }),
                    ),
        ),

        // ─── Restaurants ───
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ViewAllTitleRow(
            title: "Restaurants Near You",
            onView: () {},
          ),
        ),
        const SizedBox(height: 10),
        isLoading
            ? _buildRestaurantsShimmer()
            : restaurants.isEmpty
                ? _buildNoRestaurants()
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: restaurants.length,
                    itemBuilder: ((context, index) {
                      var rObj = restaurants[index] as Map? ?? {};
                      var uiObj = <String, dynamic>{
                        "id": rObj["id"],
                        "restaurant_id": rObj["restaurant_id"],
                        "image":
                            rObj["image_url"] ?? "assets/img/pizza_hub.png",
                        "name": rObj["name"] ?? "",
                        "foodType": rObj["cuisine"] ?? "",
                        "foodCat":
                            (rObj["tags"] as List?)?.join(", ") ?? "",
                        "rate": rObj["rating"]?.toString() ?? "0",
                        "time": rObj["delivery_time"] ?? "",
                      };
                      return Restaurants(
                        rObj: uiObj,
                      );
                    }),
                  ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ─── Hero Banner ───
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [TColor.primary, TColor.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: TColor.primaryShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          bannersArr.isNotEmpty
                              ? bannersArr[0]['title'] ?? "Special Offer"
                              : "Flat ₹100 off",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
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
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Order Now",
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
                if (bannersArr.isNotEmpty &&
                    bannersArr[0]['image_url'] != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
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
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.local_offer_rounded,
                      size: 56,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Shimmer Loaders ───
  Widget _buildRecentOrdersShimmer() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: const ShimmerBlock(height: 72, width: 180, borderRadius: 14),
      ),
    );
  }

  Widget _buildCategoriesShimmer() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 110,
      ),
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 4,
      itemBuilder: (_, __) => const ShimmerBlock(height: 110, borderRadius: 18),
    );
  }

  Widget _buildRestaurantsShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
            3, (_) => const ShimmerRestaurantCard()),
      ),
    );
  }

  // ─── No Restaurants Empty State ───
  Widget _buildNoRestaurants() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: TColor.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.delivery_dining_rounded,
            size: 52,
            color: TColor.primary,
          ),
        ),
        const SizedBox(height: 24),
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
            "We're not currently serving in your area,\nbut we're working hard to get there!\nStay tuned for delicious updates.",
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
    );
  }
}
