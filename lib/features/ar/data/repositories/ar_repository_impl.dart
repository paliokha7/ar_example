import 'dart:async';
import '../../domain/entities/ar_event.dart';
import '../../domain/repositories/ar_repository.dart';
import '../../../../core/services/ar_platform_service.dart';

class ARRepositoryImpl implements ARRepository {
  final UnifiedARPlatformService _platformService;

  ARRepositoryImpl(this._platformService);

  @override
  Stream<AREvent> get events => _platformService.events.map((event) {
        switch (event['type']) {
          case 'chairPlaced':
            return const ChairPlaced();
          case 'chairRemoved':
            return const ChairRemoved();
          case 'error':
            return ARError(event['message'] as String);
          default:
            return ARError('Unknown event type: ${event['type']}');
        }
      });

  @override
  Future<void> initialize(int viewId) async {
    _platformService.initialize(viewId);
  }

  @override
  Future<void> dispose() async {
    await _platformService.dispose();
  }

  @override
  Future<void> placeChair() async {
    await _platformService.addChairModel();
  }

  @override
  Future<void> removeChair() async {
    await _platformService.removeChairModel();
  }

  @override
  Future<void> resetSession() async {
    await _platformService.resetSession();
  }
} 