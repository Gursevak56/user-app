import 'package:flutter/material.dart';
import 'package:food_delivery/common/cart_provider.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:provider/provider.dart';

class CheckoutView extends StatefulWidget {
  final String instructions;
  const CheckoutView({super.key, this.instructions = ''});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final List<Map<String, dynamic>> paymentMethods = [
    {"name": "Cash on Delivery", "icon": Icons.money, "value": "cash_on_delivery"},
    {"name": "UPI", "icon": Icons.account_balance, "value": "upi"},
  ];

  int selectedPaymentIndex = 0;
  bool isPlacingOrder = false;

  // Order type
  String orderType = "DELIVERY";
  final List<String> orderTypes = ["DELIVERY", "PICKUP", "TAKEAWAY"];
  int selectedOrderTypeIndex = 0;

  // Address
  final TextEditingController _streetController =
      TextEditingController(text: "");
  final TextEditingController _cityController =
      TextEditingController(text: "");
  final TextEditingController _zipController =
      TextEditingController(text: "");

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  /// Compute taxable line items total (goes as `subtotal` in API).
  double _taxableTotal(List<Map<String, dynamic>> items) {
    double total = 0;
    for (var item in items) {
      final isTaxable = item['is_taxable'] == true;
      if (isTaxable) {
        total += (item['totalPrice'] as num? ?? 0).toDouble();
      }
    }
    return total;
  }

  /// Compute non-taxable line items total (goes as `totalAmount` in API).
  double _nonTaxableTotal(List<Map<String, dynamic>> items) {
    double total = 0;
    for (var item in items) {
      final isTaxable = item['is_taxable'] == true;
      if (!isTaxable) {
        total += (item['totalPrice'] as num? ?? 0).toDouble();
      }
    }
    return total;
  }

  void _placeOrder() async {
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) return;

