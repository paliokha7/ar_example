import 'dart:async';
import 'dart:io';

import 'package:ar_flutter/core/services/arcore_platform_service.dart';
import 'package:ar_flutter/core/services/arkit_platform_service.dart';

abstract class ARPlatformService {
  Stream<Map<String, dynamic>> get events;
  void initialize(int viewId);
  Future<void> dispose();
  Future<void> addChairModel();
  Future<void> removeChairModel();
  Future<void> resetSession();
  String get viewType;
}

class UnifiedARPlatformService implements ARPlatformService {
  late final ARPlatformService _platformService;
  
  UnifiedARPlatformService() {
    if (Platform.isIOS) {
      _platformService = ARKitPlatformService();
    } else if (Platform.isAndroid) {
      _platformService = ARCorePlatformService();
    } else {
      throw UnsupportedError('Platform not supported for AR');
    }
  }
  
  @override
  Stream<Map<String, dynamic>> get events => _platformService.events;
  
  @override
  void initialize(int viewId) => _platformService.initialize(viewId);
  
  @override
  Future<void> dispose() => _platformService.dispose();
  
  @override
  Future<void> addChairModel() => _platformService.addChairModel();
  
  @override
  Future<void> removeChairModel() => _platformService.removeChairModel();
  
  @override
  Future<void> resetSession() => _platformService.resetSession();
  
  @override
  String get viewType => _platformService.viewType;
} 