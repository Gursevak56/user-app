import 'package:flutter/material.dart';

import '../../common/color_extension.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../common_widget/round_textfield.dart';
import '../../common_widget/favorite_toggle_btn.dart';
import '../more/my_order_view.dart';
import 'menu_items_view.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

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
    
    final params = <String, String>{
      "page": "1",
      "limit": "20"
    };
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
          setState(() { isLoading = false; });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Menu",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyOrderView()),
                );
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
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
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: media.width * 0.27,
                height: media.height * 0.6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: TColor.primaryGradient,
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(35),
                      bottomRight: Radius.circular(35)),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      isLoading 
                        ? const Center(child: CircularProgressIndicator()) 
                        : menuArr.isEmpty 
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text("No restaurants found."),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 30, horizontal: 20),
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _filteredMenuArr.length,
                                itemBuilder: ((context, index) {
                                  var mObj = _filteredMenuArr[index] as Map? ?? {};
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
                                    child: Stack(
                                      alignment: Alignment.centerRight,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              top: 8, bottom: 8, right: 20),
                                          width: media.width - 100,
                                          height: 90,
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(25),
                                                  bottomLeft: Radius.circular(25),
                                                  topRight: Radius.circular(10),
                                                  bottomRight: Radius.circular(10)),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 7,
                                                    offset: Offset(0, 4))
                                              ]),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              // fallback image logic since real may be network
                                              "assets/img/pizza_hub.png",
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.contain,
                                            ),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    mObj["name"]?.toString() ?? "Restaurant",
                                                    style: TextStyle(
                                                        color: TColor.primaryText,
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w700),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(
                                                    height: 4,
                                                  ),
                                                  Text(
                                                    mObj["cuisine"]?.toString() ?? "Various",
                                                    style: TextStyle(
                                                        color: TColor.secondaryText,
                                                        fontSize: 11),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            FavoriteToggleBtn(
                                              itemId: (mObj["id"] as num? ?? 0).toInt(),
                                              itemType: "restaurant",
                                              isFavorite: mObj["is_favorite"] == 1 || mObj["is_favorite"] == true,
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(17.5),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                        color: Colors.black12,
                                                        blurRadius: 4,
                                                        offset: Offset(0, 2))
                                                  ]),
                                              alignment: Alignment.center,
                                              child: Image.asset(
                                                "assets/img/btn_next.png",
                                                width: 15,
                                                height: 15,
                                                color: TColor.secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
