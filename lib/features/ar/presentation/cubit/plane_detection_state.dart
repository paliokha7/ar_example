import 'package:equatable/equatable.dart';

abstract class PlaneDetectionState extends Equatable {
  const PlaneDetectionState();

  @override
  List<Object?> get props => [];
}

class PlaneDetectionInitial extends PlaneDetectionState {
  const PlaneDetectionInitial();
}

class PlaneDetectionLoading extends PlaneDetectionState {
  const PlaneDetectionLoading();
}

class PlaneDetectionReady extends PlaneDetectionState {
  const PlaneDetectionReady();
}

class ChairPlaced extends PlaneDetectionState {
  const ChairPlaced();
}

class ChairRemoved extends PlaneDetectionState {
  const ChairRemoved();
}

class PlaneDetectionError extends PlaneDetectionState {
  final String message;

  const PlaneDetectionError(this.message);

  @override
  List<Object?> get props => [message];
} 