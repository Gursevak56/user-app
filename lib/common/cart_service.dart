import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/service_call.dart';

/// Wraps all cart API interactions with the Node.js backend.
class CartService {
  /// Normalize addon IDs: deduplicate, convert to strings, sort.
  static List<String> normalizeAddonIds(List? ids) {
    if (ids == null || ids.isEmpty) return [];
    final set = <String>{};
    for (var id in ids) {
      final s = id.toString().trim();
      if (s.isNotEmpty) set.add(s);
    }
    final sorted = set.toList()..sort();
    return sorted;
  }

  /// GET /api/cart/:userId — Fetch cart
  static Future<List> getCart() async {
    final userId = Globs.getUserId();
    if (userId.isEmpty) return [];

    List items = [];
    await ServiceCall.get(
      SVKey.cartUrl(userId),
      isToken: true,
      withSuccess: (responseObj) async {
        // Response could be the cart object directly or wrapped
        if (responseObj['items'] != null) {
          items = responseObj['items'] as List;
        } else if (responseObj['cart'] != null) {
          final cart = responseObj['cart'];
          if (cart is Map && cart['items'] != null) {
            items = cart['items'] as List;
          }
        }
      },
      failure: (err) async {
        if (kDebugMode) print('CartService.getCart error: $err');
      },
    );
    return items;
  }

  /// POST /api/cart — Add item to cart
  static Future<bool> addToCart({
    required int dishId,
    required String name,
    required double price,
    required int quantity,
    int? variantId,
    String? variantName,
    double? variantPrice,
    List<int>? addonIds,
    List<Map<String, dynamic>>? addonDetails,
  }) async {
    final userId = Globs.getUserId();
    if (userId.isEmpty) return false;

    final payload = <String, dynamic>{
      'userId': userId,
      'dishId': dishId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'variantId': variantId,
      'variantName': variantName ?? '',
      'variantPrice': variantPrice ?? 0,
      'addonIds': addonIds != null ? normalizeAddonIds(addonIds) : [],
      'addonDetails': addonDetails ?? [],
    };

    bool success = false;
    await ServiceCall.postToUrl(
      payload,
      SVKey.cartAddUrl,
      isToken: true,
      withSuccess: (responseObj) async {
        success = true;
      },
      failure: (err) async {
        if (kDebugMode) print('CartService.addToCart error: $err');
      },
    );
    return success;
  }

  /// PUT /api/cart/:userId/:dishId — Update quantity
  static Future<bool> updateQuantity({
    required int dishId,
    required int quantity,
    int? variantId,
    List? addonIds,
  }) async {
    final userId = Globs.getUserId();
    if (userId.isEmpty) return false;

    final body = <String, dynamic>{
      'quantity': quantity,
      'variantId': variantId,
      'addonIds': addonIds != null ? normalizeAddonIds(addonIds) : [],
    };

    bool success = false;
    await ServiceCall.put(
      SVKey.cartItemUrl(userId, dishId),
      body: body,
      isToken: true,
      withSuccess: (responseObj) async {
        success = true;
      },
      failure: (err) async {
        if (kDebugMode) print('CartService.updateQuantity error: $err');
      },
    );
    return success;
  }

  /// DELETE /api/cart/:userId/:dishId — Remove one quantity
  static Future<bool> removeOneQuantity({
    required int dishId,
    int? variantId,
    List? addonIds,
  }) async {
    final userId = Globs.getUserId();
    if (userId.isEmpty) return false;

    final body = <String, dynamic>{
      'variantId': variantId,
      'addonIds': addonIds != null ? normalizeAddonIds(addonIds) : [],
    };

    bool success = false;
    await ServiceCall.delete(
      SVKey.cartItemUrl(userId, dishId),
      body: body,
      isToken: true,
      withSuccess: (responseObj) async {
        success = true;
      },
      failure: (err) async {
        if (kDebugMode) print('CartService.removeOneQuantity error: $err');
      },
    );
    return success;
  }

  /// DELETE /api/cart/:userId — Clear entire cart
  static Future<bool> clearCart() async {
    final userId = Globs.getUserId();
    if (userId.isEmpty) return false;

    bool success = false;
    await ServiceCall.delete(
      SVKey.cartUrl(userId),
      isToken: true,
      withSuccess: (responseObj) async {
        success = true;
      },
      failure: (err) async {
        if (kDebugMode) print('CartService.clearCart error: $err');
      },
    );
    return success;
  }
}
