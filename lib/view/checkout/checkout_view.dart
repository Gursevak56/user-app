import 'package:flutter/material.dart';
import 'package:food_delivery/common/cart_provider.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:food_delivery/common_widget/auth_bottom_sheet.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/view/more/change_address_view.dart';
import 'package:food_delivery/view/order/order_tracking_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CheckoutView extends StatefulWidget {
  final String instructions;
  const CheckoutView({super.key, this.instructions = ''});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final List<Map<String, dynamic>> paymentMethods = [
    {"name": "Cash on Delivery", "icon": Icons.payments_rounded, "value": "cash_on_delivery"},
    {"name": "UPI", "icon": Icons.account_balance_rounded, "value": "upi"},
  ];

  int selectedPaymentIndex = 0;
  bool isPlacingOrder = false;

  // Order type
  String orderType = "DELIVERY";
  final List<String> orderTypes = ["DELIVERY", "PICKUP", "TAKEAWAY"];
  final List<IconData> orderTypeIcons = [
    Icons.delivery_dining_rounded,
    Icons.storefront_rounded,
    Icons.takeout_dining_rounded,
  ];
  int selectedOrderTypeIndex = 0;

  // Address
  String _addressLabel = '';
  final TextEditingController _streetController = TextEditingController(text: "");
  final TextEditingController _cityController = TextEditingController(text: "");
  final TextEditingController _zipController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    final address = Globs.udValueString(Globs.userAddress);
    if (address.isNotEmpty) {
      _streetController.text = address;
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  double _taxableTotal(List<Map<String, dynamic>> items) {
    double total = 0;
    for (var item in items) {
      if (item['is_taxable'] == true) {
        total += (item['totalPrice'] as num? ?? 0).toDouble();
      }
    }
    return total;
  }

  double _nonTaxableTotal(List<Map<String, dynamic>> items) {
    double total = 0;
    for (var item in items) {
      if (item['is_taxable'] != true) {
        total += (item['totalPrice'] as num? ?? 0).toDouble();
      }
    }
    return total;
  }

  void _placeOrder() async {
    if (!Globs.udValueBool(Globs.userLogin)) {
      final loggedIn = await AuthBottomSheet.show(context);
      if (!loggedIn || !mounted) return;
    }

    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) return;

    if (orderType == "DELIVERY") {
      if (_streetController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter delivery address'),
            backgroundColor: TColor.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
    }

    setState(() => isPlacingOrder = true);

    final items = cart.items;
    final taxableSum = _taxableTotal(items);
    final nonTaxableSum = _nonTaxableTotal(items);

    final orderItems = <Map<String, dynamic>>[];
    for (var item in items) {
      final qty = (item['quantity'] as num? ?? 1).toInt();
      final dishId = (item['dishId'] as num? ?? 0).toInt();
      final unitPrice = (item['price'] as num? ?? 0).toDouble();
      final variantPrice = (item['variantPrice'] as num?)?.toDouble() ?? 0;
      final effectiveUnit = variantPrice > 0 ? variantPrice : unitPrice;

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

    final payload = <String, dynamic>{
      'restaurantId': 1,
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
      'paymentMethod': paymentMethods[selectedPaymentIndex]['value'] as String,
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
        await cart.clearAllItems();
        if (!mounted) return;

        final orderId = responseObj['data']?['orderId']?.toString() ?? '';
        if (orderId.isNotEmpty) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => OrderTrackingView(orderId: orderId)),
            (route) => route.isFirst,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Order placed successfully!'),
                ],
              ),
              backgroundColor: TColor.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        }
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
            backgroundColor: TColor.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    final cgst = taxableSum * 0.025;
    final sgst = taxableSum * 0.025;
    final grandTotal = subtotal + cgst + sgst;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: Text(
          "Checkout",
          style: GoogleFonts.plusJakartaSans(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          // ─── Scrollable content ───
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // ─── Order Type Selector ───
                  _buildSectionCard(
                    icon: Icons.room_service_rounded,
                    title: "Order Type",
                    child: Row(
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
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              margin: EdgeInsets.only(
                                  right: i < orderTypes.length - 1 ? 8 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? TColor.primary
                                    : TColor.textfield,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? null
                                    : Border.all(color: TColor.border),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    orderTypeIcons[i],
                                    size: 22,
                                    color: isSelected
                                        ? Colors.white
                                        : TColor.secondaryText,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    orderTypes[i],
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isSelected
                                          ? Colors.white
                                          : TColor.primaryText,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ─── Delivery Address ───
                  if (orderType == "DELIVERY") ...[
                    const SizedBox(height: 12),
                    _buildAddressSection(),
                  ],

                  // ─── Payment Method ───
                  const SizedBox(height: 12),
                  _buildPaymentSection(),

                  // ─── Savings Callout ───
                  const SizedBox(height: 12),
                  _buildSavingsCallout(),

                  // ─── Order Summary ───
                  const SizedBox(height: 12),
                  _buildOrderSummary(items, subtotal, cgst, sgst, grandTotal),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ─── Sticky CTA ───
          _buildStickyOrderBar(grandTotal, bottomPad),
        ],
      ),
    );
  }

  // ─── Reusable Section Card ───
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: TColor.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (trailing != null) ...[const Spacer(), trailing],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ─── Address Section ───
  Widget _buildAddressSection() {
    return _buildSectionCard(
      icon: Icons.location_on_rounded,
      title: _addressLabel.isNotEmpty
          ? "Delivery ($_addressLabel)"
          : "Delivery Address",
      trailing: TextButton(
        onPressed: () async {
          if (!Globs.udValueBool(Globs.userLogin)) {
            final loggedIn = await AuthBottomSheet.show(context);
            if (!loggedIn || !mounted) return;
          }
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ChangeAddressView()),
          );
          if (result != null && result is Map) {
            setState(() {
              _addressLabel = result['label']?.toString() ?? '';
              _streetController.text = result['street']?.toString() ?? '';
              _cityController.text = result['city']?.toString() ?? '';
              _zipController.text = result['zipCode']?.toString() ?? '';
            });
          }
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          "Saved",
          style: GoogleFonts.plusJakartaSans(
            color: TColor.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildAddressField("Street", _streetController, "Enter street address"),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _buildAddressField("City", _cityController, "City")),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildAddressField("Zip", _zipController, "Zip code")),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Payment Section ───
  Widget _buildPaymentSection() {
    return _buildSectionCard(
      icon: Icons.credit_card_rounded,
      title: "Payment Method",
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: paymentMethods.length,
        itemBuilder: (context, index) {
          final pm = paymentMethods[index];
          final isSelected = selectedPaymentIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedPaymentIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? TColor.primaryLight : TColor.textfield,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: TColor.primary, width: 1.5)
                    : Border.all(color: TColor.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TColor.primary.withOpacity(0.1)
                          : TColor.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(pm['icon'] as IconData,
                        size: 20, color: TColor.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      pm['name'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        color: TColor.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: TColor.primary,
                    size: 22,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Savings Callout ───
  Widget _buildSavingsCallout() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.primary.withOpacity(0.06),
            TColor.primary.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColor.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.verified_rounded,
                color: TColor.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Secure & Safe Checkout",
                  style: GoogleFonts.plusJakartaSans(
                    color: TColor.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Your payment details are always encrypted",
                  style: GoogleFonts.plusJakartaSans(
                    color: TColor.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.shield_rounded,
              color: TColor.primary.withOpacity(0.4), size: 22),
        ],
      ),
    );
  }

  // ─── Order Summary ───
  Widget _buildOrderSummary(List<Map<String, dynamic>> items, double subtotal,
      double cgst, double sgst, double grandTotal) {
    return _buildSectionCard(
      icon: Icons.receipt_long_rounded,
      title: "Order Summary",
      child: Column(
        children: [
          // Item lines
          ...items.map((item) {
            final name = item['name']?.toString() ?? '';
            final qty = (item['quantity'] as num? ?? 1).toInt();
            final tp = (item['totalPrice'] as num? ?? 0).toDouble();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "$name × $qty",
                      style: GoogleFonts.plusJakartaSans(
                        color: TColor.secondaryText,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "₹${tp.toStringAsFixed(0)}",
                    style: GoogleFonts.plusJakartaSans(
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
          Divider(color: TColor.border, height: 1),
          const SizedBox(height: 10),

          _buildPriceRow("Sub Total", subtotal),
          if (cgst > 0) ...[
            const SizedBox(height: 6),
            _buildPriceRow("CGST (2.5%)", cgst),
          ],
          if (sgst > 0) ...[
            const SizedBox(height: 6),
            _buildPriceRow("SGST (2.5%)", sgst),
          ],
          const SizedBox(height: 6),
          _buildPriceRow("Delivery Fee", 0, isFree: true),

          const SizedBox(height: 12),
          Divider(color: TColor.border, height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Grand Total",
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                "₹${grandTotal.toStringAsFixed(0)}",
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Sticky Place Order ───
  Widget _buildStickyOrderBar(double grandTotal, double bottomPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      decoration: BoxDecoration(
        color: TColor.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: isPlacingOrder
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(
                  color: TColor.primary,
                  strokeWidth: 2.5,
                ),
              ),
            )
          : RoundButton(
              title: "Place Order  •  ₹${grandTotal.toStringAsFixed(0)}",
              onPressed: _placeOrder,
            ),
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: TColor.secondaryText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          isFree ? "FREE" : "₹${value.toStringAsFixed(0)}",
          style: GoogleFonts.plusJakartaSans(
            color: isFree ? TColor.success : TColor.primaryText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField(
      String label, TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: GoogleFonts.plusJakartaSans(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(
            color: TColor.secondaryText, fontSize: 12),
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
            color: TColor.placeholder, fontSize: 13),
        filled: true,
        fillColor: TColor.textfield,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
