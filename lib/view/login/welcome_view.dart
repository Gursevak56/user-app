import 'package:flutter/material.dart';
import 'package:food_delivery/view/login/login_view.dart';
import 'package:food_delivery/view/login/sing_up_view.dart';
import 'package:food_delivery/view/on_boarding/on_boarding_view.dart';

import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: media.width,
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
            SizedBox(
              height: media.width * 0.1,
            ),
            Text(
              "Explore tasty meals from top restaurants and \n enjoy quick delivery right to you.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: media.width * 0.1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: RoundButton(
                title: "Explore Now",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnBoardingView(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: RoundButton(
                title: "Login",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginView(),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: RoundButton(
                title: "Create an Account",
                type: RoundButtonType.textPrimary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpView(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
