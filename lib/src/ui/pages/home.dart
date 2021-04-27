import 'package:chat/src/data/blocs/ui/bloc.dart';
import 'package:chat/src/data/blocs/user/bloc.dart';
import 'package:chat/src/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserBloc _userBloc;
  UIBloc _uiBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userBloc = BlocProvider.of<UserBloc>(context);
    _uiBloc = BlocProvider.of<UIBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
 //   _userBloc.close();
 //   _uiBloc.close();
  }

  _notFriendAlert(BuildContext context) {
    debugPrint('You need to be friends to cha');
    informAlert(context, 'NOT A FRIEND', 'You need to be friends to chat');
  }

  Widget getLead(UserObject user) {
    switch (user.friendStatus) {
      case FriendStatus.open:
        final Function _sendFunction = () => _userBloc.add(
            UserEventFriendUpdate(
                friendId: user.id,
                friendStatus: user.friendStatus,
                friendAction: FriendAction.send));
        return IconButton(
            icon: Icon(iconAddFriend, color: Colors.blue),
            onPressed: _sendFunction);
      case FriendStatus.received:
        final Function _acceptFunction = () => _userBloc.add(
            UserEventFriendUpdate(
                friendId: user.id,
                friendStatus: user.friendStatus,
                friendAction: FriendAction.accept));
        final Function _declineFunction = () => _userBloc.add(
            UserEventFriendUpdate(
                friendId: user.id,
                friendStatus: user.friendStatus,
                friendAction: FriendAction.decline));
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
                icon: Icon(iconAcceptFriend, color: Colors.blue),
                onPressed: _acceptFunction),
            SizedBox(
              width: 5.0,
            ),
            IconButton(
                icon: Icon(iconDeclineFriend, color: Colors.red),
                onPressed: _declineFunction)
          ],
        );

      case FriendStatus.sent:
      case FriendStatus.friend:
        final Function _removeFunction = () => _userBloc.add(
            UserEventFriendUpdate(
                friendId: user.id,
                friendStatus: user.friendStatus,
                friendAction: FriendAction.remove));

        return IconButton(
            icon: Icon(iconRemoveFriend, color: Colors.red),
            onPressed: _removeFunction);
      default:
        return Icon(iconHome, color: Colors.amber);
      // two
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: _userBloc,
        builder: (BuildContext context, UserState state) {
          if (state is UserStateLoaded) {
            final Function _logoutFunction =
                () => _userBloc.add(UserEventLogout());

            // GLOBAL CHAT
            final Function _notFriendAlertFunction =
                () => _notFriendAlert(context);
            final Function _openGlobalChat =
                () => _uiBloc.add(UIEventLoadGlobalChat());
            final Function toggleGlobalChat =
                () => _userBloc.add(UserEventToggleGlobalChat());
            final IconData iconGlobalChat =
                state.user.globalAlert ? iconGCOff : iconGCOn;
            final Color iconGlobalChatColor =
                state.user.globalAlert ? Colors.red : Colors.green;


            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(HOME, style: TextStyle(color: Colors.blue, fontSize: 16)),
                Text(state.user.name,
                    style: TextStyle(color: Colors.green, fontSize: 26)),
                Text('(${state.user.authItem})',
                    style: TextStyle(color: Colors.blue, fontSize: 20)),
                Text('id: ${state.user.id}',
                    style: TextStyle(color: Colors.blue, fontSize: 20)),
                Divider(),
                RaisedButton(child: Text(LOGOUT), onPressed: _logoutFunction),
                Divider(),
                SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.userList.length,
                    itemBuilder: (BuildContext context, int idx) {
                      final UserObject user = state.userList[idx];
                      if (user.private &&
                          user.friendStatus == FriendStatus.open)
                        return Container();
                      final Widget _leadWidget = getLead(user);
                      final Function _runChatFunction =
                          (user.friendStatus == FriendStatus.friend)
                              ? () => _uiBloc.add(UIEventLoadChat(user.id))
                              : _notFriendAlertFunction;

                      debugPrint('::::: Users :::::${user.name} ${user.friendStatus}');

                      return idx == 0
                          ? Column(
                              children: <Widget>[
                                ListTile(
                                  leading: IconButton(
                                      icon: Icon(iconGlobalChat,
                                          color: iconGlobalChatColor),
                                      onPressed: toggleGlobalChat),
                                  title: Text(LABEL_GLOBAL_CHAT,
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 16)),
                                  onTap: _openGlobalChat,
                                  trailing: state.user.globalAlertOn && state.user.globalAlert ?Icon(iconChat, color: Colors.green) : null,
                                ),
                                ListTile(
                                    leading: _leadWidget,
                                    title: Text(
                                        '${user.name} - ${user.friendStatus.toString()}',
                                        style: TextStyle(
                                            color: Colors.blue, fontSize: 16)),
                                    onTap: _runChatFunction,
                                    trailing: user.alert
                                        ? Icon(iconChat, color: Colors.green)
                                        : null)
                              ],
                            )
                          : ListTile(
                              leading: _leadWidget,
                              title: Text(
                                  '${user.name} - ${user.friendStatus.toString()}',
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 16)),
                              onTap: _runChatFunction,
                              trailing: user.alert
                                  ? Icon(iconChat, color: Colors.green)
                                  : null);
                    },
                  ),
                ),
              ],
            );
          }
//
          return Center(child: CircularProgressIndicator());
        });
  }
}
