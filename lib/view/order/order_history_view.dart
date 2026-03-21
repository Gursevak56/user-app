import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:food_delivery/common/cart_provider.dart';
import 'package:food_delivery/view/more/my_order_view.dart';
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
        const SnackBar(content: Text('No items to reorder')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reorder'),
        content: const Text('Clear your current cart and add these items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Reorder', style: TextStyle(color: Colors.green)),
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
    if (status.contains('delivered')) return Colors.green;
    if (status.contains('cancel') || status.contains('failed')) return Colors.red;
    return TColor.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset("assets/img/btn_back.png", width: 20, height: 20),
        ),
        title: Text(
          "Order History",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ordersArr.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 80, color: TColor.placeholder),
                      const SizedBox(height: 16),
                      Text(
                        "No past orders",
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Order #$orderId",
                                  style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatDate(date),
                              style: TextStyle(color: TColor.secondaryText, fontSize: 13),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1),
                            ),
                            ...items.take(3).map((item) {
                              final name = (item as Map)['name']?.toString() ?? 'Item';
                              final qty = (item['quantity'] ?? item['qty'] ?? 1).toString();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  "$qty x $name",
                                  style: TextStyle(color: TColor.primaryText, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                            if (items.length > 3)
                              Text(
                                "...and ${items.length - 3} more items",
                                style: TextStyle(color: TColor.secondaryText, fontSize: 12),
                              ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "₹${total.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _reorder(order),
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text("Reorder"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TColor.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
