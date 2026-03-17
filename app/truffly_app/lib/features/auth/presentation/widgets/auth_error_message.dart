import 'package:flutter/material.dart';

class AuthErrorMessage extends StatelessWidget {
  const AuthErrorMessage({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    final value = message?.trim();
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      value,
      style: TextStyle(
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
