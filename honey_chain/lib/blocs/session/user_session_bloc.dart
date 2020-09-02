import 'dart:async';
import 'dart:convert';
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

    if (event is Login) {
      try {
        user = await doLogin(event.email, event.password);
        if (user != null) {
          gameObjects = await getUserObjects();
          totalPower = 0;
          for (var i in gameObjects) {
            totalPower += i["power"];
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
      var cookie = prefs.getString("cookie");
      print(cookie);
      if (cookie == null) {
        return false;
      } else {
        var expires = prefs.getString("expiresDate");

        if (DateTime.parse(expires).isAfter(DateTime.now())) {
          return true;
        } else
          return false;
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
            var expiresDate = DateTime.now().add(Duration(minutes: 30));
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

      var res = await Dio().get(
        "$HOST/user/login",
        options: Options(headers: {
          cookie: "login=$cookie",
          "Content-Type": "application/json",
          "Connection": "keep-alive"
        }),
      );

      await Dio().post("$SERVER/response/log", data: {
        "callName": "Login with cookie",
        "data": res.data,
        "statusCode": res.statusCode,
        "headers": res.headers
      }).timeout(Duration(seconds: 5), onTimeout: () async {
        await Dio().post("$HOST/response/log", data: {"response": "TIMEOUT"});
      });
      ;

      print(res.data);
      return json.decode(res.data);
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
    var res = await Dio()
        .get(
            "$HOST/user/register?email=${email.toString().trim()}&password=${password.toString().trim()}&name=$name&years=$date",
            options: Options(maxRedirects: 20, followRedirects: true, headers: {
              "Content-Type": "application/json",
              "Connection": "keep-alive"
            }))
        .timeout(Duration(seconds: 5), onTimeout: () async {
      await Dio().post("$HOST/response/log", data: {"response": "TIMEOUT"});
    });

    await Dio().post("$SERVER/response/log", data: {
      "callName": "Register",
      "data": res.data,
      "statusCode": res.statusCode,
      "headers": res.headers
    });
    print(res.headers);
    if (res.statusCode != 500) {
      print(res.data);
      return true;
    } else {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserObjects() async {
    var email = user["email"];
    try {
      var res = await http
          .get(
            "$HOST/user/getObjects?email=${email.toString().trim()}",
          )
          .timeout(Duration(seconds: 5), onTimeout: () async {});

      var items = List();

      var jsonData = json.decode(res.body);

      for (var item in jsonData) {
        /* if (item.owner == email) {
          items.add(item);
        }

        */
        items.add(item);
      }
      return items;
    } catch (e) {
      print(e);
      return List();
    }
  }

  Future<bool> makeTransaction(id, email) async {
    var res = await Dio()
        .get("$HOST/user/transaction?id=$id&email=${email.toString().trim()}",
            options: Options(headers: {
              "Content-Type": "application/json",
              "Connection": "keep-alive"
            }))
        .timeout(Duration(seconds: 5), onTimeout: () async {
      await Dio().post("$HOST/response/log", data: {"response": "TIMEOUT"});
    });
    await Dio().post("$SERVER/response/log", data: {
      "callName": "Make transaction",
      "data": res.data,
      "statusCode": res.statusCode,
      "headers": res.headers
    });
    if (res.statusCode != 500) {
      return true;
    } else {
      return false;
    }
  }
}
