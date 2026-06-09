import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/ar_feature_card.dart';

class ARExamplesScreen extends StatelessWidget {
  const ARExamplesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Examples'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ARFeatureCard(
              title: 'Plane Detection',
              subtitle: 'Detect horizontal and vertical surfaces',
              icon: Icons.view_in_ar,
              startColor: const Color(0xFF2196F3),
              endColor: const Color(0xFF1976D2),
              onTap: () => context.go('/plane-detection'),
            ),
            const SizedBox(height: 16),
            ARFeatureCard(
              title: 'Face Mask AR',
              subtitle: 'Virtual face masks and filters',
              icon: Icons.face,
              startColor: const Color(0xFF9C27B0),
              endColor: const Color(0xFF7B1FA2),
              onTap: () => context.go('/face-mask'),
            ),
            const SizedBox(height: 16),
            ARFeatureCard(
              title: 'Virtual Ring',
              subtitle: 'Try on rings virtually',
              icon: Icons.circle,
              startColor: const Color(0xFFFF9800),
              endColor: const Color(0xFFF57C00),
              onTap: () => context.go('/ring-try-on'),
            ),
            const SizedBox(height: 16),
            ARFeatureCard(
              title: 'Body Tracking',
              subtitle: 'Full body pose detection',
              icon: Icons.accessibility,
              startColor: const Color(0xFF4CAF50),
              endColor: const Color(0xFF388E3C),
              onTap: () => context.go('/body-tracking'),
            ),
          ],
        ),
      ),
    );
  }
} 