// lib/view/login/sign_up_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/extension.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/common_widget/round_textfield.dart';
import 'package:food_delivery/view/login/login_view.dart';
import 'package:food_delivery/view/on_boarding/on_boarding_view.dart';

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
      "first_name": txtFirstName.text,
      "last_name": txtLastName.text,
      "email": txtEmail.text,
      "phone": txtMobile.text,
      "address": txtAddress.text,
      "password": txtPassword.text,
      "user_type": "customer",
      "push_token": "",
      "device_type": Platform.isAndroid ? "A" : "I",
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
          final token = responseObj[KKey.authToken] as String?;
          if (token != null && token.isNotEmpty) {
            Globs.udStringSet(token, Globs.userPayload);
            Globs.udBoolSet(true, Globs.userLogin);
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 64),
              Text("Sign Up",
                  style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 30,
                      fontWeight: FontWeight.w800)),
              Text("Add your details to sign up",
                  style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 25),
              RoundTextfield(hintText: "First Name", controller: txtFirstName),
              const SizedBox(height: 16),
              RoundTextfield(hintText: "Last Name", controller: txtLastName),
              const SizedBox(height: 25),
              RoundTextfield(
                  hintText: "Email",
                  controller: txtEmail,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 25),
              RoundTextfield(
                  hintText: "Mobile No",
                  controller: txtMobile,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 25),
              RoundTextfield(hintText: "Address", controller: txtAddress),
              const SizedBox(height: 25),
              RoundTextfield(
                  hintText: "Password",
                  controller: txtPassword,
                  obscureText: true),
              const SizedBox(height: 25),
              RoundTextfield(
                  hintText: "Confirm Password",
                  controller: txtConfirmPassword,
                  obscureText: true),
              const SizedBox(height: 25),
              Text("User Type: customer",
                  style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 25),
              RoundButton(
                title: "Sign Up",
                onPressed: () => {btnSignUp()},
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginView()),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "Already have an Account? ",
                          style: TextStyle(
                              color: TColor.secondaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      TextSpan(
                          text: "Login",
                          style: TextStyle(
                              color: TColor.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
