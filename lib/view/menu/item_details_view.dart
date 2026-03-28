import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/common/cart_provider.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common_widget/auth_bottom_sheet.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../common/color_extension.dart';
import '../more/my_order_view.dart';

class ItemDetailsView extends StatefulWidget {
  final Map mObj;
  final int restaurantId;
  const ItemDetailsView({
    super.key,
    required this.mObj,
    this.restaurantId = 0,
  });

  @override
  State<ItemDetailsView> createState() => _ItemDetailsViewState();
}

class _ItemDetailsViewState extends State<ItemDetailsView> {
  int qty = 1;
  bool isFav = false;

  // Variant selection
  int? selectedVariantIndex;
  List variants = [];

  // Addon selection
  List addons = [];
  Set<int> selectedAddonIndices = {};

  @override
  void initState() {
    super.initState();
    variants = widget.mObj['variants'] as List? ?? [];
    addons = widget.mObj['addons'] as List? ?? [];

    // Auto-select first variant if available
    if (variants.isNotEmpty) {
      selectedVariantIndex = 0;
    }
  }

  double get _basePrice {
    if (selectedVariantIndex != null && variants.isNotEmpty) {
      return (variants[selectedVariantIndex!]['price'] as num?)?.toDouble() ??
          (widget.mObj['price'] as num?)?.toDouble() ??
          0;
    }
    return (widget.mObj['price'] as num?)?.toDouble() ?? 0;
  }

