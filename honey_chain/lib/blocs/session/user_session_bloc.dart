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
  var totalPower = 0;
  SharedPreferences prefs;
  var gameObjects = List();
  var log = "";

  @override
  Stream<UserSessionState> mapEventToState(
    UserSessionEvent event,
  ) async* {
    if (event is StartApp) {
      prefs = await SharedPreferences.getInstance();
    }

    if (event is LoadData) {
      var isCookieValid = await verifyCookie();
      if (isCookieValid) {
        user = await doLoginWithCookie();
      }
      if (user == null) {
        yield (UnLogged());
      } else {
        yield (Logged());
      }
    }

    if (event is UpdateObjects) {
      gameObjects = await getUserObjects();
      yield (Ready());
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
        await registerUser(event.email, event.password, event.name, event.date);
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

    try {
      prefs = await SharedPreferences.getInstance();
      var res = await http
          .get(
            "$HOST/user/login?email=" + email + "&password=" + password,
          )
          .catchError((err) async {})
          // ignore: missing_return
          .timeout(Duration(seconds: 5), onTimeout: () async {});

      var cookie = res.headers["cookie"].split("login=")[1];
      if (res.statusCode != 500) {
        if (cookie != null) {
          print(cookie);
          try {
            var expiresDate = DateTime.now().add(Duration(seconds: 180));
            prefs.setString("expires", expiresDate.toIso8601String());
            prefs.setString("cookie", cookie);
          } catch (e) {
            print(e);
          }
        }
        return json.decode(res.body.toString());
      } else {
        print("No user");
        return null;
      }
    } catch (e) {
      print(e);
      await Dio().post("$HOST/response/log", data: {"response": e});
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
    var res = await Dio().get("$HOST/user/login/logout");
    print(res.data);
    await prefs.clear();
    return res.data;
  }

  Future doLog() async {
    await Dio()
        .post("$HOST/response/log", data: {"response": "LOG BUTTON PRESSED"});
  }

  Future<bool> registerUser(email, password, name, date) async {
    var res = await http
        .get(
          "$HOST/user/register?email=${email.toString().trim()}&password=${password.toString().trim()}&name=$name&years=$date",
        )
        .timeout(Duration(seconds: 5), onTimeout: () async {});

    print(res.headers);
    if (res.statusCode != 500) {
      print(res.body);
      return true;
    } else {
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

      for (var i = 0; i < jsonData.length; i++) {
        /* if (item.owner == email) {
          items.add(item);
        }

        */
        items.add(jsonData[i]);
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
      return true;
    } else {
      return false;
    }
  }
}
