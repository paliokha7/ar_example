import 'package:equatable/equatable.dart';

abstract class AREvent extends Equatable {
  const AREvent();

  @override
  List<Object?> get props => [];
}

class ChairPlaced extends AREvent {
  const ChairPlaced();
}

class ChairRemoved extends AREvent {
  const ChairRemoved();
}

class ARError extends AREvent {
  final String message;

  const ARError(this.message);

  @override
  List<Object?> get props => [message];
} 