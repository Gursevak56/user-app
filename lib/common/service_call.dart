// services/service_call.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/locator.dart';
import 'package:http/http.dart' as http;

typedef ResSuccess = Future<void> Function(Map<String, dynamic>);
typedef ResFailure = Future<void> Function(dynamic);

class ServiceCall {
  static final NavigationService navigationService =
      locator<NavigationService>();
  static Map userPayload = {};

  /// [path] should be the endpoint, e.g. '/login'
  static Future<void> post(
    Map<String, dynamic> parameter,
    String path, {
    bool isToken = true,
    ResSuccess? withSuccess,
    ResFailure? failure,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (isToken) {
        headers['Authorization'] = 'Bearer ${Globs.getToken()}';
      }

      // use the path parameter
      final uri = Uri.parse(SVKey.baseUrl + path);

      final response = await http.post(
        uri,
        body: json.encode(parameter),
        headers: headers,
      );

      if (kDebugMode) {
        print('→ [POST] $uri');
        print('   request body: ${json.encode(parameter)}');
        print('← [RESPONSE] ${response.statusCode}: ${response.body}');
      }

      final Map<String, dynamic> jsonObj =
          json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (withSuccess != null) await withSuccess(jsonObj);
      } else {
        if (failure != null) await failure(jsonObj);
      }
    } catch (err) {
      if (failure != null) await failure(err.toString());
    }
  }

  static void logout() {
    Globs.udBoolSet(false, Globs.userLogin);
    userPayload = {};
    navigationService.navigateTo("welcome");
  }
}
