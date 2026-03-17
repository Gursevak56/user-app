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

  /// [path] should be the fully qualified URL or an endpoint appended to a specific base URL
  /// e.g. SVKey.restaurantBaseUrl + "/api/home"
  static Future<void> get(
    String fullUrl, {
    Map<String, String>? queryParameters,
    bool isToken = true,
    ResSuccess? withSuccess,
    ResFailure? failure,
  }) async {
    try {
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (isToken) {
        headers['Authorization'] = 'Bearer ${Globs.getToken()}';
      }

      var uri = Uri.parse(fullUrl);
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      final response = await http.get(
        uri,
        headers: headers,
      );

      if (kDebugMode) {
        print('→ [GET] $uri');
        print('← [RESPONSE] ${response.statusCode}: ${response.body}');
      }

      var jsonObj = <String, dynamic>{};
      try {
        jsonObj = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        jsonObj = {"message": response.body}; // Fallback for plain text errs
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (withSuccess != null) await withSuccess(jsonObj);
      } else {
        if (failure != null) await failure(jsonObj);
      }
    } catch (err) {
      if (failure != null) await failure(err.toString());
    }
  }

  /// POST to an arbitrary full URL (not relative to baseUrl)
  static Future<void> postToUrl(
    Map<String, dynamic> parameter,
    String fullUrl, {
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

      final uri = Uri.parse(fullUrl);
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

  /// PUT to a full URL
  static Future<void> put(
    String fullUrl, {
    Map<String, dynamic>? body,
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

      final uri = Uri.parse(fullUrl);
      final response = await http.put(
        uri,
        body: body != null ? json.encode(body) : null,
        headers: headers,
      );

      if (kDebugMode) {
        print('→ [PUT] $uri');
        print('   request body: ${json.encode(body)}');
        print('← [RESPONSE] ${response.statusCode}: ${response.body}');
      }

      var jsonObj = <String, dynamic>{};
      try {
        jsonObj = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        jsonObj = {"message": response.body};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (withSuccess != null) await withSuccess(jsonObj);
      } else {
        if (failure != null) await failure(jsonObj);
      }
    } catch (err) {
      if (failure != null) await failure(err.toString());
    }
  }

  /// DELETE to a full URL with optional body
  static Future<void> delete(
    String fullUrl, {
    Map<String, dynamic>? body,
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

      final uri = Uri.parse(fullUrl);
      final request = http.Request('DELETE', uri)
        ..headers.addAll(headers);
      if (body != null) {
        request.body = json.encode(body);
      }

      final streamed = await request.send();
      final responseBody = await streamed.stream.bytesToString();

      if (kDebugMode) {
        print('→ [DELETE] $uri');
        print('   request body: ${json.encode(body)}');
        print('← [RESPONSE] ${streamed.statusCode}: $responseBody');
      }

      var jsonObj = <String, dynamic>{};
      try {
        jsonObj = json.decode(responseBody) as Map<String, dynamic>;
      } catch (e) {
        jsonObj = {"message": responseBody};
      }

      if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
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
