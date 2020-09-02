import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honeychain/blocs/session/bloc.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).backgroundColor,
          statusBarIconBrightness: Brightness.dark),
    );
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "./assets/logo.png",
            height: MediaQuery.of(context).size.width * 0.5,
            width: MediaQuery.of(context).size.width * 0.5,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Text(
              "HoneyChain",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
              height: 55,
              margin: EdgeInsets.all(24),
              width: MediaQuery.of(context).size.width * 0.8,
              child: RaisedButton(
                  child: Text("Definisci Indirizzo"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24))),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController controller =
                              TextEditingController();
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(24))),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  child: TextField(
                                    decoration: InputDecoration(
                                        labelText: "LocalHost Address",
                                        icon: Icon(Icons.repeat),
                                        border: InputBorder.none),
                                    controller: controller,
                                  ),
                                  margin: EdgeInsets.all(24),
                                ),
                                Container(
                                  height: 55,
                                  child: RaisedButton(
                                    onPressed: () {
                                      BlocProvider.of<UserSessionBloc>(context)
                                          .HOST = controller.text.trim();
                                      Navigator.pop(context);
                                      BlocProvider.of<UserSessionBloc>(context)
                                          .add(LoadData());
                                    },
                                    child: Text("Conferma"),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(24))),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                )
                              ],
                            ),
                          );
                        });
                  }))
        ],
      ),
    ));
  }
}
