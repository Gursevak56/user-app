import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/common/cart_provider.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common_widget/auth_bottom_sheet.dart';
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
          content: Text('$_itemName added to cart'),
          backgroundColor: TColor.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add to cart'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final cartCount = context.watch<CartProvider>().itemCount;

    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
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
                color: TColor.textfield,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                width: media.width,
                height: media.width * 0.75,
                color: TColor.textfield,
                child: Icon(Icons.restaurant, size: 60, color: TColor.placeholder),
              ),
            )
          else
            Container(
              width: media.width,
              height: media.width * 0.75,
              color: TColor.textfield,
              child: Icon(Icons.restaurant, size: 60, color: TColor.placeholder),
            ),

          // Gradient overlay
          Container(
            width: media.width,
            height: media.width * 0.75,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black54, Colors.transparent, Colors.black54],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Scrollable content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  SizedBox(height: media.width * 0.65),
                  Container(
                    decoration: BoxDecoration(
                      color: TColor.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),

                        // Name + Veg badge
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Row(
                            children: [
                              // Veg/Non-veg indicator
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _isVeg ? Colors.green : Colors.red,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _isVeg ? Colors.green : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _itemName,
                                  style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 22,
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
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Text(
                            '₹${_unitPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: TColor.primary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Text(
                            _description,
                            style: TextStyle(
                              color: TColor.secondaryText,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),

                        // Variant selector
                        if (_hasVariants && variants.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Divider(color: TColor.secondaryText.withOpacity(0.3)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Text(
                              'Select Variant',
                              style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...List.generate(variants.length, (i) {
                            final v = variants[i] as Map;
                            final vName = v['name']?.toString() ?? '';
                            final vPrice = (v['price'] as num?)?.toDouble() ?? 0;
                            final isSelected = selectedVariantIndex == i;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedVariantIndex = i;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? TColor.primary.withOpacity(0.08)
                                      : TColor.textfield,
                                  borderRadius: BorderRadius.circular(10),
                                  border: isSelected
                                      ? Border.all(color: TColor.primary, width: 1.5)
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                      color: TColor.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        vName,
                                        style: TextStyle(
                                          color: TColor.primaryText,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '₹${vPrice.toStringAsFixed(0)}',
                                      style: TextStyle(
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
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Divider(color: TColor.secondaryText.withOpacity(0.3)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Text(
                              'Add-ons',
                              style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
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
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isChecked
                                      ? TColor.secondary.withOpacity(0.08)
                                      : TColor.textfield,
                                  borderRadius: BorderRadius.circular(10),
                                  border: isChecked
                                      ? Border.all(color: TColor.secondary, width: 1.5)
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isChecked
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      color: TColor.secondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        aName,
                                        style: TextStyle(
                                          color: TColor.primaryText,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '+ ₹${aPrice.toStringAsFixed(0)}',
                                      style: TextStyle(
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

                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Divider(color: TColor.secondaryText.withOpacity(0.3)),
                        ),

                        // Quantity selector
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Row(
                            children: [
                              Text(
                                'Quantity',
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              _buildQtyButton(
                                icon: Icons.remove,
                                onTap: () {
                                  if (qty > 1) setState(() => qty--);
                                },
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 12),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: TColor.primary),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  qty.toString(),
                                  style: TextStyle(
                                    color: TColor.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              _buildQtyButton(
                                icon: Icons.add,
                                onTap: () => setState(() => qty++),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Add to Cart bar
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 25),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: TColor.primaryGradient,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: TColor.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: _addToCart,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$qty ${qty > 1 ? 'items' : 'item'}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₹${_totalPrice.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Add to Cart',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
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
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildCircleButton(
                    icon: Icons.shopping_cart,
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
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: TColor.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
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
        InkWell(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
        if (badge > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: TColor.secondary,
                shape: BoxShape.circle,
              ),
              child: Text(
                badge.toString(),
                style: const TextStyle(
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
