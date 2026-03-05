import 'package:flutter/material.dart';
import 'package:truffly_app/features/health/presentation/health_screen.dart';

class TrufflyApp extends StatelessWidget {
  const TrufflyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Truffly',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HealthScreen(),
    );
  }
}
