import 'package:chat/src/data/services/user_service.dart';
import 'package:chat/src/globals.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class CurrentUserObject extends Equatable {
  final String id;
  final String authItem; // mobile or email
  final String name;
  final bool private;
  final bool globalAlert;
  final bool globalAlertOn;
  final List<String> friends;
  final List<String> invites;

  CurrentUserObject(
      {@required this.id,
      @required this.authItem,
      @required this.name,
      @required this.private,
      @required this.globalAlert,
      @required this.globalAlertOn,
      @required this.friends,
      @required this.invites});

  @override
  List<Object> get props =>
      [id, authItem, name, private, globalAlert, globalAlertOn, friends, invites];

  // TO MAP
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map[USER_AUTH_ITEM] = this.authItem;
    map[USER_NAME] = this.name;
    map[USER_PRIVATE] = this.private;
    map[USER_GLOBAL_ALERT] = this.globalAlert;
    map[USER_FRIENDS] = this.friends;
    map[USER_INVITES] = this.invites;
    // just uid
    return map;
  }
}

class UserObject extends Equatable {
  final String id;
  final String authItem; // mobile or email
  final String name;
  final bool private;
  final bool globalAlert;
  final List<String> invites; // received
  final FriendStatus friendStatus;
  final bool alert;

  UserObject(
      {@required this.id,
      @required this.authItem,
      @required this.name,
      @required this.private,
      @required this.globalAlert,
      @required this.invites,
      @required this.friendStatus,
      @required this.alert});

  @override
  List<Object> get props =>
      [id, authItem, name, private, invites, friendStatus, alert];
}

// SUBSET OF MUTABLE AND OPTIONAL ITEMS
class UserPropsObject extends Equatable {
  final String name;
  final bool private;

  UserPropsObject({@required this.name, @required this.private});

  @override
  List<Object> get props => [name, private];
}
