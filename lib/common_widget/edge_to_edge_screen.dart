import 'package:flutter/material.dart';

class EdgeToEdgeScreen extends StatelessWidget {
  final Widget child;

  const EdgeToEdgeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        bottom: true,
        child: child,
      ),
    );
  }
}
