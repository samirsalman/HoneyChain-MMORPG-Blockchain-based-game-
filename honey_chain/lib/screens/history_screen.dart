import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honeychain/blocs/history/history_bloc.dart';
import 'package:honeychain/blocs/session/bloc.dart';

class HistoryScreen extends StatefulWidget {
  String id;

  HistoryScreen(this.id);
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryBloc historyBloc;
  UserSessionBloc userSessionBloc;

  @override
  void initState() {
    historyBloc = BlocProvider.of<HistoryBloc>(context);
    userSessionBloc = BlocProvider.of<UserSessionBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      historyBloc.add(GetHistory(
          widget.id, userSessionBloc.HOST, userSessionBloc.user["email"]));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("Honey Chain"),
      ),
      body: BlocBuilder(
        cubit: historyBloc,
        // ignore: missing_return
        builder: (context, state) {
          if (state is HistoryLoaded) {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Image.asset(
                            "assets/buy.png",
                            width: MediaQuery.of(context).size.height * 0.1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            child: Text(
                              "Transazioni",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return state.history.length < 2
                            ? Container(
                                child: Card(
                                  margin: EdgeInsets.all(24),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(24))),
                                  child: ListTile(
                                      leading: Icon(Icons.compare_arrows),
                                      title: Text(
                                        "Object is of ${state.history[index]["data"]["owner"]}, only one owner from his creation",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      subtitle: Text(
                                        DateTime.fromMillisecondsSinceEpoch(
                                                state.history[index]
                                                        ["timestamp"]["seconds"]
                                                    ["low"])
                                            .toIso8601String(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.grey),
                                      )),
                                ),
                                width: MediaQuery.of(context).size.width * 0.8,
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                              )
                            : index < state.history.length - 1
                                ? Container(
                                    child: Card(
                                      margin: EdgeInsets.all(24),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(24))),
                                      child: ListTile(
                                          leading: Icon(Icons.compare_arrows),
                                          title: Text(
                                            "Da ${state.history[index]["data"]["owner"]} a ${state.history[index + 1]["data"]["owner"]}",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          subtitle: Text(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                    state.history[index]
                                                                ["timestamp"]
                                                            ["seconds"]["low"] *
                                                        1000)
                                                .toIso8601String(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.grey),
                                          )),
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                  )
                                : Container();
                      },
                      itemCount: state.history.length),
                ],
              ),
            );
          }

          if (state is HistoryLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is HistoryError) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                    size: MediaQuery.of(context).size.width * 0.3,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text(
                      "Errore:\n${state.message}",
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
