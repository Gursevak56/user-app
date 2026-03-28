import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:food_delivery/common/cart_provider.dart';
import 'package:food_delivery/view/more/my_order_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({super.key});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  List ordersArr = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    await ServiceCall.get(
      "${SVKey.restaurantBaseUrl}/api/orders/history",
      isToken: true,
      withSuccess: (responseObj) async {
        if (!mounted) return;
        if (responseObj['status'] == 'success') {
          setState(() {
            var data = responseObj['data'];
            if (data is Map) {
              ordersArr = data['orders'] as List? ?? data['history'] as List? ?? [];
            } else if (data is List) {
              ordersArr = data;
            } else {
              ordersArr = [];
            }
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      },
      failure: (err) async {
        if (!mounted) return;
        setState(() => isLoading = false);
      },
    );
  }

  Future<void> _reorder(Map order) async {
    final items = order['items'] as List? ?? [];
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No items to reorder'),
          backgroundColor: TColor.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reorder',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text('Clear your current cart and add these items?',
            style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: TColor.secondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Yes, Reorder',
                style: TextStyle(color: TColor.success, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    Globs.showHUD();
    final cart = context.read<CartProvider>();
    await cart.clearAllItems();

    for (var item in items) {
      final itemMap = item as Map? ?? {};
      final qty = (itemMap['quantity'] as num? ?? itemMap['qty'] as num? ?? 1).toInt();
      final dishId = (itemMap['menuItemId'] as num? ?? itemMap['dishId'] as num? ?? itemMap['dish_id'] as num? ?? 0).toInt();
      final price = (itemMap['unitPrice'] as num? ?? itemMap['price'] as num? ?? 0).toDouble();
      final name = itemMap['name']?.toString() ?? 'Item';
      
      if (dishId > 0) {
        await cart.addItem(
          dishId: dishId,
          name: name,
          price: price,
          quantity: qty,
        );
      }
    }
    Globs.hideHUD();

    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrderView()));
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy, h:mm a').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  Color _getStatusColor(String status) {
    status = status.toLowerCase();
    if (status.contains('delivered')) return TColor.success;
    if (status.contains('cancel') || status.contains('failed')) return TColor.error;
    return TColor.primary;
  }

  IconData _getStatusIcon(String status) {
    status = status.toLowerCase();
    if (status.contains('delivered')) return Icons.check_circle_rounded;
    if (status.contains('cancel') || status.contains('failed')) return Icons.cancel_rounded;
    if (status.contains('prepar')) return Icons.restaurant_rounded;
    return Icons.access_time_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: Text(
          "Order History",
          style: GoogleFonts.plusJakartaSans(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: TColor.primary,
                strokeWidth: 2.5,
              ),
            )
          : ordersArr.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: TColor.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.receipt_long_rounded,
                            size: 48, color: TColor.primary),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "No past orders",
                        style: GoogleFonts.plusJakartaSans(
                          color: TColor.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Your order history will appear here",
                        style: GoogleFonts.plusJakartaSans(
                          color: TColor.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ordersArr.length,
                  itemBuilder: (context, index) {
                    final order = ordersArr[index] as Map? ?? {};
                    final orderId = order['id']?.toString() ?? order['order_id']?.toString() ?? 'Unknown';
                    final date = order['created_at']?.toString() ?? order['date']?.toString();
                    final status = order['status']?.toString() ?? 'Unknown';
                    final total = (order['total_amount'] as num? ?? order['total'] as num? ?? 0).toDouble();
                    final items = order['items'] as List? ?? [];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: TColor.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _getStatusIcon(status),
                                      size: 18,
                                      color: _getStatusColor(status),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Order #$orderId",
                                      style: GoogleFonts.plusJakartaSans(
                                        color: TColor.primaryText,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: GoogleFonts.plusJakartaSans(
                                      color: _getStatusColor(status),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatDate(date),
                              style: GoogleFonts.plusJakartaSans(
                                color: TColor.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: TColor.border, height: 1),
                            ),
                            ...items.take(3).map((item) {
                              final name = (item as Map)['name']?.toString() ?? 'Item';
                              final qty = (item['quantity'] ?? item['qty'] ?? 1).toString();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  "$qty × $name",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: TColor.primaryText,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                            if (items.length > 3)
                              Text(
                                "...and ${items.length - 3} more items",
                                style: GoogleFonts.plusJakartaSans(
                                  color: TColor.secondaryText,
                                  fontSize: 12,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: TColor.border, height: 1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "₹${total.toStringAsFixed(0)}",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: TColor.primaryText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Material(
                                  color: TColor.primary,
                                  borderRadius: BorderRadius.circular(10),
                                  child: InkWell(
                                    onTap: () => _reorder(order),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 10),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.refresh_rounded,
                                              size: 16, color: Colors.white),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Reorder",
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
