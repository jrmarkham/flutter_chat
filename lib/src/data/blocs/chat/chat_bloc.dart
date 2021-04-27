import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat/src/data/services/chat_service.dart';
import 'package:chat/src/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import './bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  @override
  ChatState get initialState => ChatStateInit();
  final BaseChatServices _chatServices = ChatServices();
  StreamSubscription<QuerySnapshot> _chatStream;
  final List<MessageObject> messages = [];
  final List<UserObject> _userList = [];
  final List<ChatStreamObject> _chatStreamsList = [];
  CurrentUserObject _currentUser;
  bool _globalChat = false;
  String chatTitle = 'NO CHAT SELECTED';
  ChatStreamObject _currentChatStream;

  setChatStream(QuerySnapshot chatData) {
    chatData.documentChanges.forEach((data) async {
      if (data == null) return;
      final DocumentSnapshot doc = data.document;
      debugPrint('::::DATE DATA:::: ${doc[MESSAGE_DATE]}');
      final MessageObject message = MessageObject(
          id: doc.documentID,
          userId: doc[MESSAGE_USER_ID],
          userName: doc[MESSAGE_USER_ID] == _currentUser.id
              ? _currentUser.name
              : _userList[_userList.indexWhere(
                      (UserObject u) => u.id == doc[MESSAGE_USER_ID])]
                  .name,
          currentUser: doc[MESSAGE_USER_ID] == _currentUser.id,
          messageType: MessageType.values[doc[MESSAGE_TYPE]],
          content: doc[MESSAGE_CONTENT],
          // with the server timestamp there seems to be a delay on the first record
          date: await doc[MESSAGE_DATE] != null
              ? doc[MESSAGE_DATE]
              : Timestamp.now());
      // remove the dups probably unnecessary
      messages.removeWhere((MessageObject m) => m.id == message.id);
      messages.add(message);
    });
  }

  clearChatStream() {
    if (_chatStream != null) _chatStream.cancel();
    _currentChatStream = null;
    messages.clear();
    add(ChatEventRefresh());
  }

  checkRemoveAlert() {
    debugPrint(':::::checkRemoveAlert :::: ');
    // add check global
    if(_globalChat && _currentUser!=null && _currentUser.globalAlertOn){
      add(ChatEventRemoveGlobalAlert());
    }

    if (_currentChatStream != null) {
      debugPrint(
          ':::::checkRemoveAlert ::::${_currentChatStream.user.name} ${_currentChatStream.user.alert}');
      if (_currentChatStream.user.alert) add(ChatEventRemoveAlert());
    }
    add(ChatEventRefresh());
  }

  @override
  Stream<ChatState> mapEventToState(
    ChatEvent event,
  ) async* {
    if (event is ChatEventInit) {
      _currentUser = event.currentUser;
      _userList.clear();
      event.userList.forEach((UserObject user) => _userList.add(user));
      if (_currentChatStream != null)
        _currentChatStream = ChatStreamObject(
            id: _currentChatStream.id,
            user: _userList.singleWhere(
                (UserObject u) => u.id == _currentChatStream.user.id));
      if (event.nav == Nav.chat) checkRemoveAlert();
      add(ChatEventRefresh());
    }

    if (event is ChatEventRemoveAlert) {
      yield ChatStateRemoveAlert(_currentChatStream.user.id);
    }

    if (event is ChatEventRemoveGlobalAlert) {
      yield ChatStateRemoveGlobalAlert();
    }

    if (event is ChatEventOpenGlobalChat) {
      if (_globalChat) return;
      yield ChatStateLoading();
      clearChatStream();
      _globalChat = true;
      chatTitle = 'GLOBAL CHAT';
      checkRemoveAlert();
      _chatStream = _chatServices.getGlobalChatStream().listen((chatData) {
        setChatStream(chatData);
        add(ChatEventRefresh());
      });
    }

    if (event is ChatEventCreateChat) {
      _globalChat = false;
      yield ChatStateLoading();
      // CURRENT CHAT STREAM IS CURRENT ONE CALLED
      if (_currentChatStream != null &&
          _currentChatStream.user.id == event.uid) {
        checkRemoveAlert();
        return;
      }

      // CHECK FOR SAVED STREAM
      if (_chatStreamsList
          .contains((ChatStreamObject cs) => cs.user.id == event.uid)) {
        debugPrint('::::ChatEventChat got saved chat ');
        final ChatStreamObject cs = _chatStreamsList
            .singleWhere((ChatStreamObject cs) => cs.user.id == event.uid);
        //  check if stream is open and ready then run chat ///
        // check stream
        debugPrint('::::ChatEventChat got saved stream ::::');
        add(ChatEventStreamChat(cs));
        return;
      }
      //  check if stream is create on the server or create automatically for friends //
      // CHECK FOR CHAT STREAM ON SERVE OR CREATE IT
      final UserObject user =
          _userList.singleWhere((UserObject u) => u.id == event.uid);
      final String streamId =
          await _chatServices.findChatStreamByUsers(_currentUser.id, event.uid);
      if (streamId != null) {
        final ChatStreamObject newStream =
            ChatStreamObject(user: user, id: streamId);
        add(ChatEventStreamChat(newStream));
        return;
      }
      //ERROR //
      debugPrint('::::ChatEventChat error ');
      yield ChatStateError(BlocError.chatCreate);
      return;
    }

    if (event is ChatEventStreamChat) {
      clearChatStream();
      _currentChatStream = event.chatStreamObj;

      chatTitle = 'Chat with ${_currentChatStream.user.name}';
      checkRemoveAlert();
      _chatStream =
          _chatServices.getChatStream(_currentChatStream.id).listen((chatData) {
        setChatStream(chatData);

        add(ChatEventRefresh());
      });
    }

    if (event is ChatEventLogout) {
      yield ChatStateLoading();
      // CLOSE all streams
      clearChatStream();
      _currentUser = null;
      _userList.clear();
      add(ChatEventRefresh());
    }

    if (event is ChatEventAddMessage) {
      if (_globalChat) {
        final bool success = await _chatServices.createGlobalChatMessage(
            event.msgPropsObj, _currentUser.id);
        yield success
            ? ChatStateGlobalMessageSent()
            : ChatStateError(BlocError.chatCreateGlobalChatMessage);
        return;
      }

      final bool success = await _chatServices.createChatMessage(
          event.msgPropsObj, _currentUser.id, _currentChatStream.id);
      yield success
          ? ChatStateMessageSent(_currentChatStream.user.id)
          : ChatStateError(BlocError.chatGlobalChatMessage);

      add(ChatEventRefresh());
    }

    if (event is ChatEventRefresh) {
      yield ChatStateLoading();
      // get user by authId //

      // check for active chat
      if(_globalChat || _currentChatStream != null){
        messages
            .sort((MessageObject a, MessageObject b) => a.date.compareTo(b.date));
        yield ChatStateLoaded(messages, chatTitle);
        return;
      }
      yield ChatStateInactive();

    }
  }
}
