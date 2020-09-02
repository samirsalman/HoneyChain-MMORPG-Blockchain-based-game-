import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honeychain/blocs/session/bloc.dart';

class MakeDonationScreen extends StatefulWidget {
  @override
  _MakeDonationScreenState createState() => _MakeDonationScreenState();
}

class _MakeDonationScreenState extends State<MakeDonationScreen> {
  var objects = List();
  TextEditingController email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    objects = BlocProvider.of<UserSessionBloc>(context).gameObjects;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("Honey Chain"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Text(
                "Inserisci l'indirizzo email della persona a cui vuoi donare l'oggetto e successivamente scegli quale oggetto donare",
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(24),
            child: TextField(
              controller: email,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    borderSide: BorderSide(width: 3, style: BorderStyle.solid)),
                labelText: "Email",
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ),
          ListView.builder(
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  try {
                    await BlocProvider.of<UserSessionBloc>(context)
                        .makeTransaction(objects[index]["id"],
                            email.text.toLowerCase().trim());
                    BlocProvider.of<UserSessionBloc>(context)
                        .gameObjects
                        .removeAt(index);
                  } catch (e) {
                    print(e);
                  }
                  Navigator.pop(context);
                },
                child: Container(
                  child: Card(
                    color: Theme.of(context).primaryColor,
                    margin: EdgeInsets.all(24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24))),
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          "assets/honeys/${objects[index]["color"].toString().toLowerCase()}@2x.png",
                          height: MediaQuery.of(context).size.height * 0.12,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              objects[index]["id"],
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              objects[index]["power"].toString(),
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
                ),
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
