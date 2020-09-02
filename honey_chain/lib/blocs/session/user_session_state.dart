import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class UserSessionState {}

class Starting extends UserSessionState implements Equatable {
  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();

  @override
  // TODO: implement stringify
  bool get stringify => throw UnimplementedError();
}

class Loading extends UserSessionState implements Equatable {
  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();

  @override
  // TODO: implement stringify
  bool get stringify => throw UnimplementedError();
}

class Ready extends UserSessionState implements Equatable {
  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();

  @override
  // TODO: implement stringify
  bool get stringify => throw UnimplementedError();
}

class Logged extends UserSessionState implements Equatable {
  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();

  @override
  // TODO: implement stringify
  bool get stringify => throw UnimplementedError();
}

class UnLogged extends UserSessionState implements Equatable {
  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();

  @override
  // TODO: implement stringify
  bool get stringify => throw UnimplementedError();
}
