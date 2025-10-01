import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_icon_button.dart';
import 'package:food_delivery/view/checkout/add_card_view.dart';

import '../../common_widget/round_button.dart';
import 'my_order_view.dart';

class PaymentDetailsView extends StatefulWidget {
  const PaymentDetailsView({super.key});

  @override
  State<PaymentDetailsView> createState() => _PaymentDetailsViewState();
}

class _PaymentDetailsViewState extends State<PaymentDetailsView> {
  List cardArr = [
    {
      "icon": "assets/img/visa_icon.png",
      "card": "**** **** **** 2187",
    }
  ];

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
            Navigator.pop(context);
          },
          icon: Image.asset("assets/img/btn_back.png", width: 20, height: 20),
        ),
        title: Text(
          "Payment Details",
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 0, 15),
                child: Text(
                  "Customize your payment method",
                  style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Divider(
                  color: TColor.secondaryText.withOpacity(0.4),
                  height: 1,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: TColor.textfield,
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            offset: Offset(0, 9))
                      ]),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 35),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Cash/Card On Delivery",
                              style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                            Image.asset(
                              "assets/img/check.png",
                              width: 20,
                              height: 20,
                              color: TColor.primary,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: Divider(
                          color: TColor.secondaryText.withOpacity(0.4),
                          height: 1,
                        ),
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: cardArr.length,
                        itemBuilder: ((context, index) {
                          var cObj = cardArr[index] as Map? ?? {};
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 35),
                            child: Row(
                              children: [
                                Image.asset(
                                  cObj["icon"].toString(),
                                  width: 50,
                                  height: 35,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Text(
                                    cObj["card"].toString(),
                                    style: TextStyle(
                                        color: TColor.secondaryText,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  height: 28,
                                  child: RoundButton(
                                    title: 'Delete Card',
                                    fontSize: 12,
                                    onPressed: () {},
                                    type: RoundButtonType.textPrimary,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: Divider(
                          color: TColor.secondaryText.withOpacity(0.4),
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 35),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Other Methods",
                              style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: RoundIconButton(
                    title: "Add Another Credit/Debit Card",
                    icon: "assets/img/add.png",
                    fontSize: 16,
                    onPressed: () {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) {
                            return const AddCardView();
                          });
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCardView() ));
                    }),
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