    // Validate address for delivery
    if (orderType == "DELIVERY") {
      if (_streetController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter delivery address'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => isPlacingOrder = true);

    final items = cart.items;
    final taxableSum = _taxableTotal(items);
    final nonTaxableSum = _nonTaxableTotal(items);

    // Build order items array
    final orderItems = <Map<String, dynamic>>[];
    for (var item in items) {
      final qty = (item['quantity'] as num? ?? 1).toInt();
      final dishId = (item['dishId'] as num? ?? 0).toInt();
      final unitPrice = (item['price'] as num? ?? 0).toDouble();
      final variantPrice =
          (item['variantPrice'] as num?)?.toDouble() ?? 0;
      final effectiveUnit = variantPrice > 0 ? variantPrice : unitPrice;

      // Calculate addon total per unit
      double addonTotal = 0;
      final addonDetails = item['addonDetails'] as List? ?? [];
      for (var a in addonDetails) {
        addonTotal += ((a as Map)['price'] as num? ?? 0).toDouble();
      }

      final lineTotal = (effectiveUnit + addonTotal) * qty;

      final orderItem = <String, dynamic>{
        'menuItemId': dishId,
        'name': item['name']?.toString() ?? '',
        'qty': qty,
        'is_taxable': item['is_taxable'] ?? false,
        'unitPrice': effectiveUnit + addonTotal,
        'totalPrice': lineTotal,
      };

      // Variants
      if (item['variantId'] != null) {
        final vid = item['variantId'];
        if (vid is num && vid.toInt() > 0) {
          orderItem['variants'] = [
            {
              'variant_id': vid.toInt(),
              'variant_name': item['variantName']?.toString() ?? '',
              'price': variantPrice,
            }
          ];
        }
      }

      // Addons
      if (addonDetails.isNotEmpty) {
        orderItem['addons'] = addonDetails.map((a) {
          final am = a as Map;
          return {
            'addon_id': (am['addon_id'] as num?)?.toInt() ?? 0,
            'addon_name': am['addon_name']?.toString() ?? '',
            'price': (am['price'] as num?)?.toDouble() ?? 0,
          };
        }).toList();
      }

      orderItems.add(orderItem);
    }

    // Build top-level payload
    final payload = <String, dynamic>{
      'restaurantId': 1, // Default restaurant ID
      'orderType': orderType,
      'customer': {
        'name': Globs.getUserId(),
        'phone': '',
        'email': '',
      },
      'deliveryAddress': {
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'zipCode': _zipController.text.trim(),
      },
      'deliveryLatitude': Globs.udValueDouble(Globs.userLat),
      'deliveryLongitude': Globs.udValueDouble(Globs.userLng),
      'paymentMethod':
          paymentMethods[selectedPaymentIndex]['value'] as String,
      'instructions': widget.instructions,
      'subtotal': taxableSum,
      'taxAmount': 0,
      'deliveryFee': 0,
      'tipAmount': 0,
      'discountAmount': 0,
      'totalAmount': nonTaxableSum,
      'cgst': 0,
      'sgst': 0,
      'items': orderItems,
    };

    await ServiceCall.postToUrl(
      payload,
      SVKey.onlineOrderUrl,
      isToken: true,
      withSuccess: (responseObj) async {
        if (!mounted) return;
        setState(() => isPlacingOrder = false);

        // Clear cart
        await cart.clearAllItems();

        if (!mounted) return;
        // Show success
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle,
                      color: Colors.green, size: 50),
                ),
                const SizedBox(height: 20),
                Text(
                  'Order Placed!',
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your order has been placed successfully.\nOrder ID: ${responseObj['data']?['orderId'] ?? 'N/A'}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: RoundButton(
                    title: 'Done',
                    onPressed: () {
                      Navigator.pop(ctx);
                      // Pop back to menu/home
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      failure: (err) async {
        if (!mounted) return;
        setState(() => isPlacingOrder = false);
        final msg = err is Map
            ? (err['message']?.toString() ?? 'Failed to place order')
            : err.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;
    final subtotal = cart.subtotal;
    final taxableSum = _taxableTotal(items);
    final cgst = taxableSum * 0.025; // 2.5%
    final sgst = taxableSum * 0.025; // 2.5%
    final grandTotal = subtotal + cgst + sgst;

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset("assets/img/btn_back.png", width: 20, height: 20),
        ),
        title: Text(
          "Checkout",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order type selector
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Type",
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(orderTypes.length, (i) {
                      final isSelected = selectedOrderTypeIndex == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedOrderTypeIndex = i;
                              orderType = orderTypes[i];
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                right: i < orderTypes.length - 1 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? TColor.primary
                                  : TColor.textfield,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              orderTypes[i],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : TColor.primaryText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Delivery address (only for DELIVERY)
            if (orderType == "DELIVERY") ...[
              Container(
                decoration: BoxDecoration(color: TColor.textfield),
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Delivery Address",
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildAddressField(
                        "Street", _streetController, "Enter street address"),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAddressField(
                              "City", _cityController, "City"),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildAddressField(
                              "Zip", _zipController, "Zip code"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            Container(
              decoration: BoxDecoration(color: TColor.textfield),
              height: 8,
            ),

            // Payment method
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "Payment Method",
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: paymentMethods.length,
                    itemBuilder: (context, index) {
                      final pm = paymentMethods[index];
                      final isSelected = selectedPaymentIndex == index;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedPaymentIndex = index),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? TColor.primary.withOpacity(0.08)
                                : TColor.textfield,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(
                                    color: TColor.primary, width: 1.5)
                                : Border.all(
                                    color: TColor.secondaryText
                                        .withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              Icon(pm['icon'] as IconData,
                                  size: 22, color: TColor.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  pm['name'] as String,
                                  style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: TColor.primary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: TColor.textfield),
              height: 8,
            ),

            // Price summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "Order Summary",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Item lines
                  ...items.map((item) {
                    final name = item['name']?.toString() ?? '';
                    final qty =
                        (item['quantity'] as num? ?? 1).toInt();
                    final tp =
                        (item['totalPrice'] as num? ?? 0).toDouble();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "$name × $qty",
                              style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "₹${tp.toStringAsFixed(0)}",
                            style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),
                  Divider(
                    color: TColor.secondaryText.withOpacity(0.3),
                    height: 1,
                  ),
                  const SizedBox(height: 8),

                  _buildPriceRow("Sub Total", subtotal),
                  if (cgst > 0) ...[
                    const SizedBox(height: 6),
                    _buildPriceRow("CGST (2.5%)", cgst),
                  ],
                  if (sgst > 0) ...[
                    const SizedBox(height: 6),
                    _buildPriceRow("SGST (2.5%)", sgst),
                  ],

                  const SizedBox(height: 12),
                  Divider(
                    color: TColor.secondaryText.withOpacity(0.3),
                    height: 1,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Grand Total",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        "₹${grandTotal.toStringAsFixed(0)}",
                        style: TextStyle(
                          color: TColor.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(color: TColor.textfield),
              height: 8,
            ),

            // Place Order button
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 20, horizontal: 25),
              child: isPlacingOrder
                  ? const Center(child: CircularProgressIndicator())
                  : RoundButton(
                      title:
                          "Place Order  •  ₹${grandTotal.toStringAsFixed(0)}",
                      onPressed: _placeOrder,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "₹${value.toStringAsFixed(0)}",
          style: TextStyle(
            color: TColor.secondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField(
      String label, TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: TColor.secondaryText, fontSize: 12),
        hintText: hint,
        hintStyle: TextStyle(color: TColor.placeholder, fontSize: 13),
        filled: true,
        fillColor: TColor.textfield,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
