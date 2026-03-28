import 'package:flutter/material.dart';
import 'package:food_delivery/common/cart_provider.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../checkout/checkout_view.dart';

class MyOrderView extends StatefulWidget {
  const MyOrderView({super.key});

  @override
  State<MyOrderView> createState() => _MyOrderViewState();
}

class _MyOrderViewState extends State<MyOrderView> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();
  bool _couponApplied = false;
  String _couponMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    // Placeholder coupon logic — hook into backend later
    setState(() {
      _couponApplied = false;
      _couponMessage = 'Invalid coupon code';
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;
    final subtotal = cart.subtotal;
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
          "My Cart",
          style: GoogleFonts.plusJakartaSans(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Text('Clear Cart',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700)),
                    content: Text('Remove all items from your cart?',
                        style: GoogleFonts.plusJakartaSans()),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text('Cancel',
                              style:
                                  TextStyle(color: TColor.secondaryText))),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('Clear',
                              style: TextStyle(color: TColor.primary))),
                    ],
                  ),
                );
                if (confirmed == true) cart.clearAllItems();
              },
              child: Text(
                "Clear",
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: cart.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: TColor.primary,
                strokeWidth: 2.5,
              ),
            )
          : items.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            // ─── Items count header ───
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 4),
                              child: Text(
                                "${items.length} ${items.length == 1 ? 'item' : 'items'} in cart",
                                style: GoogleFonts.plusJakartaSans(
                                  color: TColor.secondaryText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

                            // ─── Cart items ───
                            ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return _buildCartItem(item, cart);
                              },
                            ),

                            const SizedBox(height: 16),

                            // ─── Coupon / Promo Code ───
                            _buildCouponSection(),

                            const SizedBox(height: 12),

                            // ─── Delivery instructions ───
                            _buildNotesSection(),

                            const SizedBox(height: 12),

                            // ─── Savings callout ───
                            _buildSavingsCard(subtotal),

                            const SizedBox(height: 12),

                            // ─── Billing summary ───
                            _buildBillingSummary(subtotal),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // ─── Sticky CTA ───
                    _buildStickyCheckoutBar(subtotal, bottomPad),
                  ],
                ),
    );
  }

  // ─── Empty State ───
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: TColor.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_bag_outlined,
                size: 56, color: TColor.primary),
          ),
          const SizedBox(height: 24),
          Text(
            "Your cart is empty",
            style: GoogleFonts.plusJakartaSans(
              color: TColor.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add items from a restaurant to get started",
            style: GoogleFonts.plusJakartaSans(
              color: TColor.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Cart Item ───
  Widget _buildCartItem(Map<String, dynamic> item, CartProvider cart) {
    final name = item['name']?.toString() ?? '';
    final qty = (item['quantity'] as num? ?? 1).toInt();
    final totalPrice = (item['totalPrice'] as num? ?? 0).toDouble();
    final variantName = item['variantName']?.toString() ?? '';
    final addonDetails = item['addonDetails'] as List? ?? [];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    color: TColor.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (variantName.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    variantName,
                    style: GoogleFonts.plusJakartaSans(
                      color: TColor.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (addonDetails.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    addonDetails
                        .map((a) =>
                            '+ ${(a as Map)['addon_name'] ?? a['addonName'] ?? ''}')
                        .join(', '),
                    style: GoogleFonts.plusJakartaSans(
                      color: TColor.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  "₹${totalPrice.toStringAsFixed(0)}",
                  style: GoogleFonts.plusJakartaSans(
                    color: TColor.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Quantity controls
          Container(
            decoration: BoxDecoration(
              color: TColor.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => cart.decrementItem(item),
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      qty > 1
                          ? Icons.remove_rounded
                          : Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Container(
                    key: ValueKey(qty),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      qty.toString(),
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => cart.incrementItem(item),
                  borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(10)),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.add_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Coupon Section ───
  Widget _buildCouponSection() {
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
              Icon(Icons.local_offer_rounded,
                  color: TColor.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                "Apply Coupon",
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: "Enter coupon code",
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: TColor.placeholder,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                    filled: true,
                    fillColor: TColor.textfield,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: TColor.primary,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: _applyCoupon,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Text(
                      "Apply",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_couponMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _couponMessage,
              style: GoogleFonts.plusJakartaSans(
                color: _couponApplied ? TColor.success : TColor.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Notes Section ───
  Widget _buildNotesSection() {
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
              Icon(Icons.edit_note_rounded,
                  color: TColor.secondaryText, size: 20),
              const SizedBox(width: 8),
              Text(
                "Delivery Instructions",
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
            decoration: InputDecoration(
              hintText: "Add notes (e.g. no onions, extra spicy)",
              hintStyle: GoogleFonts.plusJakartaSans(
                color: TColor.placeholder,
                fontSize: 13,
              ),
              filled: true,
              fillColor: TColor.textfield,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // ─── Savings Callout ───
  Widget _buildSavingsCard(double subtotal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.success.withOpacity(0.08),
            TColor.success.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColor.success.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TColor.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.savings_rounded,
                color: TColor.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Free delivery on this order!",
                  style: GoogleFonts.plusJakartaSans(
                    color: TColor.success,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "You're saving ₹40 on delivery",
                  style: GoogleFonts.plusJakartaSans(
                    color: TColor.success.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded,
              color: TColor.success, size: 22),
        ],
      ),
    );
  }

  // ─── Billing Summary ───
  Widget _buildBillingSummary(double subtotal) {
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
          Text(
            "Bill Details",
            style: GoogleFonts.plusJakartaSans(
              color: TColor.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
              "Sub Total", "₹${subtotal.toStringAsFixed(0)}"),
          const SizedBox(height: 8),
          _buildSummaryRow("Delivery Fee", "FREE",
              valueColor: TColor.success),
          const SizedBox(height: 8),
          _buildSummaryRow("Taxes", "Calculated at checkout"),
          const SizedBox(height: 14),
          Divider(color: TColor.border, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: GoogleFonts.plusJakartaSans(
                  color: TColor.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                "₹${subtotal.toStringAsFixed(0)}",
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

  // ─── Sticky Checkout Bar ───
  Widget _buildStickyCheckoutBar(double subtotal, double bottomPad) {
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
      child: RoundButton(
        title: "Checkout  •  ₹${subtotal.toStringAsFixed(0)}",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckoutView(
                instructions: _notesController.text,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
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
          value,
          style: GoogleFonts.plusJakartaSans(
            color: valueColor ?? TColor.primaryText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
