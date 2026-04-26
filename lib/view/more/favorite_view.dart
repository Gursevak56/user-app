import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common_widget/favorite_toggle_btn.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteView extends StatefulWidget {
  const FavoriteView({super.key});

  @override
  State<FavoriteView> createState() => _FavoriteViewState();
}

class _FavoriteViewState extends State<FavoriteView>
    with SingleTickerProviderStateMixin {
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          "My Favorites",
          style: GoogleFonts.plusJakartaSans(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: TColor.primary,
          unselectedLabelColor: TColor.secondaryText,
          indicatorColor: TColor.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: "Restaurants"),
            Tab(text: "Dishes"),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: TColor.primary,
                strokeWidth: 2.5,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRestaurantsTab(),
                _buildDishesTab(),
              ],
            ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: TColor.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: TColor.primary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              color: TColor.secondaryText,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantsTab() {
    if (restaurants.isEmpty) {
      return _buildEmptyState(
          "No favorite restaurants yet", Icons.storefront_rounded);
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: restaurants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final rObj = restaurants[index] as Map? ?? {};
        final rId = (rObj['id'] as num? ?? 0).toInt();
        final imageUrl = rObj['logo_url']?.toString() ?? '';
        final hasImage = imageUrl.startsWith('http');

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: TColor.cardShadow,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: hasImage
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: TColor.primaryLight,
                            child: Icon(Icons.restaurant_rounded,
                                color: TColor.primary.withOpacity(0.3),
                                size: 24),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: TColor.primaryLight,
                            child: Icon(Icons.restaurant_rounded,
                                color: TColor.primary.withOpacity(0.3),
                                size: 24),
                          ),
                        )
                      : Container(
                          color: TColor.primaryLight,
                          child: Icon(Icons.restaurant_rounded,
                              color: TColor.primary.withOpacity(0.3),
                              size: 24),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rObj['name']?.toString() ?? "Restaurant",
                      style: GoogleFonts.plusJakartaSans(
                        color: TColor.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rObj['cuisine']?.toString() ?? "Cuisine",
                      style: GoogleFonts.plusJakartaSans(
                        color: TColor.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              FavoriteToggleBtn(
                itemId: rId,
                itemType: "restaurant",
                isFavorite: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDishesTab() {
    if (dishes.isEmpty) {
      return _buildEmptyState(
          "No favorite dishes yet", Icons.fastfood_rounded);
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: dishes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final itemObj = dishes[index] as Map? ?? {};
        final dishId = (itemObj['id'] as num? ?? 0).toInt();
        final imageUrl = itemObj['image_url']?.toString() ?? '';
        final hasImage = imageUrl.startsWith('http');
        final isVeg = itemObj['is_veg'] == 1;
        final price = (itemObj['price'] as num?)?.toDouble() ?? 0;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: TColor.cardShadow,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: hasImage
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: TColor.primaryLight,
                            child: Icon(Icons.fastfood_rounded,
                                color: TColor.primary.withOpacity(0.3),
                                size: 24),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: TColor.primaryLight,
                            child: Icon(Icons.fastfood_rounded,
                                color: TColor.primary.withOpacity(0.3),
                                size: 24),
                          ),
                        )
                      : Container(
                          color: TColor.primaryLight,
                          child: Icon(Icons.fastfood_rounded,
                              color: TColor.primary.withOpacity(0.3),
                              size: 24),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isVeg ? TColor.success : TColor.primary,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isVeg ? TColor.success : TColor.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            itemObj['name']?.toString() ?? "Dish",
                            style: GoogleFonts.plusJakartaSans(
                              color: TColor.primaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${price.toStringAsFixed(0)}",
                      style: GoogleFonts.plusJakartaSans(
                        color: TColor.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              FavoriteToggleBtn(
                itemId: dishId,
                itemType: "dish",
                isFavorite: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
