import 'package:flutter/material.dart';
import '../../common/color_extension.dart';

class PopularReestaurants extends StatelessWidget {
  const PopularReestaurants({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy restaurants
    final restaurants = [
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
      {
        "name": "Domino's Pizza",
        "image": "assets/img/restaurant1.jpg",
        "rate": "4.9",
        "rating": "124",
        "type": "Italian",
        "food_type": "Pizzeria",
        "location": "2 km away"
      },
      {
        "name": "Burger King",
        "image": "assets/img/restaurant2.jpg",
        "rate": "4.5",
        "rating": "124",
        "type": "American",
        "food_type": "Burgers",
        "location": "3.5 km away"
      },
      {
        "name": "Subway",
        "image": "assets/img/restaurant3.jpg",
        "rate": "4.3",
        "rating": "124",
        "type": "Fast Food",
        "food_type": "Sandwiches",
        "location": "1.2 km away"
      },
      {
        "name": "Dunkin' Donuts",
        "image": "assets/img/restaurant4.jpg",
        "rate": "4.3",
        "rating": "124",
        "type": "Bakery",
        "food_type": "Donuts",
        "location": "1.2 km away"
      },
      {
        "name": "KFC (Kentucky Fried Chicken)",
        "image": "assets/img/restaurant5.jpg",
        "rate": "4.3",
        "rating": "124",
        "type": "Fry",
        "food_type": "Fried Chicken",
        "location": "1.2 km away"
      }
    ];

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          "Popular Restaurants",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Image.asset("assets/img/btn_back.png", width: 20, height: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final rest = restaurants[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              onTap: () {
                // TODO: Navigate to restaurant menu
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      rest["image"].toString(),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Restaurant details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rest["name"].toString(),
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Image.asset(
                              "assets/img/rate.png",
                              width: 12,
                              height: 12,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rest["rate"].toString(),
                              style: TextStyle(
                                color: TColor.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "(${rest["rating"]} Ratings)",
                              style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              rest["type"].toString(),
                              style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              " • ",
                              style: TextStyle(
                                color: TColor.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              rest["food_type"].toString(),
                              style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
