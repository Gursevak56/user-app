import 'dart:async';
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
  Timer? _debounce;

  List menuItemsArr = [];
  Map restaurantInfo = {};
  bool isLoading = true;

  // Filters
  int? _selectedCategoryId;
  bool _isVegetarian = false;
  bool _isVegan = false;
  bool _isGlutenFree = false;
  List categoryArr = [];

  @override
  void initState() {
    super.initState();
    txtSearch.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (_searchQuery != txtSearch.text.trim()) {
          setState(() {
            _searchQuery = txtSearch.text.trim();
            isLoading = true;
          });
          _fetchRestaurantMenu();
        }
      });
    });
    _fetchCategories();
    _fetchRestaurantMenu();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    txtSearch.dispose();
    super.dispose();
  }

  void _fetchCategories() async {
    final resId = widget.mObj["restaurant_id"]?.toString() ?? 
                  widget.mObj["id"]?.toString() ?? "";
    if (resId.isEmpty) {
      print("CATEGORY FETCH: resId is empty, skipping");
      return;
    }

    final url = "${SVKey.restaurantBaseUrl}/restaurants/$resId/categories";
    print("-------------- CATEGORY FETCH -----------");
    print("URL: $url");

    await ServiceCall.get(
      url,
      queryParameters: {},
      isToken: Globs.udValueBool(Globs.userLogin),
      withSuccess: (responseObj) async {
        print("Category Response statusCode: ${responseObj[KKey.statusCode]}");
        final sc = responseObj[KKey.statusCode];
        if (sc == 200 || sc == "200") {
          final rawData = responseObj["data"];
          List items = [];
          if (rawData is Map) {
            items = rawData["items"] as List? ?? [];
          } else if (rawData is List) {
            items = rawData;
          }
          print("Category Array parsed size: ${items.length}");
          if (mounted) {
            setState(() {
              categoryArr = items;
            });
          }
        } else {
          print("Category fetch: unexpected statusCode=$sc");
        }
      },
      failure: (err) async {
        print("Category Fetch Err: $err");
      },
    );
  }

  void _fetchRestaurantMenu() async {
    final lat = Globs.udValueDouble(Globs.userLat).toString();
    final lng = Globs.udValueDouble(Globs.userLng).toString();
    final resId = widget.mObj["restaurant_id"]?.toString() ?? 
                  widget.mObj["id"]?.toString() ?? "";

    if (resId.isEmpty) {
      setState(() { isLoading = false; });
      return;
    }

    final params = <String, String>{
      "is_available": "true",
      "is_qrunch": "true",
    };

    if (_selectedCategoryId != null) {
      params["category_id"] = _selectedCategoryId.toString();
    }
    if (_isVegetarian) params["is_vegetarian"] = "true";
    if (_isVegan) params["is_vegan"] = "true";
    if (_isGlutenFree) params["is_gluten_free"] = "true";
    if (_searchQuery.isNotEmpty) params["search"] = _searchQuery;

    print("-------------- MENU FETCH -----------");
    print("URL: ${SVKey.restaurantBaseUrl}/restaurants/$resId/menu/items");
    print("Params: $params");

    await ServiceCall.get(
      "${SVKey.restaurantBaseUrl}/restaurants/$resId/menu/items",
      queryParameters: params,
      isToken: Globs.udValueBool(Globs.userLogin),
      withSuccess: (responseObj) async {
        print("Menu Response statusCode: ${responseObj[KKey.statusCode]}");
        final sc = responseObj[KKey.statusCode];
        if (sc == 200 || sc == "200") {
          final rawData = responseObj["data"];
          List data = [];
          if (rawData is List) {
            data = rawData;
          } else if (rawData is Map && rawData["items"] is List) {
            data = rawData["items"];
          }
          print("Menu Array parsed size: ${data.length}");
          if (mounted) {
            setState(() {
              menuItemsArr = data;
              isLoading = false;
            });
          }
        } else {
          print("Menu parsed failed condition: statusCode=$sc");
          if (mounted) setState(() => isLoading = false);
        }
      },
      failure: (err) async {
        print("Menu Fetch Err: $err");
        if (mounted) {
          setState(() { isLoading = false; });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
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
          
          // Categories + Dietary Filters
          Container(
            color: TColor.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chips
                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categoryArr.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = _selectedCategoryId == null;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = null;
                                isLoading = true;
                              });
                              _fetchRestaurantMenu();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? TColor.primary : TColor.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? TColor.primary : TColor.placeholder.withOpacity(0.3),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "All",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: isSelected ? Colors.white : TColor.primaryText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      final cat = categoryArr[index - 1] as Map? ?? {};
                      final catId = (cat["id"] as num?)?.toInt();
                      final isSelected = _selectedCategoryId == catId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryId = isSelected ? null : catId;
                              isLoading = true;
                            });
                            _fetchRestaurantMenu();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? TColor.primary : TColor.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? TColor.primary : TColor.placeholder.withOpacity(0.3),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                cat["name"]?.toString() ?? "",
                                style: GoogleFonts.plusJakartaSans(
                                  color: isSelected ? Colors.white : TColor.primaryText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Dietary filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildDietaryChip("🥬 Vegetarian", _isVegetarian, (val) {
                        setState(() { _isVegetarian = val; isLoading = true; });
                        _fetchRestaurantMenu();
                      }),
                      const SizedBox(width: 8),
                      _buildDietaryChip("🌱 Vegan", _isVegan, (val) {
                        setState(() { _isVegan = val; isLoading = true; });
                        _fetchRestaurantMenu();
                      }),
                      const SizedBox(width: 8),
                      _buildDietaryChip("🌾 Gluten Free", _isGlutenFree, (val) {
                        setState(() { _isGlutenFree = val; isLoading = true; });
                        _fetchRestaurantMenu();
                      }),
                    ],
                  ),
                ),
              ],
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
                : menuItemsArr.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: menuItemsArr.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: ((context, index) {
                                var itemObj = menuItemsArr[index] as Map? ?? {};
                                return _buildMenuItem(itemObj, "Menu");
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

  Widget _buildDietaryChip(String label, bool isSelected, Function(bool) onSelected) {
    return GestureDetector(
      onTap: () => onSelected(!isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? TColor.primaryLight : TColor.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? TColor.primary : TColor.placeholder.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? TColor.primary : TColor.secondaryText,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(Icons.check_rounded, size: 14, color: TColor.primary),
            ],
          ],
        ),
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
