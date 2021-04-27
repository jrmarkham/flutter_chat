import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat/src/data/services/auth_service.dart';
import 'package:chat/src/data/services/secure_storage_service.dart';
import 'package:chat/src/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import './bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  @override
  AuthState get initialState => AuthStateInit();
  AuthType _authType = AuthType.mobile;
  AuthStatus _authStatus = AuthStatus.notAuth;
  UserPropsObject _userProps;
  final BaseAuthServices _authServices = AuthServices();
  final BaseSecureStorageServices _secureStorageServices =
      SecureStorageServices();

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is AuthEventInit) {
      yield AuthStateLoading();
      // check auto login
      _authStatus = AuthStatus.notAuth;
      // get preference stuff
      // try login if there are credentials //
      FirebaseUser user = await _authServices.getCurrentUser();
      if (null != user && null != user.uid) _authStatus = AuthStatus.auth;
      yield AuthStateLoaded(_authStatus, _authType, _userProps);
    }

    if (event is AuthEventLogout) {
      yield AuthStateLoading();
      _userProps = null;
      await _authServices.logout();
      _secureStorageServices.clearAll();
      _authStatus = AuthStatus.notAuth;
      yield AuthStateLoaded(_authStatus, _authType, _userProps);
    }

    if (event is AuthEventReset) {
      yield AuthStateLoading();
      _authStatus = AuthStatus.notAuth;
      yield AuthStateLoaded(_authStatus, _authType, _userProps);
    }

    if (event is AuthEventSetAuthType) {
      yield AuthStateLoading();
      _authType = event.authType;
      yield AuthStateLoaded(_authStatus, _authType, _userProps);
    }

    // EMAIL EVENTS

    if (event is AuthEventInitEmailLogin) {
      yield AuthStateLoading();
      _userProps = event.userProps;
      _authStatus = await _authServices.emailInitAuth(event.email);
      // save email if link is sent
      if (_authStatus == AuthStatus.linkSent)
        await _secureStorageServices.setAuth(event.email);

      debugPrint(':::: AuthEventInitEmailLogin  ${_authStatus.toString()}');
      if (_authStatus == AuthStatus.error)
        yield AuthStateError(BlocError.authInitEmail);
      yield AuthStateLoaded(_authStatus, _authType, _userProps);
    }

    if (event is AuthEventGetDynamicLink) {
      if (AuthType.email != _authType) return;

      yield AuthStateLoading();
      _authStatus = AuthStatus.error;
      final String email = await _secureStorageServices.getAuth();
      if (email != null)
        _authStatus = await _authServices.getDynamicLink(email);

      if (_authStatus == AuthStatus.error)
        yield AuthStateError(BlocError.authDynamicLink);
      yield AuthStateLoaded(_authStatus, _authType, _userProps);
    }

    // MOBILE EVENTS
    if (event is AuthEventInitMobileLogin) {
      yield AuthStateLoading();
      _userProps = event.userProps;
      final PhoneVerificationCompleted _phoneVerificationCompleted =
          (AuthCredential phoneAuthCredential) {
        print('Received phone auth credential: $phoneAuthCredential');
      };

      final PhoneVerificationFailed _phoneVerificationFailed =
          (AuthException authException) {
        debugPrint(
            'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');

        add(AuthEventMobileFail());
      };

      _authStatus = await _authServices.mobileInitAuth(
          mobile: event.mobile,
          codeAutoRetrievalTimeout: event.codeAutoRetrievalTimeout,
          codeSent: event.codeSent,
          verificationCompleted: _phoneVerificationCompleted,
          verificationFailed: _phoneVerificationFailed);
      _secureStorageServices.setAuth(event.mobile);
      if (_authStatus == AuthStatus.error)
        yield AuthStateError(BlocError.authInitMobile);
      yield AuthStateLoaded(_authStatus, _authType, _userProps);
    }

    if (event is AuthEventVerifyMobile) {
      yield AuthStateLoading();
      _authStatus =
          await _authServices.mobileCompleteAuthCredentials(event.credential);

      if (_authStatus == AuthStatus.error)
      yield AuthStateError(BlocError.authMobileFail);
      yield AuthStateLoaded(_authStatus, _authType, _userProps);
    }

    if (event is AuthEventMobileFail) {
      _authStatus = AuthStatus.error;
      yield AuthStateError(BlocError.authMobileFail);
      yield AuthStateLoaded(_authStatus, _authType, _userProps);
    }
  }
}
