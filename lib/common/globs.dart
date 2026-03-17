import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:food_delivery/main.dart';

class Globs {
  static const appName = "Food Delivery";
  static const userPayload = "user_payload";
  static const userLogin = "user_login";
  static const userLat = "user_lat";
  static const userLng = "user_lng";
  static const userProfile = "user_profile"; // to store cached profile

  static void showHUD({String status = "loading ....."}) async {
    await Future.delayed(const Duration(milliseconds: 1));
    EasyLoading.show(status: status);
  }

  static void hideHUD() {
    EasyLoading.dismiss();
  }

  static void udSet(dynamic data, String key) {
    var jsonStr = json.encode(data);
    prefs?.setString(key, jsonStr);
  }

  static void udStringSet(String data, String key) {
    prefs?.setString(key, data);
  }

  static void udBoolSet(bool data, String key) {
    prefs?.setBool(key, data);
  }

  static void udIntSet(int data, String key) {
    prefs?.setInt(key, data);
  }

  static void udDoubleSet(double data, String key) {
    prefs?.setDouble(key, data);
  }

  static dynamic udValue(String key) {
    return json.decode(prefs?.get(key) as String? ?? "{}");
  }

  static String udValueString(String key) {
    return prefs?.get(key) as String? ?? "";
  }

  static bool udValueBool(String key) {
    return prefs?.get(key) as bool? ?? false;
  }

  static bool udValueTrueBool(String key) {
    return prefs?.get(key) as bool? ?? true;
  }

  static int udValueInt(String key) {
    return prefs?.get(key) as int? ?? 0;
  }

  static double udValueDouble(String key) {
    return prefs?.get(key) as double? ?? 0.0;
  }

  static void udRemove(String key) {
    prefs?.remove(key);
  }

  static Future<String> timeZone() async {
    try {
      return await FlutterTimezone.getLocalTimezone();
    } on PlatformException {
      return "";
    }
  }

  static getToken() {
    return Globs.udValueString(Globs.userPayload);
  }

  /// Extracts userId from the stored JWT token's 'sub' claim.
  /// Falls back to stored 'user_id' pref if JWT decode fails.
  static String getUserId() {
    // First try stored user_id
    final storedId = udValueString('user_id');
    if (storedId.isNotEmpty) return storedId;

    // Fallback: decode JWT
    try {
      final token = getToken() as String? ?? '';
      if (token.isEmpty) return '';
      final parts = token.split('.');
      if (parts.length != 3) return '';
      String payload = parts[1];
      // Normalize base64
      switch (payload.length % 4) {
        case 2: payload += '=='; break;
        case 3: payload += '='; break;
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> claims = json.decode(decoded);
      return claims['sub']?.toString() ?? '';
    } catch (e) {
      if (kDebugMode) print('getUserId JWT decode error: $e');
      return '';
    }
  }
}

class SVKey {
  static const mainUrl = "https://user-prod.mangaale.com";
  static const restaurantBaseUrl = "https://restaurant-prod.mangaale.com";
  static const cartBaseUrl = "https://qrunch-api-prod.mangaale.com/api";
  static const baseUrl = '$mainUrl/users';
  static const nodeUrl = mainUrl;

  static const svLogin = '$baseUrl/login';
  static const svSignUp = baseUrl; // the sign up endpoint is exactly /users
  static const svForgotPasswordRequest = '$baseUrl/forgot_password_request';
  static const svForgotPasswordVerify = '$baseUrl/forgot_password_verify';
  static const svForgotPasswordSetNew = '$baseUrl/forgot_password_set_new';
  
  static const svProfile = '$baseUrl/profile';
  static const svAddresses = '$baseUrl/addresses';

  // Cart endpoints
  static String cartUrl(String userId) => '$cartBaseUrl/cart/$userId';
  static String cartItemUrl(String userId, int dishId) =>
      '$cartBaseUrl/cart/$userId/$dishId';
  static const cartAddUrl = '$cartBaseUrl/cart';

  // Order endpoint
  static const onlineOrderUrl = '$restaurantBaseUrl/api/orders/online';
}

class KKey {
  static const payload = "payload";
  static const status = "status";
  static const statusCode = "statusCode"; // was "status_code"
  static const message = "message";
  static const authToken = "authToken";
  static const name = "name";
  static const email = "email";
  static const mobile = "mobile";
  static const address = "address";
  static const userId = "user_id";
  static const resetCode = "reset_code";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
  // static const  = "";
}

class MSG {
  static const enterEmail = "Please enter your valid email address.";
  static const enterName = "Please enter your name.";
  static const enterCode = "Please enter valid reset code.";

  static const enterMobile = "Please enter your valid mobile number.";
  static const enterAddress = "Please enter your address.";
  static const enterPassword =
      "Please enter password minimum 6 characters at least.";
  static const enterPasswordNotMatch = "Please enter password not match.";
  static const success = "success";
  static const fail = "fail";
}
