import 'package:chat/src/globals.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';


abstract class UserEvent extends Equatable {
  const UserEvent();
}

class UserEventInit extends UserEvent {
  final UserPropsObject userProps;
  UserEventInit(this.userProps);

  @override
  List<Object> get props => [userProps];
}

class UserEventRefresh extends UserEvent {
  @override
  List<Object> get props => [];
}

class UserEventLogout extends UserEvent {
  @override
  List<Object> get props => [];
}

class UserEventToggleGlobalChat extends UserEvent {
  @override
  List<Object> get props => [];
}

class UserEventUpdateUser extends UserEvent {
  final UserPropsObject userProps;
  UserEventUpdateUser(this.userProps);

  @override
  List<Object> get props => [userProps];
}

class UserEventChatInvite extends UserEvent {
  final String uid;
  UserEventChatInvite(this.uid);

  @override
  List<Object> get props => [uid];
}

class UserEventAddMessageAlert extends UserEvent {
  final String userId;
  UserEventAddMessageAlert(this.userId);

  @override
  List<Object> get props => [userId];
}

class UserEventRemoveMessageAlert extends UserEvent {
  final String userId;
  UserEventRemoveMessageAlert(this.userId);

  @override
  List<Object> get props => [userId];
}

class UserEventAddGlobalAlert extends UserEvent {
  @override
  List<Object> get props => [];
}
class UserEventRemoveGlobalAlert extends UserEvent {
  @override
  List<Object> get props => [];
}


 // FRIEND UPDATE
class UserEventFriendUpdate extends UserEvent {
  final String friendId;
  final FriendAction friendAction;
  final FriendStatus friendStatus;
  UserEventFriendUpdate({@required this.friendId, @required this.friendAction, @required this.friendStatus});

  @override
  List<Object> get props => [friendId, friendAction, friendStatus];
}