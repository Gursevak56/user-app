import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/tab_button.dart';
import 'package:food_delivery/view/food_share/food_share_view.dart';
import 'package:food_delivery/view/home/home_view.dart';
import 'package:food_delivery/view/menu/menu_view.dart';
import 'package:food_delivery/view/more/more_view.dart';
import 'package:food_delivery/view/offer/offer_view.dart';

class MainTabView extends StatefulWidget {
  final int initialTab;
  const MainTabView({super.key, this.initialTab = 2});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  late int selctTab;
  PageStorageBucket storageBucket = PageStorageBucket();
  late Widget selectPageView;

  @override
  void initState() {
    super.initState();
    selctTab = widget.initialTab;
    selectPageView = _getPageForTab(selctTab);
  }

  Widget _getPageForTab(int index) {
    switch (index) {
      case 0:
        return const MenuView();
      case 1:
        return const OfferView();
      case 2:
        return const HomeView();
      case 3:
        return const FoodShareView();
      case 4:
        return const MoreView();
      default:
        return const HomeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: storageBucket, child: selectPageView),
      backgroundColor: const Color(0xfff5f5f5),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {
            if (selctTab != 2) {
              selctTab = 2;
              selectPageView = const HomeView();
            }
            if (mounted) setState(() {});
          },
          shape: const CircleBorder(),
          backgroundColor: selctTab == 2 ? TColor.primary : TColor.placeholder,
          child: Image.asset("assets/img/tab_home.png", width: 30, height: 30),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: TColor.white,
        shadowColor: Colors.black,
        elevation: 1,
        notchMargin: 12,
        height: 64,
        shape: const CircularNotchedRectangle(),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TabButton(
                title: "Menu",
                icon: "assets/img/tab_menu.png",
                onTap: () {
                  selctTab = 0;
                  selectPageView = const MenuView();
                  setState(() {});
                },
                isSelected: selctTab == 0,
              ),
              TabButton(
                title: "Offer",
                icon: "assets/img/tab_offer.png",
                onTap: () {
                  selctTab = 1;
                  selectPageView = const OfferView();
                  setState(() {});
                },
                isSelected: selctTab == 1,
              ),
              const SizedBox(width: 40, height: 40),
              TabButton(
                title: "FoodShare",
                icon: "assets/img/tab_food_share.png",
                onTap: () {
                  selctTab = 3;
                  selectPageView = const FoodShareView();
                  setState(() {});
                },
                isSelected: selctTab == 3,
              ),
              TabButton(
                title: "More",
                icon: "assets/img/tab_more.png",
                onTap: () {
                  selctTab = 4;
                  selectPageView = const MoreView();
                  setState(() {});
                },
                isSelected: selctTab == 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
