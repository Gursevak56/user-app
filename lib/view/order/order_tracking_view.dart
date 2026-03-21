import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/order_tracking_service.dart';

class OrderTrackingView extends StatefulWidget {
  final String orderId;
  const OrderTrackingView({super.key, required this.orderId});

  @override
  State<OrderTrackingView> createState() => _OrderTrackingViewState();
}

class _OrderTrackingViewState extends State<OrderTrackingView> {
  GoogleMapController? _mapController;
  Timer? _pollTimer;
  bool _isLoading = true;

  // Tracking data
  String _orderStatus = 'confirmed';
  int _etaMinutes = 0;
  List<Map<String, dynamic>> _timeline = [];
  Map<String, dynamic>? _rider;
  Map<String, dynamic>? _restaurant;
  Map<String, dynamic>? _customer;

  // Map markers
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _fetchTracking();
    // Poll every 5 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchTracking();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetchTracking() async {
    final data = await OrderTrackingService.fetchTracking(widget.orderId);
    if (data == null || !mounted) return;

    setState(() {
      _isLoading = false;
      _orderStatus = data['order_status']?.toString() ?? 'confirmed';
      _etaMinutes = (data['eta_minutes'] as num?)?.toInt() ?? 0;
      _timeline = (data['status_timeline'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];
      _rider = data['rider'] as Map<String, dynamic>?;
      _restaurant = data['restaurant'] as Map<String, dynamic>?;
      _customer = data['customer'] as Map<String, dynamic>?;
    });

    _updateMapMarkers();

    // Stop polling when delivered or cancelled
    if (_orderStatus == 'delivered' || _orderStatus == 'cancelled') {
      _pollTimer?.cancel();
    }
  }

  void _updateMapMarkers() {
    final markers = <Marker>{};
    final points = <LatLng>[];

    // Restaurant marker
    if (_restaurant != null) {
      final lat = (_restaurant!['latitude'] as num?)?.toDouble();
      final lng = (_restaurant!['longitude'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        final pos = LatLng(lat, lng);
        points.add(pos);
        markers.add(Marker(
          markerId: const MarkerId('restaurant'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: _restaurant!['name']?.toString() ?? 'Restaurant',
          ),
        ));
      }
    }

    // Customer marker
    if (_customer != null) {
      final lat = (_customer!['latitude'] as num?)?.toDouble();
      final lng = (_customer!['longitude'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        final pos = LatLng(lat, lng);
        points.add(pos);
        markers.add(Marker(
          markerId: const MarkerId('customer'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ));
      }
    }

    // Rider marker
    if (_rider != null) {
      final lat = (_rider!['latitude'] as num?)?.toDouble();
      final lng = (_rider!['longitude'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        final pos = LatLng(lat, lng);
        points.add(pos);
        markers.add(Marker(
          markerId: const MarkerId('rider'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          infoWindow: InfoWindow(
            title: _rider!['name']?.toString() ?? 'Rider',
          ),
        ));
      }
    }

    // Simple polyline connecting all points
    final polylines = <Polyline>{};
    if (points.length >= 2) {
      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: TColor.primary,
        width: 4,
      ));
    }

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });

    // Fit all markers on screen
    if (_mapController != null && points.length >= 2) {
      final bounds = _boundsFromPoints(points);
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    }
  }

  LatLngBounds _boundsFromPoints(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _callRider() async {
    if (_rider == null) return;
    final phone = _rider!['phone']?.toString() ?? '';
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:+$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: TColor.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading order tracking...',
                    style: TextStyle(color: TColor.secondaryText, fontSize: 14),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Google Map — top portion
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(29.87, 77.89), // Default center (Roorkee)
                      zoom: 14,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      // Fit markers after map is ready
                      Future.delayed(const Duration(milliseconds: 500), () {
                        _updateMapMarkers();
                      });
                    },
                  ),
                ),

                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  child: _buildCircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),
                ),

                // Bottom sheet
                DraggableScrollableSheet(
                  initialChildSize: 0.48,
                  minChildSize: 0.35,
                  maxChildSize: 0.75,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: TColor.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                        children: [
                          // Handle bar
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ETA Header
                          _buildEtaHeader(),
                          const SizedBox(height: 20),

                          // Status Timeline
                          _buildStatusTimeline(),
                          const SizedBox(height: 20),

                          // Rider Info
                          if (_rider != null) _buildRiderCard(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildEtaHeader() {
    final isDelivered = _orderStatus == 'delivered';
    final isCancelled = _orderStatus == 'cancelled';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDelivered
            ? const LinearGradient(colors: [Color(0xFF43A047), Color(0xFF66BB6A)])
            : isCancelled
                ? const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFEF5350)])
                : LinearGradient(colors: TColor.primaryGradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            isDelivered
                ? Icons.check_circle
                : isCancelled
                    ? Icons.cancel
                    : Icons.delivery_dining,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDelivered
                      ? 'Delivered!'
                      : isCancelled
                          ? 'Order Cancelled'
                          : 'Arriving in $_etaMinutes min',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isDelivered
                      ? 'Your order has been delivered'
                      : isCancelled
                          ? 'This order was cancelled'
                          : 'Order #${widget.orderId}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final statusLabels = {
      'confirmed': 'Order Confirmed',
      'preparing': 'Preparing',
      'picked_up': 'Picked Up',
      'out_for_delivery': 'On the Way',
      'delivered': 'Delivered',
    };

    final statusIcons = {
      'confirmed': Icons.receipt_long,
      'preparing': Icons.restaurant,
      'picked_up': Icons.shopping_bag,
      'out_for_delivery': Icons.delivery_dining,
      'delivered': Icons.check_circle,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Status',
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_timeline.length, (i) {
          final item = _timeline[i];
          final status = item['status']?.toString() ?? '';
          final isDone = item['done'] == true;
          final isLast = i == _timeline.length - 1;
          final time = item['time']?.toString();

          String formattedTime = '';
          if (time != null && time != 'null') {
            try {
              final dt = DateTime.parse(time).toLocal();
              formattedTime =
                  '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
            } catch (_) {}
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline dots and line
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDone
                          ? TColor.primary
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcons[status] ?? Icons.circle,
                      color: isDone ? Colors.white : Colors.grey.shade400,
                      size: 16,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 32,
                      color: isDone
                          ? TColor.primary
                          : Colors.grey.shade200,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusLabels[status] ?? status,
                        style: TextStyle(
                          color: isDone
                              ? TColor.primaryText
                              : TColor.secondaryText,
                          fontSize: 14,
                          fontWeight:
                              isDone ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (formattedTime.isNotEmpty)
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      SizedBox(height: isLast ? 0 : 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildRiderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.textfield,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Rider avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TColor.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: TColor.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _rider!['name']?.toString() ?? 'Rider',
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your delivery partner',
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Call button
          InkWell(
            onTap: _callRider,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.call, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: TColor.primaryText, size: 20),
      ),
    );
  }
}
