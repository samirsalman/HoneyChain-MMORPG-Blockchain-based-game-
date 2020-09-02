import 'package:meta/meta.dart';

@immutable
abstract class UserSessionEvent {}

class StartApp extends UserSessionEvent {}

class LoadData extends UserSessionEvent {}

class GetObjects extends UserSessionEvent {}

class DataLoaded extends UserSessionEvent {}

class Login extends UserSessionEvent {
  String email;
  String password;
  Login(this.email, this.password);
}

class Register extends UserSessionEvent {
  String email;
  String password;
  String name;
  String date;

  Register(this.email, this.password, this.name, this.date);
}

class Logout extends UserSessionEvent {}
