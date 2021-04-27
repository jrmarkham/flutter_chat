import 'package:chat/src/globals.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();
}

class ChatStateInit extends ChatState {
  @override
  List<Object> get props => [];
}

class ChatStateLoading extends ChatState {
  @override
  List<Object> get props => [];
}

class ChatStatePromptChat extends ChatState {
  final UserObject user;
  ChatStatePromptChat(this.user);

  @override
  List<Object> get props => [user];
}

// SUPPLY CHAT STREAM DATA
class ChatStateLoaded extends ChatState {
  final List<MessageObject> messages;
  final String chatTitle;
  ChatStateLoaded(this.messages, this.chatTitle);

  @override
  List<Object> get props => [messages, chatTitle];
}

class ChatStateInactive extends ChatState {
  @override
  List<Object> get props => [];
}


class ChatStateRemoveGlobalAlert extends ChatState{
   @override
  List<Object> get props => [];
}


class ChatStateRemoveAlert extends ChatState{
  final String uid;
  ChatStateRemoveAlert(this.uid);

  @override
  List<Object> get props => [uid];
}


class ChatStateGlobalMessageSent extends ChatState {
@override
List<Object> get props => [];
}

class ChatStateMessageSent extends ChatState {
  final String userId;
  ChatStateMessageSent(this.userId);
  
  @override
  List<Object> get props => [userId];
}

class ChatStateError extends ChatState {
  final BlocError error;
  ChatStateError(this.error);

  @override
  List<Object> get props => [error];
}
