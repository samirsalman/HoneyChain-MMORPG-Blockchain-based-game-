import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honeychain/blocs/session/bloc.dart';
import 'package:honeychain/screens/register_screen.dart';

class LoginScreen extends StatelessWidget {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("Honey Chain"),
      ),
      body: BlocListener<UserSessionBloc, UserSessionState>(
        listener: (context, state) {
          if (state is Error) {
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(
                state.error,
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ));
          }
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset("./assets/logo.png"),
              Container(
                margin: EdgeInsets.all(24),
                child: TextField(
                  controller: email,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        borderSide:
                            BorderSide(width: 3, style: BorderStyle.solid)),
                    labelText: "Email",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(24),
                child: TextField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide:
                              BorderSide(width: 3, style: BorderStyle.solid)),
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock)),
                ),
              ),
              Container(
                height: 55,
                margin: EdgeInsets.only(bottom: 24),
                child: RaisedButton(
                  onPressed: () {
                    BlocProvider.of<UserSessionBloc>(context)
                        .add(Login(email.text.trim(), password.text.trim()));
                  },
                  child: Text("Accedi"),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24))),
                  color: Theme.of(context).primaryColor,
                ),
                width: MediaQuery.of(context).size.width * 0.8,
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 55,
                  margin: EdgeInsets.only(bottom: 24),
                  child: OutlineButton(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24))),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ));
                    },
                    child: Text("Registrati"),
                  )),
              Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 55,
                  margin: EdgeInsets.only(bottom: 24),
                  child: OutlineButton(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24))),
                    onPressed: () async {
                      await BlocProvider.of<UserSessionBloc>(context).doLog();
                    },
                    child: Text("LOG"),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
