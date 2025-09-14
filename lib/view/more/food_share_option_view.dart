import 'package:flutter/material.dart';
import 'package:food_delivery/view/food_share/aactive_orders.dart';
import 'package:share_plus/share_plus.dart';
import '../../common/color_extension.dart';

class FoodShareOptionsView extends StatefulWidget {
  const FoodShareOptionsView({super.key});

  @override
  State<FoodShareOptionsView> createState() => _FoodShareOptionsViewState();
}

class _FoodShareOptionsViewState extends State<FoodShareOptionsView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    return Container(
      padding: const EdgeInsets.all(25),
      width: media.width,
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TColor.primaryText.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: TColor.textfield,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: TColor.primaryText, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Title
          Text(
            "FoodShare Options",
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            "Choose how you want to share this order",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColor.secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 30),

          // Invite Friends Button
          Container(
            height: 55,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.primaryGradient),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: TColor.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: () async {
                const String inviteLink =
                    "https://yourapp.com/invite?order=123";

                await Share.share(
                  "Join me on this food order and get discounts! \n$inviteLink",
                  subject: "FoodShare Invite",
                );
              },
              icon: const Icon(Icons.group_add, color: Colors.white, size: 22),
              label: const Text(
                "Invite Friends",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Random Joins Button
          Container(
            height: 55,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.primaryGradient),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: TColor.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ActiveOrdersView()));
              },
              icon: const Icon(Icons.public, color: Colors.white, size: 22),
              label: const Text(
                "Wait for Random Joins",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
