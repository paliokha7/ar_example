import 'dart:async';
import 'package:flutter/services.dart';
import 'ar_platform_service.dart';

class ARCorePlatformService implements ARPlatformService {
  static const String _channelName = 'arcore_flutter_plugin';
  static const String _viewType = 'arcore_flutter_plugin/view';

  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  
  @override
  Stream<Map<String, dynamic>> get events => _eventController.stream;

  MethodChannel? _channel;
  int? _viewId;

  @override
  String get viewType => _viewType;

  @override
  void initialize(int viewId) {
    _viewId = viewId;
    _channel = MethodChannel('$_channelName/$viewId');
    _channel?.setMethodCallHandler(_handleMethodCall);
  }

  @override
  Future<void> dispose() async {
    await _eventController.close();
    _channel = null;
    _viewId = null;
  }

  @override
  Future<void> addChairModel() async {
    try {
      await _channel?.invokeMethod('addChairModel');
    } on PlatformException catch (e) {
      _eventController.add({
        'type': 'error',
        'message': e.message ?? 'Failed to add chair model',
      });
    }
  }

  @override
  Future<void> removeChairModel() async {
    try {
      await _channel?.invokeMethod('removeChairModel');
    } on PlatformException catch (e) {
      _eventController.add({
        'type': 'error',
        'message': e.message ?? 'Failed to remove chair model',
      });
    }
  }

  @override
  Future<void> resetSession() async {
    try {
      await _channel?.invokeMethod('resetSession');
    } on PlatformException catch (e) {
      _eventController.add({
        'type': 'error',
        'message': e.message ?? 'Failed to reset session',
      });
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onChairPlaced':
        _eventController.add({'type': 'chairPlaced'});
        break;
      case 'onChairRemoved':
        _eventController.add({'type': 'chairRemoved'});
        break;
      case 'onError':
        _eventController.add({
          'type': 'error',
          'message': call.arguments?['message'] as String? ?? 'Unknown error occurred',
        });
        break;
      default:
        throw PlatformException(
          code: 'notImplemented',
          message: 'Method ${call.method} not implemented',
        );
    }
  }
} 