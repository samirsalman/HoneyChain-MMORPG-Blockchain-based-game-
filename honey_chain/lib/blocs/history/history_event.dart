part of 'history_bloc.dart';

abstract class HistoryEvent {
  const HistoryEvent();
}

class GetHistory implements HistoryEvent {
  String id;

  GetHistory(this.id);
}
