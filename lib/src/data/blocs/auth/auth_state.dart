import 'package:chat/src/globals.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthStateInit extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthStateLoading extends AuthState {
  @override
  List<Object> get props => [];
}



class AuthStateError extends AuthState {
  final BlocError error;
  AuthStateError(this.error);
  @override
  List<Object> get props => [error];
}


class AuthStateLoaded extends AuthState {
  final AuthStatus authStatus;
  final AuthType authType;
  final UserPropsObject userProps;
  AuthStateLoaded(this.authStatus, this.authType, this.userProps);
  @override
  List<Object> get props => [authStatus, authType, userProps];
}

