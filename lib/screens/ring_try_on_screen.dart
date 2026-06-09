import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RingTryOnScreen extends StatelessWidget {
  const RingTryOnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Ring'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/ar-examples'),
        ),
      ),
      body: const Center(
        child: Text(
          'Virtual Ring Try-On Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
} 