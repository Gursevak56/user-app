import 'package:flutter/material.dart';
import 'package:food_delivery/common/service_call.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/color_extension.dart';

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

class _FavoriteToggleBtnState extends State<FavoriteToggleBtn>
    with SingleTickerProviderStateMixin {
  late bool isFavorite;
  bool isLoading = false;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleFavorite() async {
    setState(() => isLoading = true);
    await ServiceCall.post({
      "item_id": widget.itemId,
      "type": widget.itemType,
      "is_favorite": !isFavorite
    }, "${SVKey.restaurantBaseUrl}/api/favorites",
        isToken: true, withSuccess: (res) async {
      if (mounted) {
        if (res['status'] == 'success') {
          setState(() => isFavorite = !isFavorite);
          _animCtrl.forward(from: 0);
        }
        setState(() => isLoading = false);
      }
    }, failure: (err) async {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update favorite'),
            backgroundColor: TColor.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: IconButton(
          onPressed: isLoading ? null : _toggleFavorite,
          icon: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: TColor.primary))
              : Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? TColor.primary : TColor.secondaryText,
                  size: 22,
                ),
        ),
      ),
    );
  }
}
