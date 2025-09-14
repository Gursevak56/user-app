import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/view/main_tabview/main_tabview.dart';
import 'package:food_delivery/view/on_boarding/on_boarding_view.dart';

import '../../common/globs.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StarupViewState();
}

class _StarupViewState extends State<StartupView> {
  @override
  void initState() {
    super.initState();
    goWelcomePage();
  }

  void goWelcomePage() async {
    await Future.delayed(const Duration(seconds: 3));
    welcomePage();
  }

  void welcomePage() {
    if (Globs.udValueBool(Globs.userLogin)) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const MainTabView()));
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const OnBoardingView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/img/splash_bg.png",
            width: media.width,
            height: media.height,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: TColor.primaryGradient,
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft)),
            child: Image.asset(
              "assets/img/app-logo-update.png",
              width: media.width * 0.55,
              height: media.width * 0.55,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
