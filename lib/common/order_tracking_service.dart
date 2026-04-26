import 'package:flutter/foundation.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/service_call.dart';

class OrderTrackingService {
  /// Fetch live tracking data for an order.
  static Future<Map<String, dynamic>?> fetchTracking(String orderId) async {
    Map<String, dynamic>? result;

    await ServiceCall.get(
      "${SVKey.restaurantBaseUrl}/api/orders/$orderId",
      isToken: true,
      withSuccess: (responseObj) async {
        if (responseObj[KKey.statusCode] == 200) {
          result = responseObj['data'] as Map<String, dynamic>?;
        }
      },
      failure: (err) async {
        if (kDebugMode) print('OrderTrackingService.fetchTracking error: $err');
      },
    );

    return result;
  }
}
