import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ARKitView extends StatefulWidget {
  final Function(int) onViewCreated;

  const ARKitView({
    super.key,
    required this.onViewCreated,
  });

  @override
  State<ARKitView> createState() => _ARKitViewState();
}

class _ARKitViewState extends State<ARKitView> {
  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: 'arkit_flutter_plugin/view',
      onPlatformViewCreated: widget.onViewCreated,
      creationParams: const {},
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
} 