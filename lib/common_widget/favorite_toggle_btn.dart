import 'package:flutter/material.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:food_delivery/common/globs.dart';

class FavoriteToggleBtn extends StatefulWidget {
  final int itemId;
  final String itemType; // "restaurant" or "dish"
  final bool isFavorite;

  const FavoriteToggleBtn({
    super.key,
    required this.itemId,
    required this.itemType,
    this.isFavorite = false,
  });

  @override
  State<FavoriteToggleBtn> createState() => _FavoriteToggleBtnState();
}

class _FavoriteToggleBtnState extends State<FavoriteToggleBtn> {
  late bool isFavorite;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() async {
    setState(() => isLoading = true);
    await ServiceCall.post({
      "item_id": widget.itemId,
      "type": widget.itemType,
      "is_favorite": !isFavorite
    }, "${SVKey.restaurantBaseUrl}/api/favorites", 
    isToken: true,
    withSuccess: (res) async {
       if (mounted) {
         if (res['status'] == 'success') {
           setState(() => isFavorite = !isFavorite);
         }
         setState(() => isLoading = false);
       }
    }, 
    failure: (err) async {
       if (mounted) {
         setState(() => isLoading = false);
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update favorite')));
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: isLoading ? null : _toggleFavorite,
        icon: isLoading 
           ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
           : Icon(
               isFavorite ? Icons.favorite : Icons.favorite_border,
               color: isFavorite ? Colors.red : Colors.white,
               size: 24,
             ),
      ),
    );
  }
}
