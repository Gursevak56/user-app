import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/extension.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/view/login/rest_password_view.dart';
import 'package:food_delivery/view/login/sing_up_view.dart';
import 'package:food_delivery/view/on_boarding/on_boarding_view.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../common/service_call.dart';
import '../../common/location_service.dart';
import '../../common_widget/round_icon_button.dart';
import '../../common_widget/round_textfield.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 64),
              // App icon
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: TColor.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.restaurant_rounded,
                  size: 40,
                  color: TColor.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Login",
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.primaryText,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Add your details to login",
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              RoundTextfield(
                hintText: "Your Email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
                left: Icon(Icons.email_outlined,
                    color: TColor.placeholder, size: 20),
              ),
              const SizedBox(height: 16),
              RoundTextfield(
                hintText: "Password",
                controller: txtPassword,
                obscureText: true,
                left: Icon(Icons.lock_outline_rounded,
                    color: TColor.placeholder, size: 20),
              ),
              const SizedBox(height: 24),
              RoundButton(
                title: "Login",
                onPressed: () {
                  btnLogin();
                },
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResetPasswordView(),
                    ),
                  );
                },
                child: Text(
                  "Forgot your password?",
                  style: GoogleFonts.plusJakartaSans(
                    color: TColor.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: TColor.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "or login with",
                      style: GoogleFonts.plusJakartaSans(
                        color: TColor.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: TColor.border)),
                ],
              ),
              const SizedBox(height: 24),
              RoundIconButton(
                icon: "assets/img/facebook_logo.png",
                title: "Login with Facebook",
                onPressed: () {},
              ),
              const SizedBox(height: 14),
              RoundIconButton(
                icon: "assets/img/google_logo.png",
                title: "Login with Google",
                onPressed: () {},
              ),
              const SizedBox(height: 60),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpView(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Don't have an Account? ",
                      style: GoogleFonts.plusJakartaSans(
                        color: TColor.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Sign Up",
                      style: GoogleFonts.plusJakartaSans(
                        color: TColor.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //TODO: Action
  void btnLogin() {
    if (!txtEmail.text.isEmail) {
      mdShowAlert(Globs.appName, MSG.enterEmail, () {});
      return;
    }

    if (txtPassword.text.length < 6) {
      mdShowAlert(Globs.appName, MSG.enterPassword, () {});
      return;
    }

    endEditing();

    serviceCallLogin({"email": txtEmail.text, "password": txtPassword.text});
  }

  //TODO: ServiceCall

  void serviceCallLogin(Map<String, dynamic> parameter) async {
    Globs.showHUD();
    await ServiceCall.post(
      parameter,
      "login",
      withSuccess: (responseObj) async {
        Globs.hideHUD();
        final data = responseObj["data"] as Map<String, dynamic>?;
        final token = data?["authToken"] as String?;
        if (token != null && token.isNotEmpty) {
          // Save token and login flag
          Globs.udStringSet(token, Globs.userPayload);
          Globs.udBoolSet(true, Globs.userLogin);

          await _requestPermissions();
          await LocationService.fetchAndSaveCurrentLocation();

          if (!mounted) return;
          // Navigate to OnBoarding and remove login from stack
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const OnBoardingView(),
            ),
          );
        } else {
          mdShowAlert(Globs.appName, responseObj[KKey.message] ?? MSG.fail, () {});
        }
      },
      failure: (err) async {
        Globs.hideHUD();
        mdShowAlert(Globs.appName, err.toString(), () {});
      },
    );
  }

  Future<void> _requestPermissions() async {
    try {
      await Permission.locationWhenInUse.request();
      await Permission.notification.request();
    } catch (e) {
      debugPrint("Error requesting permissions: $e");
    }
  }
}
