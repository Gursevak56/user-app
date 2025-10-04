import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class ViewAllTitleRow extends StatelessWidget {
  final String title;
  final VoidCallback onView;
  const ViewAllTitleRow({super.key, required this.title, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: onView,
          child: Text(
            "See all",
            style: TextStyle(
              color: TColor.primary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class SeeAllIconTitleRow extends StatelessWidget {
  final String title;
  final VoidCallback onView;
  final IconData icon;
  const SeeAllIconTitleRow(
      {super.key,
      required this.title,
      required this.onView,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(
              width: 8,
            ),
            Text(
              title,
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: onView,
          child: Text(
            "See all",
            style: TextStyle(
              color: TColor.primary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class IconTitleRow extends StatelessWidget {
  final String title;
  final VoidCallback onView;
  final IconData icon;
  const IconTitleRow({super.key, required this.title, required this.onView, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        IconButton(
          onPressed: onView,
          icon: Icon(icon),
          iconSize: 24,
          color: TColor.primaryText,
          )
      ],
    );
  }
}
