import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/tab_button.dart';
import 'package:food_delivery/view/home/home_view.dart';
import 'package:food_delivery/view/more/more_view.dart';

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
        return const MoreView();
      default:
        return const HomeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: PageStorage(bucket: storageBucket, child: selectPageView),
      backgroundColor: TColor.background,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: TColor.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
      top: false,
      bottom: true,
      child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  title: "More",
                  icon: "assets/img/tab_more_icon.png",
                  onTap: () {
                    selctTab = 1;
                    selectPageView = const MoreView();
                    setState(() {});
                  },
                  isSelected: selctTab == 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
