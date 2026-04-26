import 'package:flutter/material.dart';

enum DeliveryStatus {
  pending,
  confirmed,
  preparing,
  ready,
  riderSearching,
  riderAssigned,
  riderArrivedRestaurant,
  pickedUp,
  outForDelivery,
  delivered,
  cancelled,
  rejected,
  unknown;

  static DeliveryStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return DeliveryStatus.pending;
      case 'confirmed':
      case 'order_placed':
      case 'restaurant_accepted':
        return DeliveryStatus.confirmed;
      case 'preparing':
        return DeliveryStatus.preparing;
      case 'ready':
      case 'ready_for_pickup':
        return DeliveryStatus.ready;
      case 'rider_searching':
        return DeliveryStatus.riderSearching;
      case 'rider_assigned':
        return DeliveryStatus.riderAssigned;
      case 'rider_arrived_restaurant':
        return DeliveryStatus.riderArrivedRestaurant;
      case 'picked_up':
        return DeliveryStatus.pickedUp;
      case 'out_for_delivery':
      case 'on_the_way':
        return DeliveryStatus.outForDelivery;
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'cancelled':
        return DeliveryStatus.cancelled;
      case 'declined':
      case 'rejected':
        return DeliveryStatus.rejected;
      default:
        return DeliveryStatus.unknown;
    }
  }

  String get title {
    switch (this) {
      case DeliveryStatus.pending: return 'Order Placed';
      case DeliveryStatus.confirmed: return 'Restaurant Accepted';
      case DeliveryStatus.preparing: return 'Preparing Your Food';
      case DeliveryStatus.ready: return 'Ready for Pickup';
      case DeliveryStatus.riderSearching: return 'Searching Rider';
      case DeliveryStatus.riderAssigned: return 'Rider Assigned';
      case DeliveryStatus.riderArrivedRestaurant: return 'Rider at Restaurant';
      case DeliveryStatus.pickedUp: return 'Order Picked Up';
      case DeliveryStatus.outForDelivery: return 'On the Way';
      case DeliveryStatus.delivered: return 'Delivered';
      case DeliveryStatus.cancelled: return 'Cancelled';
      case DeliveryStatus.rejected: return 'Rejected';
      case DeliveryStatus.unknown: return 'Order Update Received';
    }
  }

  IconData get icon {
    switch (this) {
      case DeliveryStatus.pending: return Icons.receipt_long_rounded;
      case DeliveryStatus.confirmed: return Icons.thumb_up_rounded;
      case DeliveryStatus.preparing: return Icons.restaurant_menu_rounded;
      case DeliveryStatus.ready: return Icons.storefront_rounded;
      case DeliveryStatus.riderSearching: return Icons.search_rounded;
      case DeliveryStatus.riderAssigned: return Icons.person_add_rounded;
      case DeliveryStatus.riderArrivedRestaurant: return Icons.store_rounded;
      case DeliveryStatus.pickedUp: return Icons.shopping_bag_rounded;
      case DeliveryStatus.outForDelivery: return Icons.delivery_dining_rounded;
      case DeliveryStatus.delivered: return Icons.check_circle_rounded;
      case DeliveryStatus.cancelled:
      case DeliveryStatus.rejected: return Icons.cancel_rounded;
      case DeliveryStatus.unknown: return Icons.info_outline_rounded;
    }
  }
}

class TrackingTimelineItem {
  final DeliveryStatus status;
  final String title;
  final DateTime? time;
  final bool isDone;

  TrackingTimelineItem({
    required this.status,
    required this.title,
    this.time,
    required this.isDone,
  });
}

class RiderInfo {
  final int id;
  final String name;
  final String phone;
  final String vehicleType;
  final String vehicleNumber;
  final double? latitude;
  final double? longitude;

  RiderInfo({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.vehicleNumber,
    this.latitude,
    this.longitude,
  });

  factory RiderInfo.fromJson(Map<String, dynamic> json) {
    return RiderInfo(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      vehicleType: json['vehicle_type']?.toString() ?? '',
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      latitude: json['latitude'] is num ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] is num ? (json['longitude'] as num).toDouble() : null,
    );
  }
}
