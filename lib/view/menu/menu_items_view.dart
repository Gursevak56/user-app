import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_textfield.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../more/my_order_view.dart';
import 'item_details_view.dart';

class MenuItemsView extends StatefulWidget {
  final Map mObj;
  const MenuItemsView({super.key, required this.mObj});

  @override
  State<MenuItemsView> createState() => _MenuItemsViewState();
}

class _MenuItemsViewState extends State<MenuItemsView> {
  TextEditingController txtSearch = TextEditingController();
  String _searchQuery = '';

  List menuCategoriesArr = [];
  Map restaurantInfo = {};
  bool isLoading = true;

  /// Filter categories and their items by search query
  List get _filteredCategories {
    if (_searchQuery.isEmpty) return menuCategoriesArr;
    return menuCategoriesArr.map((cat) {
      final catMap = cat as Map? ?? {};
      final items = (catMap['items'] as List? ?? []).where((item) {
        final name = (item as Map?)?['name']?.toString().toLowerCase() ?? '';
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
      return {...catMap, 'items': items};
    }).where((cat) => (cat['items'] as List).isNotEmpty).toList();
  }

  @override
  void initState() {
    super.initState();
    txtSearch.addListener(() {
      setState(() => _searchQuery = txtSearch.text.trim());
    });
    _fetchRestaurantMenu();
  }

  @override
  void dispose() {
    txtSearch.dispose();
    super.dispose();
  }

  void _fetchRestaurantMenu() async {
    final lat = Globs.udValueDouble(Globs.userLat).toString();
    final lng = Globs.udValueDouble(Globs.userLng).toString();
    final resId = widget.mObj["id"]?.toString() ?? "";

    if (resId.isEmpty) {
      setState(() { isLoading = false; });
      return;
    }

    final params = <String, String>{};
    if (lat != "0.0" && lng != "0.0") {
      params['lat'] = lat;
      params['lng'] = lng;
    }

    await ServiceCall.get(
      "${SVKey.restaurantBaseUrl}/api/restaurants/$resId/menu",
      queryParameters: params,
      isToken: Globs.udValueBool(Globs.userLogin),
      withSuccess: (responseObj) async {
        if (responseObj[KKey.statusCode] == 200) {
          final data = responseObj["data"] as Map<String, dynamic>? ?? {};
          if (mounted) {
            setState(() {
              restaurantInfo = data["restaurant"] as Map? ?? {};
              menuCategoriesArr = data["menu_categories"] as List? ?? [];
              isLoading = false;
            });
          }
        }
      },
      failure: (err) async {
        if (mounted) {
          setState(() { isLoading = false; });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: Text(
          widget.mObj["name"]?.toString() ?? "Restaurant",
          style: GoogleFonts.plusJakartaSans(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const MyOrderView()));
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TColor.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 20,
                  color: TColor.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Container(
            color: TColor.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: RoundTextfield(
              hintText: "Search menu items",
              controller: txtSearch,
              left: Icon(Icons.search_rounded,
                  color: TColor.placeholder, size: 22),
            ),
          ),
          // Content
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: TColor.primary,
                      strokeWidth: 2.5,
                    ),
                  )
                : menuCategoriesArr.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: TColor.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.restaurant_menu_rounded,
                                  size: 40, color: TColor.primary),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No menu items available",
                              style: GoogleFonts.plusJakartaSans(
                                color: TColor.secondaryText,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredCategories.length,
                              itemBuilder: ((context, catIndex) {
                                var catObj = _filteredCategories[catIndex] as Map? ?? {};
                                var catName = catObj["name"]?.toString() ?? "Items";
                                var items = catObj["items"] as List? ?? [];

                                if (items.isEmpty) return const SizedBox();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Category header
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, bottom: 10),
                                      child: Text(
                                        catName,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: TColor.primaryText,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    // Items
                                    ListView.separated(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: items.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: ((context, index) {
                                        var itemObj = items[index] as Map? ?? {};
                                        return _buildMenuItem(itemObj, catName);
                                      }),
                                    ),
                                    const SizedBox(height: 16),
                                    Divider(
                                        color: TColor.border, height: 1),
                                  ],
                                );
                              }),
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(Map itemObj, String catName) {
    final imageUrl = itemObj["image_url"]?.toString() ?? "";
    final isNetwork = imageUrl.startsWith("http");
    final isVeg = itemObj["is_vegetarian"] == true || itemObj["is_veg"] == 1;
    final price = (itemObj["price"] as num?)?.toDouble() ?? 0;
    final hasVariants = itemObj["has_variants"] == true;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailsView(
              mObj: itemObj,
              restaurantId: widget.mObj['id'] as int? ?? 0,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
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
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Veg/Non-veg indicator
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isVeg ? TColor.success : TColor.primary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Center(
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isVeg ? TColor.success : TColor.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      if (itemObj["is_bestseller"] == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: TColor.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "Bestseller",
                            style: GoogleFonts.plusJakartaSans(
                              color: TColor.warning,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    itemObj["name"]?.toString() ?? "",
                    style: GoogleFonts.plusJakartaSans(
                      color: TColor.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasVariants
                        ? "From ₹${price.toStringAsFixed(0)}"
                        : "₹${price.toStringAsFixed(0)}",
                    style: GoogleFonts.plusJakartaSans(
                      color: TColor.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (itemObj["description"]?.toString().isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      itemObj["description"].toString(),
                      style: GoogleFonts.plusJakartaSans(
                        color: TColor.secondaryText,
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Image + Add button
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: isNetwork
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: TColor.primaryLight,
                              child: Icon(Icons.fastfood_rounded,
                                  color: TColor.primary.withOpacity(0.3),
                                  size: 28),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: TColor.primaryLight,
                              child: Icon(Icons.fastfood_rounded,
                                  color: TColor.primary.withOpacity(0.3),
                                  size: 28),
                            ),
                          )
                        : Container(
                            color: TColor.primaryLight,
                            child: Icon(Icons.fastfood_rounded,
                                color: TColor.primary.withOpacity(0.3),
                                size: 28),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                // ADD button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: TColor.primary, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: TColor.primary.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "ADD",
                    style: GoogleFonts.plusJakartaSans(
                      color: TColor.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
