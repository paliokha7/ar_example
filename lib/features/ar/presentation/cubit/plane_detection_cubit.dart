import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ar_event.dart' as events;
import '../../domain/repositories/ar_repository.dart';
import 'plane_detection_state.dart';

class PlaneDetectionCubit extends Cubit<PlaneDetectionState> {
  final ARRepository _repository;
  StreamSubscription? _eventSubscription;

  PlaneDetectionCubit(this._repository) : super(const PlaneDetectionInitial());

  Future<void> initializeAR(int viewId) async {
    emit(const PlaneDetectionLoading());
    try {
      await _repository.initialize(viewId);
      _eventSubscription = _repository.events.listen(_handleEvent);
      emit(const PlaneDetectionReady());
    } catch (e) {
      emit(PlaneDetectionError(e.toString()));
    }
  }

  Future<void> placeChair() async {
    emit(const PlaneDetectionLoading());
    try {
      await _repository.placeChair();
    } catch (e) {
      emit(PlaneDetectionError(e.toString()));
    }
  }

  Future<void> removeChair() async {
    emit(const PlaneDetectionLoading());
    try {
      await _repository.removeChair();
    } catch (e) {
      emit(PlaneDetectionError(e.toString()));
    }
  }

  Future<void> resetSession() async {
    emit(const PlaneDetectionLoading());
    try {
      await _repository.resetSession();
      emit(const PlaneDetectionReady());
    } catch (e) {
      emit(PlaneDetectionError(e.toString()));
    }
  }

  void _handleEvent(dynamic event) {
    if (event is events.ChairPlaced) {
      emit(const ChairPlaced());
    } else if (event is events.ChairRemoved) {
      emit(const ChairRemoved());
    } else if (event is events.ARError) {
      emit(PlaneDetectionError(event.message));
    }
  }

  @override
  Future<void> close() async {
    await _eventSubscription?.cancel();
    await _repository.dispose();
    return super.close();
  }
} 