import 'package:chat/src/data/blocs/auth/bloc.dart';
import 'package:chat/src/data/blocs/chat/bloc.dart';
import 'package:chat/src/data/blocs/ui/bloc.dart';
import 'package:chat/src/data/blocs/user/bloc.dart';
import 'package:chat/src/globals.dart';
import 'package:chat/src/ui/elements/app_bar.dart';
import 'package:chat/src/ui/elements/page_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  // blocs

  AuthBloc _authBloc;
  Nav nav = Nav.auth;
  UIBloc _uiBloc;
  UserBloc _userBloc;
  ChatBloc _chatBloc;
  UserPropsObject _userProps;
  Function _navFunction;


  @override
  void didChangeDependencies() {
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _userBloc = BlocProvider.of<UserBloc>(context);
    _uiBloc = BlocProvider.of<UIBloc>(context);
    _chatBloc = BlocProvider.of<ChatBloc>(context);
    _authBloc.add(AuthEventInit());
    super.didChangeDependencies();
  }



  _setProps(String _name, bool _private) {
    setState(() {
      _userProps = UserPropsObject(name: _name, private: _private);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (BuildContext context, AuthState state) {
            // get login state
            if (state is AuthStateLoaded) {
              if (state.authStatus == AuthStatus.notAuth) {
                nav = Nav.auth;
                _uiBloc.add(UIEventInit(nav));
              }

              if (state.authStatus == AuthStatus.auth) {
                // init user list /
                _userBloc.add(UserEventInit(state.userProps));
                // create or load user data //
              }
            }

            if (state is AuthStateError) {
              debugPrint(':::::ERROR:::: AuthState ${state.error}');
              informAlert(context, 'auth error',
                  'auth error ${state.error.toString()}');
            }
          },
        ),
        BlocListener<UserBloc, UserState>(
          listener: (BuildContext context, UserState state) {
            // if user event list is ready //
            // should run once
            if (state is UserStateLoaded) {
              // user list is load try to authenticate
              debugPrint('::::: UserStateLoaded ');
              _setProps(state.user.name, state.user.private);
              // init chat or refresh
              _chatBloc.add(ChatEventInit(state.user, state.userList, nav));
              if (Nav.auth == nav) {
                nav = Nav.home;
                _navFunction = (Nav nav) => _uiBloc.add(UIEventSetPage(nav));
                _uiBloc.add(UIEventInit(nav));
              }
            }

            if (state is UserStateError) {
              debugPrint(':::::ERROR:::: UserState ${state.error}');
              informAlert(context, 'user error',
                  'user error ${state.error.toString()}');
            }

            if (state is UserStateLogout) {
              _authBloc.add(AuthEventLogout());
              _chatBloc.add(ChatEventLogout());
            }
          },
        ),
        BlocListener<UIBloc, UIState>(
          listener: (BuildContext context, UIState state) {
            if (state is UIStateGlobalChat) {
              // set global chat //
              debugPrint(':::::UIStateGlobalChat:::: ');
              _chatBloc.add(ChatEventOpenGlobalChat());
            }

            if (state is UIStateChat) {
              // set global chat //
              debugPrint(':::::UIStateChat:::: ${state.uid} ');
              _chatBloc.add(ChatEventCreateChat(state.uid));
            }

            if(state is UIStateLoaded){
              // track page
             nav = state.nav;

            }

//            if(state is UIStateError){
//              debugPrint(':::::ERROR:::: UIState ${state.error}');
//              informAlert(context, 'ui error', 'ui error ${state.error.toString()}');
//            }

            // get login state
          },
        ),
        BlocListener<ChatBloc, ChatState>(
          listener: (BuildContext context, ChatState state) {
            // get login state
            debugPrint('::::: Chat Listener :::: ${state.toString()} ');

            if(state is ChatStateRemoveAlert){
              _userBloc.add(UserEventRemoveMessageAlert(state.uid));
            }


            if(state is ChatStateRemoveGlobalAlert){
              _userBloc.add(UserEventRemoveGlobalAlert());
            }
            
            if(state is ChatStateMessageSent){
              // write update on user ... ///
              _userBloc.add(UserEventAddMessageAlert(state.userId));
            }

            if(state is ChatStateGlobalMessageSent){
                // write update on all users w/ global  ... ///
              _userBloc.add(UserEventAddGlobalAlert());
            }

            if (state is ChatStateError) {
              informAlert(context, 'chat error',
                  'chat error ${state.error.toString()}');
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: appBar(_navFunction),
        body: SafeArea(
          child: GestureDetector(
            // close key boards
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: PageRouter(_uiBloc, _userBloc, _userProps),
          ),
        ),
      ),
    );
  }
}
