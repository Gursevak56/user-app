import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class StartOrderButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Gradient gradient;

  const StartOrderButton({
    super.key,
    required this.onPressed,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: TColor.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]),
        child: Text(
          "Start Order",
          style: TextStyle(
            color: TColor.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
