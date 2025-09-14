import 'package:flutter/material.dart';
import 'package:food_delivery/view/checkout/checkout_message_view.dart';
import 'package:food_delivery/view/more/food_share_option_view.dart';
import '../../common/color_extension.dart';

class OrderTypeView extends StatefulWidget {
  const OrderTypeView({super.key});

  @override
  State<OrderTypeView> createState() => _OrderTypeViewState();
}

class _OrderTypeViewState extends State<OrderTypeView> {
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
          Text(
            "Select Order Type",
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Choose how you want to place your order",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColor.secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 30),
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
                showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    isDismissible: false,
                    builder: (context) {
                      return const CheckoutMessageView();
                    });
              },
              icon: const Icon(Icons.person, color: Colors.white, size: 22),
              label: const Text(
                "Solo Order",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 15),
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
                showDialog(
                  context: context,
                  builder: (context) => const Dialog(
                    insetPadding: EdgeInsets.all(20),
                    child: FoodShareOptionsView(),
                  ),
                );
              },
              icon: const Icon(Icons.group, color: Colors.white, size: 22),
              label: const Text(
                "FoodShare",
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
