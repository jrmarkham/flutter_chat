import 'package:chat/src/globals.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class AuthEventInit extends AuthEvent {
  @override
  List<Object> get props => [];
}


class AuthEventLogout extends AuthEvent {
  @override
  List<Object> get props => [];
}



class AuthEventSetAuthType extends AuthEvent {
  final AuthType authType;

  AuthEventSetAuthType(this.authType);

  @override
  List<Object> get props => [authType];
}

class AuthEventGetDynamicLink extends AuthEvent {
  @override
  List<Object> get props => [];
}

class AuthEventInitEmailLogin extends AuthEvent {
  final String email;
  final UserPropsObject userProps;

  AuthEventInitEmailLogin(this.email, this.userProps);

  @override
  List<Object> get props => [email, userProps];
}

class AuthEventInitMobileLogin extends AuthEvent {
  final String mobile;
  final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout;
  final PhoneCodeSent codeSent;
  final UserPropsObject userProps;

  AuthEventInitMobileLogin(
      {@required this.mobile,
      @required this.userProps,
      @required this.codeAutoRetrievalTimeout,
      @required this.codeSent});

  @override
  List<Object> get props =>
      [mobile, userProps, codeAutoRetrievalTimeout, codeSent];
}

class AuthEventVerifyMobile extends AuthEvent {
  final AuthCredential credential;
  AuthEventVerifyMobile(this.credential);

  @override
  List<Object> get props => [credential];
}

class AuthEventReset extends AuthEvent {
  @override
  List<Object> get props => [];
}

class AuthEventMobileFail extends AuthEvent {
  @override
  List<Object> get props => [];
}
