import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_textfield.dart';

import '../../common_widget/menu_item_row.dart';
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
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset("assets/img/btn_back.png", width: 20, height: 20),
        ),
        title: Text(
          widget.mObj["name"]?.toString() ?? "Restaurant",
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const MyOrderView()));
              },
              icon: Image.asset(
                "assets/img/shopping_cart.png",
                width: 25,
                height: 25,
                color: TColor.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundTextfield(
                  hintText: "Search Food",
                  controller: txtSearch,
                  left: Container(
                    alignment: Alignment.center,
                    width: 30,
                    child: Image.asset(
                      "assets/img/search.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : menuCategoriesArr.isEmpty 
                      ? const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("No menu items available"),
                        ))
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: _filteredCategories.length,
                          itemBuilder: ((context, catIndex) {
                            var catObj = _filteredCategories[catIndex] as Map? ?? {};
                            var catName = catObj["name"]?.toString() ?? "Items";
                            var items = catObj["items"] as List? ?? [];
                            
                            if (items.isEmpty) return const SizedBox();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  child: Text(
                                    catName,
                                    style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: items.length,
                                  itemBuilder: ((context, index) {
                                    var itemObj = items[index] as Map? ?? {};
                                    // Adapt to MenuItemRow expected format
                                    var uiObj = {
                                      "image": itemObj["image_url"] ?? "assets/img/dess_1.png",
                                      "name": itemObj["name"] ?? "",
                                      "rate": itemObj["price"]?.toString() ?? "0",
                                      "type": itemObj["is_veg"] == 1 ? "Veg" : "Non-Veg",
                                      "food_type": catName,
                                    };
                                    return MenuItemRow(
                                      mObj: uiObj,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ItemDetailsView(
                                                mObj: itemObj,
                                                restaurantId: widget.mObj['id'] as int? ?? 0,
                                              )),
                                        );
                                      },
                                    );
                                  }),
                                ),
                              ],
                            );
                          }),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
