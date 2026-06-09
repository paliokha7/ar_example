import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'dart:io';

class UnifiedARView extends StatefulWidget {
  final Function(int) onViewCreated;

  const UnifiedARView({
    Key? key,
    required this.onViewCreated,
  }) : super(key: key);

  @override
  State<UnifiedARView> createState() => _UnifiedARViewState();
}

class _UnifiedARViewState extends State<UnifiedARView> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return UiKitView(
        viewType: 'arkit_flutter_plugin/view',
        onPlatformViewCreated: widget.onViewCreated,
        creationParams: const {},
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (Platform.isAndroid) {
      return AndroidView(
        viewType: 'arcore_flutter_plugin/view',
        onPlatformViewCreated: widget.onViewCreated,
      );
    } else {
      return const Center(
        child: Text('AR not supported on this platform'),
      );
    }
  }
} 