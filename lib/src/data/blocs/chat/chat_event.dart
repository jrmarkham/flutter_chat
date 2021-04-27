import 'package:chat/src/globals.dart';
import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
}


class ChatEventInit extends ChatEvent{
  final CurrentUserObject currentUser;
  final List<UserObject> userList;
  final Nav nav;
  ChatEventInit(this.currentUser, this.userList, this.nav);
  @override
  List<Object> get props => [currentUser, userList, nav];
}

class ChatEventLogout extends ChatEvent{
  @override
  List<Object> get props => [];
}

class ChatEventRemoveAlert extends ChatEvent{
  @override
  List<Object> get props => [];
}

class ChatEventRemoveGlobalAlert extends ChatEvent{
  @override
  List<Object> get props => [];
}

class ChatEventRefresh extends ChatEvent{
  @override
  List<Object> get props => [];
}

class ChatEventOpenGlobalChat extends ChatEvent{
  @override
  List<Object> get props => [];
}

class ChatEventCreateChat extends ChatEvent{
  final String uid;
  ChatEventCreateChat(this.uid);

  @override
  List<Object> get props => [uid];
}



class ChatEventAccept extends ChatEvent{
  final String uid;
  ChatEventAccept(this.uid);

  @override
  List<Object> get props => [uid];
}

class ChatEventStreamChat extends ChatEvent{
  final ChatStreamObject chatStreamObj;
  ChatEventStreamChat(this.chatStreamObj);

  @override
  List<Object> get props => [chatStreamObj];
}

// MESSAGES
class ChatEventAddMessage extends ChatEvent{
  final MessagePropsObject msgPropsObj;
  ChatEventAddMessage(this.msgPropsObj);
  @override
  List<Object> get props => [msgPropsObj];
}

class ChatEventDeleteMessage extends ChatEvent{
  final String mid;
  ChatEventDeleteMessage(this.mid);

  @override
  List<Object> get props => [mid];
}
