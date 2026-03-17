import 'package:flutter/material.dart';

class AuthTextBlock extends StatelessWidget {
  const AuthTextBlock({
    super.key,
    required this.child,
    this.alignment = Alignment.centerLeft,
    this.maxWidth = 320,
  });

  final Widget child;
  final Alignment alignment;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
