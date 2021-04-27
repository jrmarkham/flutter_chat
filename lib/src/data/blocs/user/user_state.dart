import 'package:chat/src/globals.dart';
import 'package:chat/src/data/models/user.dart';
import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  const UserState();
}

class UserStateInit extends UserState {
  @override
  List<Object> get props => [];
}


class UserStateLoading extends UserState {
  @override
  List<Object> get props => [];
}

class UserStateLoaded extends UserState {
  final CurrentUserObject user;
  final List<UserObject> userList;
  UserStateLoaded(this.user, this.userList);

  @override
  List<Object> get props => [user, userList];
}

class UserStateError extends UserState {
  final BlocError error;
  UserStateError(this.error);
  @override
  List<Object> get props => [error];
}


class UserStateLogout extends UserState {
  @override
  List<Object> get props => [];
}