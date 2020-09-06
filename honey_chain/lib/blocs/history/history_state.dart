part of 'history_bloc.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();
}

class HistoryInitial extends HistoryState {
  @override
  List<Object> get props => [];
}

class HistoryLoading extends HistoryState {
  @override
  List<Object> get props => [];
}

class HistoryError extends HistoryState {
  String message;

  HistoryError(this.message);

  @override
  List<Object> get props => [];
}

class HistoryLoaded extends HistoryState {
  Map<String, dynamic> history;

  HistoryLoaded(this.history);

  @override
  List<Object> get props => [];
}
