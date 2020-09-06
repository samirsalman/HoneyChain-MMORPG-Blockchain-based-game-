part of 'history_bloc.dart';

abstract class HistoryEvent {
  const HistoryEvent();
}

class GetHistory implements HistoryEvent {
  String id;
  String host;
  String email;


  GetHistory(this.id,this.host,this.email);
}
