import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common_widget/favorite_toggle_btn.dart';
import 'package:food_delivery/common_widget/menu_item_row.dart';

class FavoriteView extends StatefulWidget {
  const FavoriteView({super.key});

  @override
  State<FavoriteView> createState() => _FavoriteViewState();
}

class _FavoriteViewState extends State<FavoriteView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List restaurants = [];
  List dishes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    await ServiceCall.get(
      "${SVKey.restaurantBaseUrl}/api/favorites",
      isToken: true,
      withSuccess: (res) async {
        if (!mounted) return;
        if (res['status'] == 'success') {
          var data = res['data'] ?? {};
          setState(() {
            restaurants = data['restaurants'] as List? ?? [];
            dishes = data['dishes'] as List? ?? [];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      },
      failure: (err) async {
        if (!mounted) return;
        setState(() => isLoading = false);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: Text(
          "My Favorites",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset("assets/img/btn_back.png", width: 20, height: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: TColor.primary,
          unselectedLabelColor: TColor.secondaryText,
          indicatorColor: TColor.primary,
          tabs: const [
            Tab(text: "Restaurants"),
            Tab(text: "Dishes"),
          ],
        ),
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildRestaurantsTab(),
              _buildDishesTab(),
            ],
          ),
    );
  }

  Widget _buildRestaurantsTab() {
    if (restaurants.isEmpty) {
      return Center(
        child: Text("No favorite restaurants yet.", style: TextStyle(color: TColor.secondaryText)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final rObj = restaurants[index] as Map? ?? {};
        final rId = (rObj['id'] as num? ?? 0).toInt();
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.only(bottom: 15),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    "assets/img/pizza_hub.png", // Mock image if URL isn't working
                    width: 70, height: 70, fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rObj['name']?.toString() ?? "Restaurant",
                        style: TextStyle(color: TColor.primaryText, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rObj['cuisine']?.toString() ?? "Cuisine",
                        style: TextStyle(color: TColor.secondaryText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                FavoriteToggleBtn(
                  itemId: rId,
                  itemType: "restaurant",
                  isFavorite: true, // It's in the favorites list
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDishesTab() {
    if (dishes.isEmpty) {
      return Center(
        child: Text("No favorite dishes yet.", style: TextStyle(color: TColor.secondaryText)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dishes.length,
      itemBuilder: (context, index) {
        final itemObj = dishes[index] as Map? ?? {};
        final uiObj = {
          "id": itemObj["id"],
          "image": itemObj["image_url"] ?? "assets/img/dess_1.png",
          "name": itemObj["name"] ?? "",
          "rate": itemObj["price"]?.toString() ?? "0",
          "type": itemObj["is_veg"] == 1 ? "Veg" : "Non-Veg",
          "food_type": "Dish",
          "is_favorite": true
        };
        return MenuItemRow(
          mObj: uiObj,
          onTap: () {},
        );
      },
    );
  }
}
