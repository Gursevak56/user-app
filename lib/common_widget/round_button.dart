import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/color_extension.dart';

enum RoundButtonType { bgPrimary, textPrimary }

class RoundButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String title;
  final RoundButtonType type;
  final double fontSize;
  final double height;
  final double width;
  final BorderRadiusGeometry borderRadius;
  final Gradient gradient;
  final IconData? icon;

  const RoundButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.fontSize = 16,
    this.height = 56,
    this.width = double.infinity,
    this.type = RoundButtonType.bgPrimary,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.gradient = TColor.foodTabGradient,
    this.icon,
  });

  @override
  State<RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<RoundButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.type == RoundButtonType.bgPrimary;
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: isPrimary ? TColor.ctaShadow : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: widget.borderRadius,
          child: InkWell(
            onTap: () {
              _scaleCtrl.forward().then((_) => _scaleCtrl.reverse());
              widget.onPressed();
            },
            onTapDown: (_) => _scaleCtrl.forward(),
            onTapCancel: () => _scaleCtrl.reverse(),
            borderRadius: widget.borderRadius as BorderRadius?,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: widget.height,
              width: widget.width,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: isPrimary ? TColor.premiumGradient : null,
                color: isPrimary ? null : TColor.white,
                borderRadius: widget.borderRadius,
                border: isPrimary
                    ? null
                    : Border.all(color: TColor.primary, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon,
                        color: isPrimary ? Colors.white : TColor.primary,
                        size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.title,
                    style: GoogleFonts.plusJakartaSans(
                      color: isPrimary ? TColor.white : TColor.primary,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