  double get _addonsTotal {
    double total = 0;
    for (var i in selectedAddonIndices) {
      total += (addons[i]['price'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  double get _unitPrice => _basePrice + _addonsTotal;
  double get _totalPrice => _unitPrice * qty;

  String get _itemName => widget.mObj['name']?.toString() ?? 'Menu Item';
  String? get _imageUrl => widget.mObj['image_url']?.toString();
  String get _description =>
      widget.mObj['description']?.toString() ??
      'Delicious food prepared with fresh ingredients.';
  bool get _hasVariants => widget.mObj['has_variants'] == true;
  bool get _isVeg => widget.mObj['is_vegetarian'] == true;

  void _addToCart() async {
    // Auth wall: show login bottom sheet if not logged in
    if (!Globs.udValueBool(Globs.userLogin)) {
      final loggedIn = await AuthBottomSheet.show(context);
      if (!loggedIn || !mounted) return;
    }

    final cart = context.read<CartProvider>();
    final dishId = (widget.mObj['id'] as num?)?.toInt() ?? 0;
    if (dishId == 0) return;

    // Variant info
    int? variantId;
    String? variantName;
    double? variantPrice;
    if (selectedVariantIndex != null && variants.isNotEmpty) {
      final v = variants[selectedVariantIndex!] as Map;
      variantId = (v['variant_id'] as num?)?.toInt();
      variantName = v['name']?.toString();
      variantPrice = (v['price'] as num?)?.toDouble();
    }

    // Addon info
    List<int>? addonIds;
    List<Map<String, dynamic>>? addonDetails;
    if (selectedAddonIndices.isNotEmpty) {
      addonIds = [];
      addonDetails = [];
      for (var i in selectedAddonIndices) {
        final a = addons[i] as Map;
        addonIds.add((a['addon_id'] as num).toInt());
        addonDetails.add({
          'addon_id': (a['addon_id'] as num).toInt(),
          'addon_name': a['addon_name']?.toString() ?? '',
          'price': (a['price'] as num?)?.toDouble() ?? 0,
        });
      }
    }

    final success = await cart.addItem(
      dishId: dishId,
      name: _itemName,
      price: _basePrice,
      quantity: qty,
      variantId: variantId,
      variantName: variantName,
      variantPrice: variantPrice,
      addonIds: addonIds,
      addonDetails: addonDetails,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('$_itemName added to cart'),
            ],
          ),
          backgroundColor: TColor.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to add to cart'),
          backgroundColor: TColor.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final cartCount = context.watch<CartProvider>().itemCount;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: TColor.white,
      body: Column(
        children: [
          // ─── Scrollable hero + content ───
          Expanded(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Hero image
                if (_imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: _imageUrl!,
                    width: media.width,
                    height: media.width * 0.75,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: media.width,
                      height: media.width * 0.75,
                      color: TColor.primaryLight,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: TColor.primary,
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: media.width,
                      height: media.width * 0.75,
                      color: TColor.primaryLight,
                      child: Icon(Icons.restaurant_rounded,
                          size: 60, color: TColor.primary.withOpacity(0.3)),
                    ),
                  )
                else
                  Container(
                    width: media.width,
                    height: media.width * 0.75,
                    color: TColor.primaryLight,
                    child: Icon(Icons.restaurant_rounded,
                        size: 60, color: TColor.primary.withOpacity(0.3)),
                  ),

                // Gradient overlay
                Container(
                  width: media.width,
                  height: media.width * 0.75,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black45, Colors.transparent, Colors.black26],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // Scrollable content
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: media.width * 0.65),
                      Container(
                        decoration: BoxDecoration(
                          color: TColor.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Drag handle
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(top: 12),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: TColor.border,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Name + Veg badge
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _isVeg ? TColor.success : TColor.primary,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _isVeg ? TColor.success : TColor.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _itemName,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: TColor.primaryText,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Price
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                '₹${_unitPrice.toStringAsFixed(0)}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: TColor.primary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Description
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                _description,
                                style: GoogleFonts.plusJakartaSans(
                                  color: TColor.secondaryText,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),

                            // Variant selector
                            if (_hasVariants && variants.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Divider(color: TColor.border),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  children: [
                                    Icon(Icons.tune_rounded, color: TColor.primary, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Select Variant',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: TColor.primaryText,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...List.generate(variants.length, (i) {
                                final v = variants[i] as Map;
                                final vName = v['name']?.toString() ?? '';
                                final vPrice = (v['price'] as num?)?.toDouble() ?? 0;
                                final isSelected = selectedVariantIndex == i;
                                return InkWell(
                                  onTap: () => setState(() => selectedVariantIndex = i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isSelected ? TColor.primaryLight : TColor.textfield,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isSelected
                                          ? Border.all(color: TColor.primary, width: 1.5)
                                          : Border.all(color: TColor.border, width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.radio_button_checked_rounded
                                              : Icons.radio_button_off_rounded,
                                          color: TColor.primary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            vName,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: TColor.primaryText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '₹${vPrice.toStringAsFixed(0)}',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: TColor.primaryText,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],

                            // Addon selector
                            if (addons.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Divider(color: TColor.border),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  children: [
                                    Icon(Icons.add_circle_outline_rounded, color: TColor.warning, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Add-ons',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: TColor.primaryText,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: TColor.secondaryText.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "Optional",
                                        style: GoogleFonts.plusJakartaSans(
                                          color: TColor.secondaryText,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...List.generate(addons.length, (i) {
                                final a = addons[i] as Map;
                                final aName = a['addon_name']?.toString() ?? '';
                                final aPrice = (a['price'] as num?)?.toDouble() ?? 0;
                                final isChecked = selectedAddonIndices.contains(i);
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isChecked) {
                                        selectedAddonIndices.remove(i);
                                      } else {
                                        selectedAddonIndices.add(i);
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isChecked
                                          ? TColor.warning.withOpacity(0.08)
                                          : TColor.textfield,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isChecked
                                          ? Border.all(color: TColor.warning, width: 1.5)
                                          : Border.all(color: TColor.border, width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isChecked
                                              ? Icons.check_box_rounded
                                              : Icons.check_box_outline_blank_rounded,
                                          color: TColor.warning,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            aName,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: TColor.primaryText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '+ ₹${aPrice.toStringAsFixed(0)}',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: TColor.secondaryText,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],

                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Divider(color: TColor.border),
                            ),

                            // Quantity selector
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                children: [
                                  Text(
                                    'Quantity',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: TColor.primaryText,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  _buildQtyButton(
                                    icon: Icons.remove_rounded,
                                    onTap: () {
                                      if (qty > 1) setState(() => qty--);
                                    },
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    switchInCurve: Curves.easeInOut,
                                    switchOutCurve: Curves.easeInOut,
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(scale: animation, child: child),
                                    child: Container(
                                      key: ValueKey(qty),
                                      margin: const EdgeInsets.symmetric(horizontal: 14),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: TColor.border),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        qty.toString(),
                                        style: GoogleFonts.plusJakartaSans(
                                          color: TColor.primaryText,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  _buildQtyButton(
                                    icon: Icons.add_rounded,
                                    onTap: () => setState(() => qty++),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Top bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircleButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        _buildCircleButton(
                          icon: Icons.shopping_bag_outlined,
                          badge: cartCount,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyOrderView(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Sticky Add to Cart CTA ───
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPad),
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
            child: Container(
              decoration: BoxDecoration(
                color: TColor.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: TColor.primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: _addToCart,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$qty ${qty > 1 ? 'items' : 'item'}',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${_totalPrice.toStringAsFixed(0)}',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Add to Cart',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.shopping_bag_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: TColor.primary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    int badge = 0,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ),
        ),
        if (badge > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: TColor.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                badge.toString(),
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
