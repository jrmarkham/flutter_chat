import 'package:chat/src/data/services/chat_service.dart';
import 'package:chat/src/data/services/user_service.dart';
import 'package:chat/src/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

// CHAT MODELS
class ChatStreamObject extends Equatable {
  final String id;
  final UserObject user;
  ChatStreamObject({@required this.id, @required this.user});

  @override
  List<Object> get props => [id, user];

  // MAP FOR USER DATA
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map[USER_CHAT_STREAM_ID] = this.id;
    map[USER_ID] = this.user.id;
  }
}

// MESSAGE OBJECTS
class MessageObject extends Equatable {
  final String id;
  final String userId;
  final bool currentUser;
  final String userName;
  final MessageType messageType; // type
  final String content;
  final Timestamp date;

  MessageObject(
      {@required this.id,
      @required this.userId,
      @required this.userName,
      @required this.currentUser,
      @required this.messageType,
      @required this.content,
      @required this.date});

  @override
  List<Object> get props =>
      [id, userId, userName, currentUser, messageType, content, date];
}

// POST MESSAGE
class MessagePostObject extends Equatable {
  final String userId;
  final MessageType messageType; // type
  final String content; // content
  final FieldValue date;

  MessagePostObject(
      {@required this.userId,
      @required this.messageType,
      @required this.content,
      this.date});

  @override
  List<Object> get props => [userId, messageType, content];

  // TO MAP
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map[MESSAGE_USER_ID] = this.userId;
    map[MESSAGE_TYPE] = this.messageType.index;
    map[MESSAGE_CONTENT] = this.content;
    map[MESSAGE_DATE] = this.date;
    return map;
  }
}

// PROPS
class MessagePropsObject extends Equatable {
  final MessageType messageType; // type
  final String content; // content
  MessagePropsObject({@required this.messageType, @required this.content});

  @override
  List<Object> get props => [messageType, content];
}
