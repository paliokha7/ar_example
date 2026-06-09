import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FaceMaskScreen extends StatelessWidget {
  const FaceMaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Mask AR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/ar-examples'),
        ),
      ),
      body: const Center(
        child: Text(
          'Face Mask AR Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
} 