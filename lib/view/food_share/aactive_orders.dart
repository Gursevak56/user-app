import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/view/main_tabview/main_tabview.dart';
import 'package:food_delivery/view/more/my_order_view.dart';

class ActiveOrdersView extends StatefulWidget {
  const ActiveOrdersView({super.key});

  @override
  State<ActiveOrdersView> createState() => _ActiveOrdersViewState();
}

class _ActiveOrdersViewState extends State<ActiveOrdersView> {
  // My own order (always pinned at the top)
  final Map<String, dynamic> myOrder = {
    "restaurant": "Burger King",
    "startTime": DateTime.now(),
    "peopleJoined": 1,
  };

  // Mock public orders with start time
  List<Map<String, dynamic>> publicOrders = [
    {
      "restaurant": "KFC (Kentucky Fried Chicken)",
      "startTime": DateTime.now(),
      "peopleJoined": 1,
    },
    {
      "restaurant": "Subway",
      "startTime": DateTime.now(),
      "peopleJoined": 2,
    },
    {
      "restaurant": "Minute by tuk tuk",
      "startTime": DateTime.now(),
      "peopleJoined": 4,
    },
    {
      "restaurant": "Bakes by Tella",
      "startTime": DateTime.now(),
      "peopleJoined": 9,
    },
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update countdown every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String getDiscount(int people) {
    if (people == 1) return "No discount ";
    if (people == 2) return "40% off each";
    if (people == 3) return "55% off each";
    if (people >= 4) return "70% off each (max)";
    return "";
  }

  String getTimeLeft(DateTime startTime) {
    final endTime = startTime.add(const Duration(minutes: 5));
    final now = DateTime.now();
    final difference = endTime.difference(now);

    if (difference.isNegative) {
      return "Expired";
    } else {
      final minutes = difference.inMinutes;
      final seconds = difference.inSeconds % 60;
      return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    }
  }

  // 🔹 My Order Card (special styling)
  // 🔹 My Order Card (special styling, dark version)
  Widget _buildMyOrderCard(Map<String, dynamic> order) {
    final timeLeft = getTimeLeft(order["startTime"]);
    final discount = getDiscount(order["peopleJoined"]);

    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 6,
      color: const Color(0xFF1E1E1E), // deep near-black background
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Owner Badge
            Row(
              children: [
                Icon(Icons.star, color: TColor.secondary, size: 20),
                const SizedBox(width: 6),
                const Text(
                  "My Order",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Restaurant Name
            Text(
              order["restaurant"],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Countdown Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Time left:",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  timeLeft,
                  style: TextStyle(
                    fontSize: 16,
                    color: timeLeft == "Expired" ? Colors.red : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Members Joined
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Members Joined:",
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  order["peopleJoined"] >= 4
                      ? "4+"
                      : "${order["peopleJoined"]}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),

            // Discount Info
            Text(
              "Discount: $discount",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: TColor.secondary, // accent stays same
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // 🔹 Public Order Card (your original design)
  Widget _buildPublicOrderCard(Map<String, dynamic> order) {
    final timeLeft = getTimeLeft(order["startTime"]);
    final discount = getDiscount(order["peopleJoined"]);

    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Name
            Text(
              order["restaurant"],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TColor.primaryText,
              ),
            ),
            const SizedBox(height: 8),

            // Countdown Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Time left:",
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  timeLeft,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        timeLeft == "Expired" ? Colors.red : TColor.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Members Joined
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Members Joined:"),
                Text(
                  order["peopleJoined"] >= 4
                      ? "4+"
                      : "${order["peopleJoined"]}",
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),

            // Discount Info
            Text(
              "Discount: $discount",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: TColor.secondary,
              ),
            ),
            const SizedBox(height: 12),

            // Join Button
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: timeLeft == "Expired"
                      ? null
                      : LinearGradient(
                          colors: TColor.primaryGradient,
                        ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: timeLeft == "Expired"
                      ? null
                      : () {
                          setState(() {
                            order["peopleJoined"] += 1;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                  ),
                  child: const Text(
                    "Join",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MainTabView(initialTab: 3),
              ),
              (route) => false,
            );
          },
          icon: Image.asset("assets/img/btn_back.png", width: 20, height: 20),
        ),
        title: Text(
          "Active Orders",
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
      body: Column(
        children: [
           // My Order pinned at top
          _buildMyOrderCard(myOrder),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                // Divider before other orders
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "Other Active Orders",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: TColor.primaryText,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
            
                // Public orders
                ...publicOrders.map((order) => _buildPublicOrderCard(order)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
