import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../common/color_extension.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../common_widget/round_textfield.dart';
import '../../common_widget/shimmer_block.dart';
import '../more/my_order_view.dart';
import 'menu_items_view.dart';

class MenuView extends StatefulWidget {
  final Map? rObj;
  const MenuView({super.key, this.rObj});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  List menuArr = [];
  bool isLoading = true;
  TextEditingController txtSearch = TextEditingController();
  String _searchQuery = '';

  List get _filteredMenuArr {
    if (_searchQuery.isEmpty) return menuArr;
    return menuArr.where((item) {
      final name = (item as Map?)?['name']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    txtSearch.addListener(() {
      setState(() => _searchQuery = txtSearch.text.trim());
    });
    _fetchRestaurants();
  }

  @override
  void dispose() {
    txtSearch.dispose();
    super.dispose();
  }

  void _fetchRestaurants() async {
    final lat = Globs.udValueDouble(Globs.userLat).toString();
    final lng = Globs.udValueDouble(Globs.userLng).toString();

    final params = <String, String>{"page": "1", "limit": "20"};
    if (lat != "0.0" && lng != "0.0") {
      params['lat'] = lat;
      params['lng'] = lng;
    }

    await ServiceCall.get(
      "${SVKey.restaurantBaseUrl}/api/restaurants",
      queryParameters: params,
      isToken: Globs.udValueBool(Globs.userLogin),
      withSuccess: (responseObj) async {
        if (responseObj[KKey.statusCode] == 200) {
          final data = responseObj["data"] as Map<String, dynamic>? ?? {};
          if (mounted) {
            setState(() {
              menuArr = data["restaurants"] as List? ?? [];
              isLoading = false;
            });
          }
        }
      },
      failure: (err) async {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
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
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: Text(
          "Restaurants",
          style: GoogleFonts.plusJakartaSans(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyOrderView()),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TColor.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    size: 20,
                    color: TColor.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: TColor.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: RoundTextfield(
              hintText: "Search restaurants...",
              controller: txtSearch,
              left: Icon(Icons.search_rounded,
                  color: TColor.placeholder, size: 22),
            ),
          ),
          // Restaurant list
          Expanded(
            child: isLoading
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: List.generate(
                            4, (_) => const ShimmerRestaurantCard()),
                      ),
                    ),
                  )
                : _filteredMenuArr.isEmpty
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
                              child: Icon(Icons.search_off_rounded,
                                  size: 48, color: TColor.primary),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "No restaurants found",
                              style: GoogleFonts.plusJakartaSans(
                                color: TColor.primaryText,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Try a different search",
                              style: GoogleFonts.plusJakartaSans(
                                color: TColor.secondaryText,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filteredMenuArr.length,
                        itemBuilder: ((context, index) {
                          var mObj =
                              _filteredMenuArr[index] as Map? ?? {};
                          final imageUrl =
                              mObj["image_url"]?.toString() ?? "";
                          final isNetwork = imageUrl.startsWith("http");

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MenuItemsView(
                                    mObj: mObj,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: TColor.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: TColor.cardShadow,
                              ),
                              child: Row(
                                children: [
                                  // Image
                                  ClipRRect(
                                    borderRadius:
                                        const BorderRadius.horizontal(
                                      left: Radius.circular(18),
                                    ),
                                    child: SizedBox(
                                      width: 105,
                                      height: 105,
                                      child: isNetwork
                                          ? CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (_, __) =>
                                                  Container(
                                                color: TColor.textfield,
                                                child: Center(
                                                  child: Icon(
                                                    Icons
                                                        .restaurant_rounded,
                                                    color: TColor
                                                        .placeholder,
                                                    size: 28,
                                                  ),
                                                ),
                                              ),
                                              errorWidget:
                                                  (_, __, ___) =>
                                                      Container(
                                                color: TColor.textfield,
                                                child: Center(
                                                  child: Icon(
                                                    Icons
                                                        .restaurant_rounded,
                                                    color: TColor
                                                        .placeholder,
                                                    size: 28,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              color: TColor.textfield,
                                              child: Center(
                                                child: Icon(
                                                  Icons
                                                      .restaurant_rounded,
                                                  color:
                                                      TColor.placeholder,
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  // Info
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mObj["name"]?.toString() ??
                                                "Restaurant",
                                            style: GoogleFonts
                                                .plusJakartaSans(
                                              color: TColor.primaryText,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            mObj["cuisine"]
                                                    ?.toString() ??
                                                "Various",
                                            style: GoogleFonts
                                                .plusJakartaSans(
                                              color:
                                                  TColor.secondaryText,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 8,
                                                    vertical: 3),
                                                decoration:
                                                    BoxDecoration(
                                                  color: const Color(
                                                          0xFFFFC107)
                                                      .withOpacity(
                                                          0.15),
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                        Icons
                                                            .star_rounded,
                                                        color: Color(
                                                            0xFFFFC107),
                                                        size: 14),
                                                    const SizedBox(
                                                        width: 3),
                                                    Text(
                                                      mObj["rating"]
                                                              ?.toString() ??
                                                          "0",
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                        color: TColor
                                                            .primaryText,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight
                                                                .w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 14,
                                                  color: TColor
                                                      .placeholder),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
          ),
        ],
      ),
    );
  }
}
