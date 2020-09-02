import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honeychain/blocs/session/bloc.dart';

class GameObjectsScreen extends StatelessWidget {
  var objects = List();

  @override
  Widget build(BuildContext context) {
    objects = BlocProvider.of<UserSessionBloc>(context).gameObjects;

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
                    "assets/objective.png",
                    width: MediaQuery.of(context).size.height * 0.1,
                  ),
                ),
                Container(
                  child: Text(
                    "I tuoi oggetti",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
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
                        "assets/honeys/${objects[index]["Record"]["color"].toString().toLowerCase()}@2x.png",
                        height: MediaQuery.of(context).size.height * 0.12,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            objects[index]["Key"],
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            objects[index]["Record"]["power"].toString(),
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
            itemCount: objects.length,
            shrinkWrap: true,
          )
        ],
      ),
    );
  }
}
