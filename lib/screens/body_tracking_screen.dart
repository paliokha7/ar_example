import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BodyTrackingScreen extends StatelessWidget {
  const BodyTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Tracking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/ar-examples'),
        ),
      ),
      body: const Center(
        child: Text(
          'Body Tracking Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
} 