import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/food&rest_list.dart';
import 'package:food_delivery/common_widget/groceries_cat_cell.dart';
import 'package:food_delivery/common_widget/groceries_heading.dart';
import 'package:food_delivery/common_widget/grocery_recent_orders_cell.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/common_widget/title_rows.dart';
import 'package:food_delivery/view/more/my_order_view.dart';
import 'package:food_delivery/view/more/popular_restaurants.dart';

class HomeGroceryTabView extends StatelessWidget {
  HomeGroceryTabView({
    super.key,
  });

  final List groceryRecentOrderArr = [
    {
      "image": "assets/img/samosa_pack.png",
      "name": "Samosa Pack",
      "delivered_date": "2 days ago",
    },
    {
      "image": "assets/img/milk.png",
      "name": "Milk",
      "delivered_date": "5 days ago",
    },
    {
      "image": "assets/img/fruits_basket.png.",
      "name": "Fruit Basket",
      "delivered_date": "5 days ago",
    },
  ];

  final List groceryCatArr = [
    {
      "image": "assets/img/vegetables.png",
      "name": "Vegetables",
      "time": "30-45 mins"
    },
    {"image": "assets/img/fruits.png", "name": "Fruits", "time": "30-45 mins"},
    {"image": "assets/img/diary.png", "name": "Diary", "time": "30-45 mins"},
    {
      "image": "assets/img/staples.png",
      "name": "Staples",
      "time": "30-45 mins"
    },
  ];

  final List foodRestaurantsArr = [
    {
      "image": "assets/img/sethi_dhaba.png",
      "name": "Sethi Dhaba",
      "link": "Indian",
      "address": "Punjabi, North Indian",
      "rate": "4.2",
      "time": "30-40 mins",
    },
    {
      "image": "assets/img/anju_ kitchen.png",
      "name": "Anju's Kitchen",
      "link": "South Indian",
      "address": "South Indian, Home-style ",
      "rate": "4.5",
      "time": "25-35 mins",
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        spreadRadius: 2,
                        blurRadius: 2)
                  ],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/img/grocery_promotion_banner_background.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 36,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Limited time",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: TColor.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Flat ₹50 off on first grocery order",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TColor.white,
                        letterSpacing: -0.5,
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
                        gradient: TColor.groceryTabGradient,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SeeAllIconTitleRow(
            icon: Icons.history,
            title: "Recent Orders",
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
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groceryRecentOrderArr.length,
            itemBuilder: ((context, index) {
              var gRObj = groceryRecentOrderArr[index] as Map? ?? {};
              return GroceryRecentOrdersCell(
                gRObj: gRObj,
                onTap: () {},
              );
            }),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: GroceriesHeading(
              headingTitle: "Groceries",
              subtitle: "Essentials from nearby kirana"),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groceryCatArr.length,
            itemBuilder: ((context, index) {
              var gObj = groceryCatArr[index] as Map? ?? {};
              return GroceriesCatCell(
                gObj: gObj,
                onTap: () {},
              );
            }),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: IconTitleRow(
            icon: Icons.filter_list,
            title: "Food & Restaurants",
            onView: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PopularReestaurants()));
            },
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: foodRestaurantsArr.length,
          itemBuilder: ((context, index) {
            var fRObj = foodRestaurantsArr[index] as Map? ?? {};
            return FoodRestList(
              fRobj: fRObj,
              onTap: () {},
            );
          }),
        ),
      ],
    );
  }
}
