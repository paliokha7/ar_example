import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../cubit/plane_detection_state.dart';

class ARControls extends StatelessWidget {
  final PlaneDetectionState state;
  final VoidCallback onPlaceChair;
  final VoidCallback onRemoveChair;
  final VoidCallback onReset;

  const ARControls({
    super.key,
    required this.state,
    required this.onPlaceChair,
    required this.onRemoveChair,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state is PlaneDetectionReady) ...[
            FloatingActionButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onPlaceChair();
              },
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 16),
          ],
          if (state is ChairPlaced) ...[
            FloatingActionButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onRemoveChair();
              },
              child: const Icon(Icons.remove),
            ),
            const SizedBox(height: 16),
          ],
          FloatingActionButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onReset();
            },
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
} 