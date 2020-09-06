import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honeychain/blocs/session/bloc.dart';

class HistoryScreen extends StatefulWidget {
  int index;

  HistoryScreen(this.index);
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  UserSessionBloc userSessionBloc;

  @override
  void initState() {
    userSessionBloc = BlocProvider.of<UserSessionBloc>(context);
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
        builder: (context, state) {
          if (state is HistoryLoaded) {
            return ListView.builder(
                itemBuilder: (context, index) {
                  return Container(
                    child: Card(
                      color: Theme.of(context).primaryColor,
                      margin: EdgeInsets.all(24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24))),
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            "assets/honeys/${userSessionBloc.gameObjects[index]["Record"]["color"].toString().toLowerCase()}@2x.png",
                            height: MediaQuery.of(context).size.height * 0.12,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                userSessionBloc.gameObjects[index]["Key"],
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                userSessionBloc.gameObjects[index]["Record"]
                                        ["power"]
                                    .toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.2,
                  );
                },
                itemCount: state.history.length);
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
