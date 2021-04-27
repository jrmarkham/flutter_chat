
// LABELS AND BUTTONS
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String title = 'chat';



const String ERROR_MOBILE = 'Phone is incorrect';
const String ERROR_EMAIL = 'Email is incorect';
const String ENTER_NAME = 'Please enter a display name';
const String ENTER_MOBILE = 'Please enter your phone';
const String ENTER_EMAIL = 'Please enter your email';
const String ENTER_CHAT = 'Chat message . . .';
const String USE_MOBILE = 'Use phone instead';
const String USE_EMAIL = 'Use email instead';
const String SUBMIT = 'submit';
const String SEND = 'send';
const String DELETE = 'delete';
const String UPDATE = 'update';
const String LOGOUT = 'logout';
const String LABEL_NAME = 'Display Name';
const String LABEL_GLOBAL_CHAT = 'Global Chat Alerts';
const String LABEL_EMAIL = 'Email';
const String LABEL_PRIVACY = 'Privacy';
const String LABEL_MOBILE = 'Phone';
const String LABEL_CHAT = 'Chat';
const String SENT_EMAIL = 'Check your email for the confirmation link';
const String ERROR = 'Please check the input field';
const String VERIFICATION_FAILED = 'Verification failed';
const String THANK_YOU = 'Thank you for authenticating!';
// PAGES
const String HOME = 'Home';
const String PROFILE = 'Update Your Profile';
const String CHAT = 'Chat';
const String AUTH = 'Loging / Sign Up';
// ALERTS
const String OK = 'ok';
const String CANCEL = 'cancel';
const String CONFIRM = 'confirm';

// SETTINGS
const String PROJECT_URL = 'https://megasandbox.page.link/jdF1';

//const String PROJECT_URL = 'https://mega-sandbox.firebaseapp.com';

const String ANDROID_PACKAGE_NAME = 'sandbox.markhamenterprises.chat';
const String IOS_BUNDLE_ID = 'sandbox.markhamenterprises.chat';
const String ANDROID_MIN_VERSION = '21';
const int TIMEOUT = 90;

// ICONS
final IconData iconProfile = Platform.isIOS ? CupertinoIcons.person :  Icons.person;
final IconData iconHome = Platform.isIOS ? CupertinoIcons.home :  Icons.home;
final IconData iconChat = Platform.isIOS ? CupertinoIcons.conversation_bubble :  Icons.chat_bubble;
final IconData iconPost = Platform.isIOS ? CupertinoIcons.up_arrow : Icons.arrow_upward;

// INVITES
final IconData iconAddFriend = Platform.isIOS ? CupertinoIcons.add :  Icons.add;
final IconData iconRemoveFriend = Platform.isIOS ? CupertinoIcons.delete :  Icons.delete;
final IconData iconAcceptFriend = Platform.isIOS ? CupertinoIcons.check_mark_circled :  Icons.check_circle;
final IconData iconDeclineFriend = Platform.isIOS ? CupertinoIcons.clear_circled :  Icons.highlight_off;
final IconData iconGCOff = Platform.isIOS ?  CupertinoIcons.minus_circled : Icons.remove_circle;
final IconData iconGCOn = Platform.isIOS ?  CupertinoIcons.add_circled : Icons.add_circle;