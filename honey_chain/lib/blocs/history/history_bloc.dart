import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryInitial());

  @override
  Stream<HistoryState> mapEventToState(HistoryEvent event,) async* {
    if (event is GetHistory) {
      yield HistoryLoading();
      var history = await getHistory(event.id);

      if (history != null) {
        yield HistoryLoaded(history);
      } else {
        yield HistoryError("No history");
      }
    }
  }


  Future<Map<String,dynamic>> getHistory(id) async{

  }
}
