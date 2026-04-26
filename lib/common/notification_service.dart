import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:food_delivery/common/globs.dart';

class NotificationService {
  static const String _notifUrl = "${SVKey.restaurantBaseUrl}/notifications";

  static Future<void> setupFCM() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await messaging.getToken();
        if (token != null && Globs.udValueBool(Globs.userLogin)) {
          await registerDeviceToken(token);
        }

        messaging.onTokenRefresh.listen((newToken) {
          if (Globs.udValueBool(Globs.userLogin)) {
            registerDeviceToken(newToken);
          }
        });
      }
    } catch (e) {
      debugPrint("Error setting up FCM: $e");
    }
  }

  static Future<void> registerDeviceToken(String token) async {
    final platform = Platform.isIOS ? 'ios' : 'android';
    await ServiceCall.post(
      {"device_token": token, "platform": platform},
      "$_notifUrl/device-token",
      isToken: true,
      withSuccess: (res) async {
        debugPrint("Token registered successfully");
      },
      failure: (err) async {
        debugPrint("Failed to register token: $err");
      },
    );
  }

  static Future<void> removeDeviceToken(String token) async {
    await ServiceCall.delete(
      "$_notifUrl/device-token",
      body: {"device_token": token},
      isToken: true,
      withSuccess: (res) async {
        debugPrint("Token removed successfully");
      },
      failure: (err) async {
        debugPrint("Failed to remove token: $err");
      },
    );
  }

  static Future<void> fetchNotifications(
      int page, Function(List, int) onSuccess, Function(String) onFailure) async {
    await ServiceCall.get(
      "$_notifUrl?page=$page&limit=20",
      isToken: true,
      withSuccess: (res) async {
        if (res[KKey.statusCode] == 200) {
          final data = res["data"] as Map<String, dynamic>? ?? {};
          final items = data["items"] as List? ?? [];
          final pagination = data["pagination"] as Map<String, dynamic>? ?? {};
          final total = pagination["total"] as int? ?? 0;
          onSuccess(items, total);
        } else {
          onFailure(res[KKey.message] ?? "Failed to fetch notifications");
        }
      },
      failure: (err) async {
        onFailure(err.toString());
      },
    );
  }

  static Future<void> markAsRead(String id, Function() onSuccess, Function(String) onFailure) async {
    await ServiceCall.put(
      "$_notifUrl/$id/read",
      body: {},
      isToken: true,
      withSuccess: (res) async {
        if (res[KKey.statusCode] == 200) {
          onSuccess();
        } else {
          onFailure(res[KKey.message] ?? "Failed");
        }
      },
      failure: (err) async {
        onFailure(err.toString());
      },
    );
  }
}
