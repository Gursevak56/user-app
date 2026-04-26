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

  Future<void> _requestPermissions() async {
    try {
      await Permission.locationWhenInUse.request();
      await Permission.notification.request();
    } catch (e) {
      debugPrint("Error requesting permissions: $e");
    }
  }

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
          Globs.udStringSet(token, Globs.userPayload);
          Globs.udBoolSet(true, Globs.userLogin);

          await _requestPermissions();
          await LocationService.fetchAndSaveCurrentLocation();

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const OnBoardingView(),
            ),
          );
        } else {
          mdShowAlert(
              Globs.appName, responseObj[KKey.message] ?? MSG.fail, () {});
        }
      },
      failure: (err) async {
        Globs.hideHUD();
        mdShowAlert(Globs.appName, err.toString(), () {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // App icon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: TColor.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_rounded,
                  size: 44,
                  color: TColor.primary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                "Welcome Back",
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.primaryText,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Sign in to continue exploring",
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.secondaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 36),
              
              RoundTextfield(
                hintText: "Email Address",
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
              
              const SizedBox(height: 12),
              
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
                  "Forgot Password?",
                  style: GoogleFonts.plusJakartaSans(
                    color: TColor.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(child: Divider(color: TColor.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "OR",
                      style: GoogleFonts.plusJakartaSans(
                        color: TColor.placeholder,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: TColor.border)),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Social login row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialBtn(
                    icon: "assets/img/facebook_logo.png",
                    onTap: () {},
                  ),
                  const SizedBox(width: 20),
                  _buildSocialBtn(
                    icon: "assets/img/google_logo.png",
                    onTap: () {},
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
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

  Widget _buildSocialBtn({required String icon, required VoidCallback onTap}) {
    return Material(
      color: TColor.textfield,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 72,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: TColor.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Image.asset(icon, width: 24, height: 24),
        ),
      ),
    );
  }
}
