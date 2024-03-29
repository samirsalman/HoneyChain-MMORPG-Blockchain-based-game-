import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './bloc.dart';
import "package:http/http.dart" as http;

class UserSessionBloc extends Bloc<UserSessionEvent, UserSessionState> {
  UserSessionBloc(UserSessionState initialState) : super(initialState);

  var HOST = "192.168.1.1";
  var SERVER = "http://192.168.1.2:3000";
  var user = null;
  var lastHost = null;
  var totalPower = 0;
  SharedPreferences prefs;
  var gameObjects = List();

  @override
  Stream<UserSessionState> mapEventToState(
    UserSessionEvent event,
  ) async* {
    if (event is StartApp) {
      prefs = await SharedPreferences.getInstance();
      lastHost = prefs.getString("lastHost");
      print(lastHost);
      yield (Starting());
    }

    if (event is ErrorOccourred) {
      yield (Error(event.error));
    }

    if (event is LoadData) {
      prefs = await SharedPreferences.getInstance();
      prefs.setString("lastHost", HOST.trim());
      var isCookieValid = await verifyCookie();
      if (isCookieValid) {
        user = await doLoginWithCookie();
        gameObjects = await getUserObjects();
      }
      if (user == null) {
        yield (UnLogged());
      } else {
        yield (Logged());
      }
    }

    if (event is UpdateObjects) {
      gameObjects = await getUserObjects();
      yield (Logged());
    }

    if (event is Login) {
      try {
        user = await doLogin(event.email, event.password);
        if (user != null) {
          gameObjects = await getUserObjects();
          totalPower = 0;
          for (var i = 0; i < gameObjects.length; i++) {
            totalPower += gameObjects[i]["Record"]["power"];
          }
          yield (Logged());
        }
      } catch (e) {
        print(e);
      }
    }

    if (event is Logout) {
      await doLogout();
      user = null;
      yield (UnLogged());
    }

    if (event is Register) {
      try {
        var response = await registerUser(
            event.email, event.password, event.name, event.date);
        if (response) {
          yield (RegistrationSuccess());
        }
      } catch (e) {
        print(e);
      }
    }

    if (event is GetObjects) {
      gameObjects = await getUserObjects();

      yield (Logged());
    }
  }

  Future<bool> verifyCookie() async {
    try {
      prefs = await SharedPreferences.getInstance();

      var cookie = prefs.getString("cookie");
      print(cookie);
      if (cookie == null) {
        return false;
      } else {
        var expires = prefs.getString("expires");

        if (DateTime.parse(expires).isAfter(DateTime.now())) {
          return true;
        } else {
          await prefs.clear();
          return false;
        }
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<Map<String, dynamic>> doLogin(email, password) async {
    //return {"email": "samirsalman@gmail.com", "years": 22, "name": "Samir"};

    // use the client, eg.:
    // new MyServiceClient(client)

    if (email.toString().trim().length == 0) {
      this.add(ErrorOccourred("Inserisci una email"));
      return null;
    }
    if (password.toString().trim().length == 0) {
      this.add(ErrorOccourred("Inserisci una password"));
      return null;
    }

    prefs = await SharedPreferences.getInstance();
    var res = await http
        .get(
      "$HOST/user/login?email=$email&password=$password",
    )
        .catchError((err) {
      this.add(ErrorOccourred(err.toString()));
      return;
    })
        // ignore: missing_return
        .timeout(Duration(seconds: 5), onTimeout: () async {});

    var cookie = res.headers["cookie"];
    if (res.statusCode == 200) {
      if (cookie != null) {
        cookie = cookie.split("login=")[1];
        print(cookie);
        try {
          var expiresDate = DateTime.now().add(Duration(seconds: 180));
          prefs.setString("expires", expiresDate.toIso8601String());
          prefs.setString("cookie", cookie);
        } catch (e) {
          this.add(ErrorOccourred(e.toString()));

          print(e);
        }
      }
      return json.decode(res.body.toString());
    } else {
      print(res.body);
      this.add(ErrorOccourred(json.decode(res.body)["error"]));
      print("No user");
      return null;
    }
  }

  Future<Map<String, dynamic>> doLoginWithCookie() async {
    var expiresDate = prefs.getString("expires");
    if (expiresDate != null &&
        DateTime.now().isBefore(DateTime.parse(expiresDate))) {
      var cookie = prefs.getString("cookie");

      HttpClient httpClient = HttpClient();
      var request =
          await httpClient.openUrl("GET", Uri.parse("$HOST/user/login"));
      request.cookies.add(Cookie("login", cookie));

      var res = await request.close();
      var bodyString = "";
      await res.transform(utf8.decoder).listen((data) {
        print(data);
        bodyString = data;
      }).asFuture();

      print(bodyString);
      return json.decode(bodyString);
    } else {
      return null;
    }
  }

  Future<String> doLogout() async {
    var res = await http.get("$HOST/user/login/logout");
    print(res.body);
    await prefs.clear();
    return res.body;
  }

  Future doLog() async {
    await Dio()
        .post("$HOST/response/log", data: {"response": "LOG BUTTON PRESSED"});
  }

  Future<bool> registerUser(email, password, name, date) async {
    if (email.toString().trim().length == 0) {
      this.add(ErrorOccourred("Inserisci una email"));
      return null;
    }
    if (password.toString().trim().length == 0) {
      this.add(ErrorOccourred("Inserisci una password"));
      return null;
    }
    if (name.toString().trim().length == 0) {
      this.add(ErrorOccourred("Inserisci un nome"));
      return null;
    }
    if (date.toString().trim().length == 0) {
      this.add(ErrorOccourred("Inserisci la tua età"));
      return null;
    }

    var res = await http
        .get(
          "$HOST/user/register?email=${email.toString().trim()}&password=${password.toString().trim()}&name=$name&years=$date",
        )
        .timeout(Duration(seconds: 5), onTimeout: () async {});

    print(res.headers);
    if (res.statusCode == 200) {
      print(res.body);
      return true;
    } else {
      this.add(ErrorOccourred(json.decode(res.body)["error"]));
      return false;
    }
  }

  Future<List<dynamic>> getUserObjects() async {
    var email = user["email"];
    try {
      var res = await http
          .get(
            "$HOST/user/getObjects?email=${email.toString().trim()}",
          )
          .timeout(Duration(seconds: 5), onTimeout: () async {});
      print(res.body.toString());
      var items = List();

      var jsonData = json.decode(res.body);

      totalPower = 0;
      for (var i = 0; i < jsonData.length; i++) {
        if (jsonData[i]["Record"]["owner"] == email) {
          totalPower += jsonData[i]["Record"]["power"];
          items.add(jsonData[i]);
        }

        //items.add(jsonData[i]);
      }
      return items;
    } catch (e) {
      print(e);
      return List();
    }
  }

  Future<bool> makeTransaction(id, email) async {
    var res = await http
        .get(
          "$HOST/user/transaction?id=$id&email=${email.toString().trim()}",
        )
        .timeout(Duration(seconds: 5), onTimeout: () async {});

    if (res.statusCode != 500) {
      totalPower -= gameObjects.where((element) => element["Key"] == id).first;

      return true;
    } else {
      return false;
    }
  }
}
