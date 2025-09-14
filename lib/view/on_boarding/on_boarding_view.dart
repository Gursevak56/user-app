import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/on_boarding_button.dart';
import 'package:food_delivery/view/main_tabview/main_tabview.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int selectPage = 0;
  PageController controller = PageController();

  List<Map<String, String>> pageArr = [
    {
      "title": "Order from your favorite restaurants",
      "subtitle":
          "Browse menus and get delicious meals delivered to your door.",
      "image": "assets/img/on_boarding_1.png",
    },
    {
      "title": "Fast & Safe Delivery",
      "subtitle": "Your food arrives hot, fresh, and contact-free every time.",
      "image": "assets/img/on_boarding_2.png",
    },
    {
      "title": "Exclusive Offers & Rewards",
      "subtitle":
          "Unlock discounts, earn points, and enjoy special deals daily.",
      "image": "assets/img/on_boarding_3.png",
    },
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller.addListener(() {
      setState(() {
        selectPage = controller.page?.round() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: TColor.primaryGradient,
                  begin: Alignment.centerRight,
                  end: Alignment.bottomLeft),
            ),
          ),
          Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: media.height * 0.8,
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(50),
                              bottomRight: Radius.circular(50))),
                      child: PageView.builder(
                        controller: controller,
                        itemCount: pageArr.length,
                        itemBuilder: (context, index) {
                          final pObj = pageArr[index];
                          return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: Column(children: [
                                SizedBox(
                                  height: media.width * 0.2,
                                ),
                                Image.asset(
                                  pObj["image"].toString(),
                                  width: media.width * 0.65,
                                  height: media.width * 0.8,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(
                                  height: media.width * 0.2,
                                ),
                                Text(
                                  pObj["title"].toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Text(
                                  pObj["subtitle"].toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: TColor.secondaryText,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ]));
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: media.height * 0.50,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pageArr.map((e) {
                        var index = pageArr.indexOf(e);

                        bool isActive = index == selectPage;

                        return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isActive
                                    ? TColor.primary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? TColor.primary
                                      : TColor.placeholder,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ));
                      }).toList(),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: selectPage != 2
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomOutlinedButton(
                              onPressed: () {
                                if (selectPage < 2) {
                                  controller.animateToPage(
                                    selectPage + 1,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              title: "Next",
                            ),
                            CustomOutlinedButton(
                              onPressed: () {
                                controller.animateToPage(
                                  2,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                              title: "Skip",
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: CustomOutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainTabView(),
                              ),
                            );
                          },
                          title: "Done",
                        ),
                      ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
