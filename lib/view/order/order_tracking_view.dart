import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/order_tracking_service.dart';
import 'package:food_delivery/common/order_tracking_socket.dart';
import 'package:food_delivery/models/order_tracking_model.dart';

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
  bool _isSocketConnected = false;
  OrderTrackingSocket? _socket;

  DeliveryStatus _orderStatus = DeliveryStatus.pending;
  int _etaMinutes = 0;
  List<TrackingTimelineItem> _timeline = [];
  RiderInfo? _rider;
  Map<String, dynamic>? _restaurant;
  Map<String, dynamic>? _customer;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initTracking();
  }

  void _initTracking() async {
    await _fetchTrackingData();
    _connectSocket();
  }

  Future<void> _fetchTrackingData() async {
    final data = await OrderTrackingService.fetchTracking(widget.orderId);
    if (data == null || !mounted) {
      setState(() => _isLoading = false);
      return;
    }
    _updateStateFromData(data);
  }

  void _connectSocket() {
    _socket = OrderTrackingSocket(
      orderId: widget.orderId,
      onConnected: () {
        if (mounted) setState(() {
          _isSocketConnected = true;
          _pollTimer?.cancel();
        });
      },
      onDisconnected: () {
        if (mounted) setState(() {
          _isSocketConnected = false;
          _startPolling();
        });
      },
      onMessage: (data) {
        if (mounted) {
           if (data['type'] == 'ORDER_STATUS_UPDATED' || data['type'] == 'RIDER_LOCATION_UPDATED' || data['type'] == 'RIDER_ASSIGNED') {
             _fetchTrackingData();
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text(data['message']?.toString() ?? 'Order updated'),
                 duration: const Duration(seconds: 2),
                 backgroundColor: TColor.primary,
               )
             );
           } else {
             _fetchTrackingData();
           }
        }
      },
    );
    _socket?.connect();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!_isSocketConnected) {
        _fetchTrackingData();
      }
    });
  }

  void _updateStateFromData(Map<String, dynamic> data) {
    setState(() {
      _isLoading = false;
      
      final statusStr = data['order_status']?.toString() ?? 'pending';
      _orderStatus = DeliveryStatus.fromString(statusStr);
      _etaMinutes = (data['eta_minutes'] as num?)?.toInt() ?? 0;
      
      _timeline.clear();
      final tlList = data['status_timeline'] as List? ?? [];
      for (var item in tlList) {
        final m = item as Map;
        final s = DeliveryStatus.fromString(m['status']?.toString() ?? '');
        DateTime? time;
        if (m['time'] != null && m['time'] != 'null') {
           time = DateTime.tryParse(m['time'].toString())?.toLocal();
        }
        _timeline.add(TrackingTimelineItem(
          status: s,
          title: s.title,
          time: time,
          isDone: m['done'] == true,
        ));
      }

      if (data['rider'] != null) {
        _rider = RiderInfo.fromJson(data['rider'] as Map<String, dynamic>);
      }
      _restaurant = data['restaurant'] as Map<String, dynamic>?;
      _customer = data['customer'] as Map<String, dynamic>?;
    });

    _updateMapMarkers();

    if (_orderStatus == DeliveryStatus.delivered || _orderStatus == DeliveryStatus.cancelled || _orderStatus == DeliveryStatus.rejected) {
      _pollTimer?.cancel();
      _socket?.dispose();
    }
  }

  void _updateMapMarkers() {
    final markers = <Marker>{};
    final points = <LatLng>[];

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

    if (_rider != null && _rider!.latitude != null && _rider!.longitude != null) {
      final pos = LatLng(_rider!.latitude!, _rider!.longitude!);
      points.add(pos);
      markers.add(Marker(
        markerId: const MarkerId('rider'),
        position: pos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(
          title: _rider!.name,
        ),
      ));
    }

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
    final phone = _rider!.phone;
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:+$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _socket?.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: TColor.primary, strokeWidth: 2.5),
                  const SizedBox(height: 16),
                  Text(
                    'Loading order tracking...',
                    style: GoogleFonts.plusJakartaSans(color: TColor.secondaryText, fontSize: 14),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Google Map
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(29.87, 77.89),
                      zoom: 14,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      Future.delayed(const Duration(milliseconds: 500), () {
                        _updateMapMarkers();
                      });
                    },
                  ),
                ),

                // Back button & Socket Status
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCircleButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      if (!_isSocketConnected && (_orderStatus != DeliveryStatus.delivered && _orderStatus != DeliveryStatus.cancelled && _orderStatus != DeliveryStatus.rejected))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text("Reconnecting...", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        )
                    ],
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
                          top: Radius.circular(28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 24,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                        children: [
                          // Handle bar
                          Center(
                            child: Container(
                              width: 44,
                              height: 5,
                              decoration: BoxDecoration(
                                color: TColor.border,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ETA Header
                          _buildEtaHeader(),
                          const SizedBox(height: 24),

                          // Status Timeline
                          _buildStatusTimeline(),
                          const SizedBox(height: 24),

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
    final isDelivered = _orderStatus == DeliveryStatus.delivered;
    final isCancelled = _orderStatus == DeliveryStatus.cancelled || _orderStatus == DeliveryStatus.rejected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: isDelivered
            ? LinearGradient(colors: [TColor.success, TColor.success.withOpacity(0.8)])
            : isCancelled
                ? LinearGradient(colors: [TColor.error, TColor.error.withOpacity(0.8)])
                : TColor.premiumGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDelivered ? TColor.success : isCancelled ? TColor.error : TColor.primary).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _orderStatus.icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDelivered
                      ? 'Delivered! 🎉'
                      : isCancelled
                          ? 'Order Cancelled'
                          : 'Arriving in $_etaMinutes min',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDelivered
                      ? 'Your order has been delivered'
                      : isCancelled
                          ? 'This order was cancelled'
                          : 'Order #${widget.orderId}',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.75),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Status',
          style: GoogleFonts.plusJakartaSans(
            color: TColor.primaryText,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_timeline.length, (i) {
          final item = _timeline[i];
          final isDone = item.isDone;
          final isLast = i == _timeline.length - 1;
          final time = item.time;

          String formattedTime = '';
          if (time != null) {
            formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline dots and line
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDone ? TColor.primary : TColor.textfield,
                      shape: BoxShape.circle,
                      boxShadow: isDone
                          ? [
                              BoxShadow(
                                color: TColor.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      item.status.icon,
                      color: isDone ? Colors.white : TColor.placeholder,
                      size: 18,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2.5,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDone ? TColor.primary : TColor.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          color: isDone ? TColor.primaryText : TColor.secondaryText,
                          fontSize: 14,
                          fontWeight: isDone ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                      if (formattedTime.isNotEmpty)
                        Text(
                          formattedTime,
                          style: GoogleFonts.plusJakartaSans(
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: TColor.textfield,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: TColor.premiumGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _rider!.name,
                  style: GoogleFonts.plusJakartaSans(
                    color: TColor.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _rider!.vehicleType.isNotEmpty ? '${_rider!.vehicleType} • ${_rider!.vehicleNumber}' : 'Your delivery partner',
                  style: GoogleFonts.plusJakartaSans(
                    color: TColor.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: TColor.success,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: _callRider,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: const Icon(Icons.call_rounded, color: Colors.white, size: 22),
              ),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, color: TColor.primaryText, size: 20),
        ),
      ),
    );
  }
}
