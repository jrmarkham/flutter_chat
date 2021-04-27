import 'dart:core';

import 'package:chat/src/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

const int TIMEOUT_SECONDS = 30;

abstract class BaseAuthServices {
  // EMAIL LOGIN
  Future<AuthStatus> emailInitAuth(String email);
  Future<AuthStatus> getDynamicLink(String email);

  // MOBILE LOGINS
  Future<AuthStatus> mobileInitAuth(
      {@required String mobile,
      @required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
      @required PhoneCodeSent codeSent,
      @required PhoneVerificationCompleted verificationCompleted,
      @required PhoneVerificationFailed verificationFailed});

  Future<AuthStatus> mobileCompleteAuthCredentials(AuthCredential credential);

  // GENERAL
  Future<FirebaseUser> getCurrentUser();
  logout();
}

class AuthServices extends BaseAuthServices {
  // static singleton
  static final AuthServices _instance = AuthServices.internal();
  factory AuthServices() => _instance;
  AuthServices.internal();
  FirebaseAuth _firebaseAuth() => FirebaseAuth.instance;
  FirebaseAuth get firebaseAuth => _firebaseAuth();

  // PUBLIC


  // EMAIL LOGIN
  Future<AuthStatus> emailInitAuth(String email) async {
    bool success = true;
    try {
      await firebaseAuth.sendSignInWithEmailLink(
          email: email,
          url: PROJECT_URL,
          handleCodeInApp: true,
          iOSBundleID: IOS_BUNDLE_ID,
          androidPackageName: ANDROID_PACKAGE_NAME,
          androidInstallIfNotAvailable: true,
          androidMinimumVersion: ANDROID_MIN_VERSION);
    } on PlatformException {
      debugPrint(':::: emailInitAuth error ');
      success = false;
      return AuthStatus.error;
    }
    debugPrint(':::: emailInitLogin no error ');
    return success ? AuthStatus.linkSent : AuthStatus.error;
  }

  Future<AuthStatus> getDynamicLink(String email) async {
    final PendingDynamicLinkData linkData =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = linkData?.link;
    debugPrint(
        ':::: getDynamicLink DEEP LINK TO STRING ${deepLink.toString()} ');
    if (deepLink == null) return AuthStatus.error;
    // used saved email here
    return _emailVerify(email, deepLink.toString());
  }

  Future<AuthStatus> _emailVerify(String email, String link) async {
    bool success = true;
    try {
      final AuthResult authResult = await firebaseAuth.signInWithEmailAndLink(email: email, link: link);
      if(authResult == null||authResult.user == null){
        success = false;
        return AuthStatus.error;
      }


      debugPrint(':::: link  ${link.toString()}');
      debugPrint(':::: auth uid = results  ${authResult.user.uid.toString()}');
      final FirebaseUser user = await getCurrentUser();
      debugPrint(':::: FirebaseUser user uid  ${user.uid}');

    } on PlatformException {
      debugPrint(':::: emailVerify error ');
      success = false;
      return AuthStatus.error;
    }

    return success ? AuthStatus.auth : AuthStatus.error;
  }

// MOBILE

  Future<AuthStatus> mobileInitAuth(
      {@required String mobile,
      @required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
      @required PhoneCodeSent codeSent,
      @required PhoneVerificationCompleted verificationCompleted,
      @required PhoneVerificationFailed verificationFailed}) async {
    bool success = true;

  //  try {
      await firebaseAuth.verifyPhoneNumber(
          phoneNumber: mobile,
          timeout: Duration(seconds: TIMEOUT_SECONDS),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout)
          .catchError((e) {
        debugPrint(':::: mobileInitAuth error ${e.toString()}');
//        success = false;
      });

    return success ? AuthStatus.smsSent : AuthStatus.error;
  }

  // COMPLETE MOBILE W/ CREDENTIALS
  Future<AuthStatus> mobileCompleteAuthCredentials(
      AuthCredential credential) async {
    bool success = true;

    debugPrint(':::: mobileCompleteAuthCredential ');
    try {
      final AuthResult authResult = await firebaseAuth.signInWithCredential(credential);
      if(authResult == null||authResult.user == null){
        success = false;
        return AuthStatus.error;
      }
      debugPrint(':::: credentials  ${credential.toString()}');
      debugPrint(':::: auth uid = results  ${authResult.user.uid.toString()}');
      final FirebaseUser user = await getCurrentUser();
      debugPrint(':::: FirebaseUser user uid  ${user.uid}');
    } on PlatformException {
      debugPrint(':::: mobileCompleteAuthCredential error ');
      success = false;
      return AuthStatus.error;
    }
    return success ? AuthStatus.auth : AuthStatus.error;
  }

  // GENERAL
  Future<FirebaseUser> getCurrentUser() async {
    return firebaseAuth.currentUser();
  }

  logout() async {
    await firebaseAuth.signOut();
  }
}

