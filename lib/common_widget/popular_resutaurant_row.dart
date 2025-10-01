import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class PopularRestaurantRow extends StatelessWidget {
  final Map pObj;
  final VoidCallback onTap;
  const PopularRestaurantRow({
    super.key,
    required this.pObj,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(10),
              child: Image.asset(
                pObj["image"].toString(),
                width: double.maxFinite,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pObj["name"],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/img/rate.png",
                        width: 16,
                        height: 16,
                        fit: BoxFit.cover,
                        color: TColor.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pObj["rate"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(${pObj["rating"]} Ratings)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        pObj["type"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        " . ",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: TColor.primary, fontSize: 11),
                      ),
                      Text(
                        pObj["food_type"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 12,
                        ),
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
  }
}
