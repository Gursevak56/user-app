import 'package:flutter/material.dart';
import 'package:food_delivery/common/cart_service.dart';

/// ChangeNotifier that holds cart state and syncs with the cart API.
class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get items => _items;
  bool get isLoading => _isLoading;

  int get itemCount {
    int count = 0;
    for (var item in _items) {
      count += (item['quantity'] as num? ?? 1).toInt();
    }
    return count;
  }

  /// Total price of all items in the cart.
  double get subtotal {
    double total = 0;
    for (var item in _items) {
      total += (item['totalPrice'] as num? ?? 0).toDouble();
    }
    return total;
  }

  /// Load cart from API.
  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    final rawItems = await CartService.getCart();
    _items = rawItems.map((e) => Map<String, dynamic>.from(e as Map)).toList();

    _isLoading = false;
    notifyListeners();
  }

  /// Add an item to cart.
  Future<bool> addItem({
    required int dishId,
    required String name,
    required double price,
    int quantity = 1,
    int? variantId,
    String? variantName,
    double? variantPrice,
    List<int>? addonIds,
    List<Map<String, dynamic>>? addonDetails,
  }) async {
    final success = await CartService.addToCart(
      dishId: dishId,
      name: name,
      price: price,
      quantity: quantity,
      variantId: variantId,
      variantName: variantName,
      variantPrice: variantPrice,
      addonIds: addonIds,
      addonDetails: addonDetails,
    );
    if (success) await loadCart();
    return success;
  }

  /// Increment quantity of an exact selection.
  Future<bool> incrementItem(Map<String, dynamic> cartItem) async {
    final dishId = (cartItem['dishId'] as num).toInt();
    final currentQty = (cartItem['quantity'] as num? ?? 1).toInt();
    final variantId = cartItem['variantId'];
    final addonIds = cartItem['addonIds'] as List?;

    final success = await CartService.updateQuantity(
      dishId: dishId,
      quantity: currentQty + 1,
      variantId: variantId is num ? variantId.toInt() : null,
      addonIds: addonIds,
    );
    if (success) await loadCart();
    return success;
  }

  /// Decrement quantity by 1 (removes row if qty becomes 0).
  Future<bool> decrementItem(Map<String, dynamic> cartItem) async {
    final dishId = (cartItem['dishId'] as num).toInt();
    final variantId = cartItem['variantId'];
    final addonIds = cartItem['addonIds'] as List?;

    final success = await CartService.removeOneQuantity(
      dishId: dishId,
      variantId: variantId is num ? variantId.toInt() : null,
      addonIds: addonIds,
    );
    if (success) await loadCart();
    return success;
  }

  /// Set exact quantity for a cart item (0 = remove).
  Future<bool> setQuantity(Map<String, dynamic> cartItem, int newQty) async {
    final dishId = (cartItem['dishId'] as num).toInt();
    final variantId = cartItem['variantId'];
    final addonIds = cartItem['addonIds'] as List?;

    final success = await CartService.updateQuantity(
      dishId: dishId,
      quantity: newQty,
      variantId: variantId is num ? variantId.toInt() : null,
      addonIds: addonIds,
    );
    if (success) await loadCart();
    return success;
  }

  /// Clear the entire cart.
  Future<bool> clearAllItems() async {
    final success = await CartService.clearCart();
    if (success) {
      _items = [];
      notifyListeners();
    }
    return success;
  }
}
