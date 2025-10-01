import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/view/food_share/aactive_orders.dart';
import 'package:food_delivery/view/more/my_order_view.dart';

class FoodShareView extends StatelessWidget {
  const FoodShareView({super.key});

  @override
  Widget build(BuildContext context) {
    final foodShareOptionsList = [
      {
        "title": "Create Group Order",
        "subtitle": "Start a new group order & invite friends.",
        "icon": Icons.group_add,
        "onTap": () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Create Group Order tapped")),
          );
        },
      },
      {
        "title": "Join Order",
        "subtitle": "Browse available group orders to join.",
        "icon": Icons.list_alt,
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ActiveOrdersView(),
            ),
          );
        },
      },
      {
        "title": "Random Join",
        "subtitle": "Get matched with random users nearby.",
        "icon": Icons.shuffle,
        "onTap": () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Random Join tapped")),
          );
        },
      },
    ];

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Food Share",
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title & subtitle
            Text(
              "Share food, save more",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: TColor.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Choose how you want to enjoy FoodShare",
              style: TextStyle(
                fontSize: 14,
                color: TColor.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            Expanded(
              child: ListView.separated(
                itemCount: foodShareOptionsList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 25),
                itemBuilder: (context, index) {
                  final option = foodShareOptionsList[index];
                  return _buildOptionCard(
                    context,
                    title: option["title"] as String,
                    subtitle: option["subtitle"] as String,
                    icon: option["icon"] as IconData,
                    onTap: option["onTap"] as VoidCallback,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: TColor.primaryGradient),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: TColor.primary.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
