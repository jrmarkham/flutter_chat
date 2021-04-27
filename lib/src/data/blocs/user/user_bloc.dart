import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat/src/data/services/secure_storage_service.dart';
import 'package:chat/src/data/services/user_service.dart';
import 'package:chat/src/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import './bloc.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  @override
  UserState get initialState => UserStateInit();
  final BaseUserServices _userServices = UserServices();
  final BaseSecureStorageServices _secureStorageServices =
      SecureStorageServices();

  StreamSubscription<QuerySnapshot> _userStream;
  final List<UserObject> _userList = [];
  CurrentUserObject _currentUser;

  refreshUserList() {
    _userList.forEach((UserObject user) {
      // debugPrint('::::: LOOPING THRU USER LIST FOR FRIENDS UPDATE :::: ');

      // check alerts
      // check should be received
      if (_currentUser.invites.contains(user.id) &&
          user.friendStatus != FriendStatus.received) {
        // needs update
        final UserObject updateUser = UserObject(
            id: user.id,
            name: user.name,
            authItem: user.authItem,
            private: user.private,
            globalAlert: user.globalAlert,
            invites: user.invites,
            alert: user.alert,
            friendStatus: FriendStatus.received);
        _userList.remove(user);
        _userList.add(updateUser);
        return;
      }
      // check should be sent
      if (user.invites.contains(_currentUser.id) &&
          user.friendStatus != FriendStatus.sent) {
        final UserObject updateUser = UserObject(
            id: user.id,
            name: user.name,
            authItem: user.authItem,
            private: user.private,
            globalAlert: user.globalAlert,
            invites: user.invites,
            alert: user.alert,
            friendStatus: FriendStatus.sent);
        _userList.remove(user);
        _userList.add(updateUser);
        return;
      }
// check should be friend
      if (_currentUser.friends.contains(user.id) &&
          user.friendStatus != FriendStatus.friend) {
        // needs update
        final UserObject updateUser = UserObject(
            id: user.id,
            name: user.name,
            authItem: user.authItem,
            private: user.private,
            globalAlert: user.globalAlert,
            invites: user.invites,
            alert: user.alert,
            friendStatus: FriendStatus.friend);
        _userList.remove(user);
        _userList.add(updateUser);
        return;
      }
    // check should be open
      if(!_currentUser.friends.contains(user.id) &&
         ! _currentUser.invites.contains(user.id) &&
         ! user.invites.contains(_currentUser.id) &&
          user.friendStatus != FriendStatus.open
      ){
        final UserObject updateUser = UserObject(
            id: user.id,
            name: user.name,
            authItem: user.authItem,
            private: user.private,
            globalAlert: user.globalAlert,
            invites: user.invites,
            alert: user.alert,
            friendStatus: FriendStatus.open);
        _userList.remove(user);
        _userList.add(updateUser);
        return;

      }

    });
  }

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is UserEventInit) {
      yield UserStateLoading();
      debugPrint(':::::UserEventInit  :::: ');
      // get auth typ add // auth
      final String authItem = await _secureStorageServices.getAuth();
      _userStream = _userServices.getUserStream().listen((userData) {
        // set init data
        userData.documentChanges.forEach((data) {
          final DocumentSnapshot doc = data.document;
          if (authItem == doc[USER_AUTH_ITEM]) {
            _currentUser = CurrentUserObject(
              id: doc.documentID,
              authItem: doc[USER_AUTH_ITEM],
              name: doc[USER_NAME],
              private: doc[USER_PRIVATE],
              globalAlert: doc[USER_GLOBAL_ALERT],
              globalAlertOn: doc[USER_CHAT_ALERT] != null ? List.from(doc[USER_CHAT_ALERT]).contains(USER_CHAT_ALERT_GA)
                  : false,
              friends:
                  doc[USER_FRIENDS] != null ? List.from(doc[USER_FRIENDS]) : [],
              invites:
                  doc[USER_INVITES] != null ? List.from(doc[USER_INVITES]) : [],
            );

            // update friends status on users on the list //
            // check if update necessary
            refreshUserList();
          } else {
            final List<String> invites =
                doc[USER_INVITES] != null ? List.from(doc[USER_INVITES]) : [];
            bool alertOn = false;
            if (_currentUser != null) {
              final List<String> alertList = doc[USER_CHAT_ALERT] != null
                  ? List.from(doc[USER_CHAT_ALERT])
                  : [];

              alertOn = alertList.contains(_currentUser.id);
            }

            final UserObject user = UserObject(
                id: doc.documentID,
                authItem: doc[USER_AUTH_ITEM],
                name: doc[USER_NAME],
                private: doc[USER_PRIVATE],
                globalAlert: doc[USER_GLOBAL_ALERT],
                invites: invites,
                friendStatus: _currentUser == null
                    ? FriendStatus.open
                    : _currentUser.friends.contains(doc.documentID)
                        ? FriendStatus.friend
                        : _currentUser.invites.contains(doc.documentID)
                            ? FriendStatus.received
                            : invites.contains(_currentUser.id)
                                ? FriendStatus.sent
                                : FriendStatus.open,
                alert: alertOn);

            // Check user by phone or email for multiple devices
            // keeps list updated w/ unique items
            // if user exists remove it
            _userList.removeWhere((UserObject u) => u.id == user.id);
            // add the new user
            _userList.add(user);
          }
        });
        // if still no user create user
        if (_currentUser == null) {
          _userServices.createUser(
              authItem: authItem,
              name: event.userProps.name,
              private: event.userProps.private);
        }

        add(UserEventRefresh());
      });
    }

    if (event is UserEventToggleGlobalChat) {
      final success = await _userServices.updateUser(id: _currentUser.id, field: USER_GLOBAL_ALERT, value: !_currentUser.globalAlert);
      if(!success)yield UserStateError(BlocError.userGlobalAlertToggle);
      add(UserEventRefresh());
    }

    if (event is UserEventRefresh) {
      yield UserStateLoading();
      // get user by authId //

      _userList.sort((UserObject a, UserObject b) => a.name.compareTo(b.name));
      yield UserStateLoaded(_currentUser, _userList);
    }

    if (event is UserEventLogout) {
      yield UserStateLoading();
      _userStream.cancel();
      _userList.clear();
      _currentUser = null;
      yield UserStateLogout();
    }

    if (event is UserEventAddMessageAlert) {
      final success = await _userServices.userAddArrayItem(
          id: _currentUser.id, field: USER_CHAT_ALERT, value: event.userId);
      if (!success) yield UserStateError(BlocError.userAddChatAlert);
      add(UserEventRefresh());
    }


    if (event is UserEventAddGlobalAlert) {
      _userList.forEach((UserObject user) async{
        if(user.globalAlert ){
         final success = await _userServices.userAddArrayItem(
              id: user.id, field: USER_CHAT_ALERT, value: USER_CHAT_ALERT_GA);
         if(!success)debugPrint(':::error ::::: ${BlocError.userAddGlobalChatAlert} ');
        }
      });

      add(UserEventRefresh());
    }


    if (event is UserEventRemoveGlobalAlert) {
      debugPrint('::::UserEventRemoveMessageGlobalAlert::::::');
      final success = await _userServices.userRemoveArrayItem(
          id: _currentUser.id, field: USER_CHAT_ALERT, value: USER_CHAT_ALERT_GA);
      if(!success)yield UserStateError(BlocError.userRemoveGlobalChatAlert);
      add(UserEventRefresh());
    }
    
    if (event is UserEventRemoveMessageAlert) {
      debugPrint('::::UserEventRemoveMessageAlert::::::');
      final success = await _userServices.userRemoveArrayItem(
          id: event.userId, field: USER_CHAT_ALERT, value: _currentUser.id);
     // clearAlert(event.userId);
      debugPrint('::::UserEventRemoveMessageAlert:::::: success $success');
      if(!success)yield UserStateError(BlocError.userRemoveChatAlert);
      add(UserEventRefresh());
    }

    // user update
    if (event is UserEventUpdateUser) {
      bool success = true;
      if (event.userProps.name != _currentUser.name) {
        success = await _userServices.updateUser(
            id: _currentUser.id, field: USER_NAME, value: event.userProps.name);
      }
      if (event.userProps.private != _currentUser.private) {
        success = await _userServices.updateUser(
            id: _currentUser.id,
            field: USER_PRIVATE,
            value: event.userProps.private);
      }

      if (!success) yield UserStateError(BlocError.updateUser);
      add(UserEventRefresh());
    }

    // friends action
    if (event is UserEventFriendUpdate) {
      bool success = true;
      BlocError blocError = BlocError.friendInvite;
      switch (event.friendAction) {
        case FriendAction.send:
          // add the invite to the user's invite list //
          // check status
          success = false;
          if (event.friendStatus == FriendStatus.open) {
            success = await _userServices.userAddArrayItem(
                id: event.friendId,
                field: USER_INVITES,
                value: _currentUser.id);
          }

          break;

        case FriendAction.accept:
          // add ids to both friends list //
          // remove invite from your list //
          blocError = BlocError.friendAccept;

          success = false;
          if (event.friendStatus == FriendStatus.received) {
            // add friends
            success = await _userServices.userAddArrayItem(
                id: event.friendId,
                field: USER_FRIENDS,
                value: _currentUser.id);
            success = await _userServices.userAddArrayItem(
                id: _currentUser.id,
                field: USER_FRIENDS,
                value: event.friendId);
            success = await _userServices.userRemoveArrayItem(
                id: _currentUser.id,
                field: USER_INVITES,
                value: event.friendId);
          }

          break;
        case FriendAction.decline:
          // remove invite from your list //

          blocError = BlocError.friendDecline;

          success = false;
          if (event.friendStatus == FriendStatus.received) {
            // remove invite
            success = await _userServices.userRemoveArrayItem(
                id: _currentUser.id,
                field: USER_INVITES,
                value: event.friendId);
          }

          break;
        case FriendAction.remove:
          // remove ids from both friends list //
          // or remove invite from the user's invite list //
          blocError = BlocError.friendRemove;
          success = false;
          // remove invite
          if (event.friendStatus == FriendStatus.sent) {
            // remove invite
            success = await _userServices.userRemoveArrayItem(
                id: event.friendId,
                field: USER_INVITES,
                value: _currentUser.id);
          }
          // unfriend
          if (event.friendStatus == FriendStatus.friend) {
            // remove friend
            success = await _userServices.userRemoveArrayItem(
                id: event.friendId,
                field: USER_FRIENDS,
                value: _currentUser.id);
            success = await _userServices.userRemoveArrayItem(
                id: _currentUser.id,
                field: USER_FRIENDS,
                value: event.friendId);
          }

          break;
      }

      if (!success) yield UserStateError(blocError);
      add(UserEventRefresh());
    }
  }
}
