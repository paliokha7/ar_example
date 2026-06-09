import 'dart:async';
import '../entities/ar_event.dart';

abstract class ARRepository {
  Stream<AREvent> get events;
  Future<void> initialize(int viewId);
  Future<void> dispose();
  Future<void> placeChair();
  Future<void> removeChair();
  Future<void> resetSession();
} 