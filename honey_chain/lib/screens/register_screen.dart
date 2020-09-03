import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honeychain/blocs/session/bloc.dart';
import 'package:honeychain/screens/login.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController years = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Honey Chain"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
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
          listenWhen: (previous, current) {
            if (previous is UnLogged && current is RegistrationSuccess) {
              Navigator.pop(context);
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Image.asset("./assets/logo.png"),
                Container(
                  margin: EdgeInsets.all(16),
                  child: TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide:
                              BorderSide(width: 3, style: BorderStyle.solid)),
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(16),
                  child: TextField(
                    controller: password,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide:
                              BorderSide(width: 3, style: BorderStyle.solid)),
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(16),
                  child: TextField(
                    controller: name,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide:
                              BorderSide(width: 3, style: BorderStyle.solid)),
                      labelText: "Nome Giocatore",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(16),
                  child: TextField(
                    controller: years,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide:
                              BorderSide(width: 3, style: BorderStyle.solid)),
                      labelText: "Età",
                      prefixIcon: Icon(Icons.plus_one),
                    ),
                  ),
                ),
                Container(
                  height: 55,
                  margin: EdgeInsets.only(bottom: 24, top: 24),
                  child: RaisedButton(
                    onPressed: () {
                      BlocProvider.of<UserSessionBloc>(context).add(Register(
                          email.text.trim(),
                          password.text.trim(),
                          name.text.trim(),
                          years.text.trim()));
                    },
                    child: Text("Registrati"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24))),
                    color: Theme.of(context).primaryColor,
                  ),
                  width: MediaQuery.of(context).size.width * 0.8,
                ),
              ],
            ),
          ),
        ));
  }
}
