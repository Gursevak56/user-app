import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';

class ONPLView extends StatefulWidget {
  const ONPLView({super.key});

  @override
  State<ONPLView> createState() => _ONPLViewState();
}

class _ONPLViewState extends State<ONPLView>
    with SingleTickerProviderStateMixin {
  double total = 3000;
  double spent = 1250;
  double payLaterLimit = 200;

  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        progress = (spent / total).clamp(0.0, 1.0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ Fade + slide animation
              Text(
                "Order Now,\nPay Later",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Spend more, unlock credit to pay later.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "₹${spent.toInt()} spent out of ₹${total.toInt()}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TColor.primaryText,
                ),
              ),
              const SizedBox(height: 12),

              // 🔥 Gradient animated progress bar
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(seconds: 2),
                curve: Curves.easeOut,
                builder: (context, value, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 16,
                          width: double.infinity,
                          color: TColor.placeholder,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: constraints.maxWidth * value,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: TColor.primaryGradient,
                                      ),
                                      borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(
                                          value == 1.0 ? 12 : 50,
                                        ),
                                      )),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          "Spending Progress: ${(value * 100).toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: TColor.secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),
              Text(
                "Spend ₹${(total - spent).toInt()} more to unlock\n₹${payLaterLimit.toInt()} Pay-later limit",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Card with shadow polish
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: TColor.primaryText.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatBox(
                          icon: Icons.room_service,
                          title: "Total Spend",
                          value: "₹$total",
                        ),
                        _buildStatBox(
                          icon: Icons.credit_card,
                          title: "Pay-later Limit",
                          value: "₹$payLaterLimit",
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ✅ Gradient button with ripple
              Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: TColor.primaryGradient),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: TColor.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {},
                  child: const Center(
                    child: Text(
                      "Order Now, Pay Later",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: TColor.secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Pay-later orders are added to your next bill. Spend more to unlock higher limits!",
                      style: TextStyle(
                        fontSize: 13,
                        color: TColor.secondaryText,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: TColor.secondary.withOpacity(0.1),
          child: Icon(icon, size: 32, color: TColor.secondary),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            color: TColor.secondaryText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
