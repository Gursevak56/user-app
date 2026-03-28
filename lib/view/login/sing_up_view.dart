// lib/view/login/sign_up_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/extension.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:food_delivery/common/location_service.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/common_widget/round_textfield.dart';
import 'package:food_delivery/view/login/login_view.dart';
import 'package:food_delivery/view/on_boarding/on_boarding_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController txtFirstName = TextEditingController();
  final TextEditingController txtLastName = TextEditingController();
  final TextEditingController txtMobile = TextEditingController();
  final TextEditingController txtAddress = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtConfirmPassword = TextEditingController();

  void btnSignUp() {
    if (txtFirstName.text.isEmpty) {
      mdShowAlert(Globs.appName, MSG.enterName, () {});
      return;
    }

    if (txtLastName.text.isEmpty) {
      mdShowAlert(Globs.appName, MSG.enterName, () {});
      return;
    }

    if (!txtEmail.text.isEmail) {
      mdShowAlert(Globs.appName, MSG.enterEmail, () {});
      return;
    }

    if (txtMobile.text.isEmpty) {
      mdShowAlert(Globs.appName, MSG.enterMobile, () {});
      return;
    }

    if (txtAddress.text.isEmpty) {
      mdShowAlert(Globs.appName, MSG.enterAddress, () {});
      return;
    }

    if (txtPassword.text.length < 6) {
      mdShowAlert(Globs.appName, MSG.enterPassword, () {});
      return;
    }

    if (txtPassword.text != txtConfirmPassword.text) {
      mdShowAlert(Globs.appName, MSG.enterPasswordNotMatch, () {});
      return;
    }

    endEditing();
    serviceCallSignUp({
      "email": txtEmail.text,
      "phone": txtMobile.text,
      "phone_country_code": "+91",
      "first_name": txtFirstName.text,
      "last_name": txtLastName.text,
      "display_name": "${txtFirstName.text} ${txtLastName.text}",
      "password": txtPassword.text,
      "primary_role": "customer",
    });
  }

  void serviceCallSignUp(Map<String, dynamic> parameter) async {
    Globs.showHUD();
    await ServiceCall.post(
      parameter,
      "",
      withSuccess: (responseObj) async {
        Globs.hideHUD();
        if (responseObj[KKey.statusCode] == 201) {
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
            mdShowAlert(Globs.appName, MSG.fail, () {});
          }
        } else {
          mdShowAlert(
            Globs.appName,
            responseObj[KKey.message] as String? ?? MSG.fail,
            () {},
          );
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TColor.primaryLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 36,
                  color: TColor.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Sign Up",
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.primaryText,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Add your details to sign up",
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              RoundTextfield(
                hintText: "First Name",
                controller: txtFirstName,
                left: Icon(Icons.person_outline_rounded,
                    color: TColor.placeholder, size: 20),
              ),
              const SizedBox(height: 14),
              RoundTextfield(
                hintText: "Last Name",
                controller: txtLastName,
                left: Icon(Icons.person_outline_rounded,
                    color: TColor.placeholder, size: 20),
              ),
              const SizedBox(height: 14),
              RoundTextfield(
                hintText: "Email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
                left: Icon(Icons.email_outlined,
                    color: TColor.placeholder, size: 20),
              ),
              const SizedBox(height: 14),
              RoundTextfield(
                hintText: "Mobile No",
                controller: txtMobile,
                keyboardType: TextInputType.phone,
                left: Icon(Icons.phone_outlined,
                    color: TColor.placeholder, size: 20),
              ),
              const SizedBox(height: 14),
              RoundTextfield(
                hintText: "Address",
                controller: txtAddress,
                left: Icon(Icons.location_on_outlined,
                    color: TColor.placeholder, size: 20),
              ),
              const SizedBox(height: 14),
              RoundTextfield(
                hintText: "Password",
                controller: txtPassword,
                obscureText: true,
                left: Icon(Icons.lock_outline_rounded,
                    color: TColor.placeholder, size: 20),
              ),
              const SizedBox(height: 14),
              RoundTextfield(
                hintText: "Confirm Password",
                controller: txtConfirmPassword,
                obscureText: true,
                left: Icon(Icons.lock_outline_rounded,
                    color: TColor.placeholder, size: 20),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: TColor.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "User Type: Customer",
                  style: GoogleFonts.plusJakartaSans(
                    color: TColor.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              RoundButton(
                title: "Sign Up",
                onPressed: () => {btnSignUp()},
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginView()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Already have an Account? ",
                      style: GoogleFonts.plusJakartaSans(
                        color: TColor.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Login",
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

  Future<void> _requestPermissions() async {
    try {
      await Permission.locationWhenInUse.request();
      await Permission.notification.request();
    } catch (e) {
      debugPrint("Error requesting permissions: $e");
    }
  }
}
