import 'dart:async';
import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryInitial());

  @override
  Stream<HistoryState> mapEventToState(
    HistoryEvent event,
  ) async* {
    if (event is GetHistory) {
      yield HistoryLoading();
      var history = await getHistory(event.id, event.host, event.email);

      if (history != null) {
        yield HistoryLoaded(history);
      } else {
        yield HistoryError("No history");
      }
    }
  }

  Future<List<dynamic>> getHistory(id, host, email) async {
    try {
      var res = await http.get("$host/history?id=$id&email=$email");

      print(res.body);

      var responseJson = json.decode(res.body);
      var history = List();

      for (var i = 0; i < responseJson.length; i++) {
        history.add(responseJson[i]);
      }

      return history;
    } catch (err) {
      print(err.toString());
      return null;
    }
  }
}
