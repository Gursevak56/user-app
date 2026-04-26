import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/color_extension.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PopularReestaurants extends StatefulWidget {
  const PopularReestaurants({super.key});

  @override
  State<PopularReestaurants> createState() => _PopularReestaurantsState();
}

class _PopularReestaurantsState extends State<PopularReestaurants> {
  List restaurants = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  void _fetchRestaurants() async {
    final lat = Globs.udValueDouble(Globs.userLat).toString();
    final lng = Globs.udValueDouble(Globs.userLng).toString();

    final params = <String, String>{};
    if (lat != "0.0" && lng != "0.0") {
      params['lat'] = lat;
      params['lng'] = lng;
      params['radius'] = "10";
    }

    await ServiceCall.get(
      "${SVKey.restaurantBaseUrl}/api/home",
      queryParameters: params,
      isToken: Globs.udValueBool(Globs.userLogin),
      withSuccess: (responseObj) async {
        if (responseObj[KKey.statusCode] == 200) {
          final data = responseObj["data"] as Map<String, dynamic>? ?? {};
          if (mounted) {
            setState(() {
              restaurants = data["recommended_restaurants"] as List? ?? [];
              isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              errorMessage = "Failed to load restaurants.";
              isLoading = false;
            });
          }
        }
      },
      failure: (err) async {
        if (mounted) {
          setState(() {
            errorMessage = err.toString();
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Popular Restaurants",
          style: GoogleFonts.plusJakartaSans(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: TColor.primary,
                strokeWidth: 2.5,
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: GoogleFonts.plusJakartaSans(
                      color: TColor.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : restaurants.isEmpty
                  ? Center(
                      child: Text(
                        "No popular restaurants found nearby.",
                        style: GoogleFonts.plusJakartaSans(
                          color: TColor.secondaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 100, 16, 32),
                      physics: const BouncingScrollPhysics(),
                      itemCount: restaurants.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final rest = restaurants[index] as Map? ?? {};
                        final imageUrl = rest["image_url"]?.toString() ?? "";
                        final isNetwork = imageUrl.startsWith("http");

                        return Container(
                          decoration: BoxDecoration(
                            color: TColor.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: TColor.cardShadow,
                          ),
                          child: InkWell(
                            onTap: () {
                              // Navigate to restaurant menu
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Restaurant image
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(18),
                                 ),
                                  child: isNetwork
                                      ? CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          width: double.infinity,
                                          height: 180,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) => _buildPlaceholder(),
                                        )
                                      : _buildPlaceholder(),
                                ),
                                // Details
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rest["name"]?.toString() ?? "Restaurant",
                                        style: GoogleFonts.plusJakartaSans(
                                          color: TColor.primaryText,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          // Rating badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: TColor.warning.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.star_rounded,
                                                    size: 14, color: TColor.warning),
                                                const SizedBox(width: 3),
                                                Text(
                                                  rest["rating"]?.toString() ?? "0",
                                                  style: GoogleFonts.plusJakartaSans(
                                                    color: TColor.warning,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: TColor.placeholder,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            rest["cuisine"]?.toString() ?? "",
                                            style: GoogleFonts.plusJakartaSans(
                                              color: TColor.secondaryText,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "•",
                                            style: GoogleFonts.plusJakartaSans(
                                              color: TColor.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            (rest["tags"] as List?)?.join(", ") ?? "",
                                            style: GoogleFonts.plusJakartaSans(
                                              color: TColor.secondaryText,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 180,
      color: TColor.primaryLight,
      child: Icon(Icons.restaurant_rounded,
          size: 48, color: TColor.primary.withOpacity(0.3)),
    );
  }
}

