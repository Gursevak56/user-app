import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/tab_button.dart';
import 'package:food_delivery/view/food_share/food_share_view.dart';
import 'package:food_delivery/view/home/home_view.dart';
import 'package:food_delivery/view/more/more_view.dart';
import 'package:food_delivery/view/onpl/o_n_p_l.dart';

class MainTabView extends StatefulWidget {
  final int initialTab;
  const MainTabView({super.key, this.initialTab = 0});

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
        return const HomeView();
      case 1:
        return const ONPLView();
      case 2:
        return const FoodShareView();
      case 3:
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFE5E7EB),
              width: 2,
            ),
          ),
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          height: 64,
          elevation: 2,
          color: TColor.white,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TabButton(
                  title: "Home",
                  icon: "assets/img/tab_home.png",
                  onTap: () {
                    selctTab = 0;
                    selectPageView = const HomeView();
                    setState(() {});
                  },
                  isSelected: selctTab == 0,
                ),
                TabButton(
                  title: "ONPL",
                  icon: "assets/img/tab_onpl.png",
                  onTap: () {
                    selctTab = 1;
                    selectPageView = const ONPLView();
                    setState(() {});
                  },
                  isSelected: selctTab == 1,
                ),
                TabButton(
                  title: "FoodShare",
                  icon: "assets/img/tab_foodshare.png",
                  onTap: () {
                    selctTab = 2;
                    selectPageView = const FoodShareView();
                    setState(() {});
                  },
                  isSelected: selctTab == 2,
                ),
                TabButton(
                  title: "More",
                  icon: "assets/img/tab_more_icon.png",
                  onTap: () {
                    selctTab = 3;
                    selectPageView = const MoreView();
                    setState(() {});
                  },
                  isSelected: selctTab == 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
