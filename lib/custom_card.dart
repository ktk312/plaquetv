import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  Color primaryColorCode = const Color(0xFFA9DFD8);
  Color cardBackgroundColor = const Color(0xFF21222D);

  CustomCard({super.key, this.color, this.padding, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(8.0),
          ),
          color: color ?? cardBackgroundColor,
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(8.0),
          child: child,
        ));
  }
}
