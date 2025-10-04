import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/food_recent_orders_cell.dart';
import 'package:food_delivery/common_widget/food_tab_cat_cell.dart';
import 'package:food_delivery/common_widget/restaurants.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/common_widget/title_rows.dart';
import 'package:food_delivery/view/more/my_order_view.dart';
import 'package:food_delivery/view/more/popular_restaurants.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeFoodTabView extends StatelessWidget {
  HomeFoodTabView({
    super.key,
  });

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

  final List foodCatArr = [
    {"image": "assets/img/cat_offer.png", "name": "Offers"},
    {"image": "assets/img/cat_sri.png", "name": "Sri Lankan"},
    {"image": "assets/img/cat_3.png", "name": "Italian"},
    {"image": "assets/img/cat_4.png", "name": "Indian"},
  ];

  final List popArr = [
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

  final List foodMostPopArr = [
    {
      "title": "Indian",
      "time": "30-40 mins",
      "image": "assets/img/indian_food.png",
    },
    {
      "title": "Chinese",
      "time": "30-40 mins",
      "image": "assets/img/chinese_food.png",
    },
    {
      "title": "South Indian",
      "time": "30-40 mins",
      "image": "assets/img/south_indian_food.png",
    },
    {
      "title": "Fast Food",
      "time": "30-40 mins",
      "image": "assets/img/fast_food.png",
    },
  ];

  final List foodRecentArr = [
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

  final List restaurants = [
    {
      "image": "assets/img/biryani_junction.png",
      "name": "Biryani Junction",
      "foodType": "Hyderabadi",
      "foodCat": "Indian",
      "rate": "4.3",
      "time": "30-40 mins"
    },
    {
      "image": "assets/img/pizza_hub.png",
      "name": "Pizza Hub",
      "foodType": "Italia",
      "foodCat": "Fast Food",
      "rate": "4.1",
      "time": "25-35 mins"
    },
  ];

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
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 110,
            ),
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: foodMostPopArr.length,
            itemBuilder: ((context, index) {
              var mObj = foodMostPopArr[index] as Map? ?? {};
              return FoodTabCatCell(
                mObj: mObj,
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
        ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: restaurants.length,
          itemBuilder: ((context, index) {
            var rObj = restaurants[index] as Map? ?? {};
            return Restaurants(
              rObj: rObj,
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
