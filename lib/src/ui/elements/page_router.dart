import 'package:chat/src/data/blocs/ui/bloc.dart';
import 'package:chat/src/data/blocs/user/bloc.dart';
import 'package:chat/src/globals.dart';
import 'package:chat/src/ui/pages/auth.dart';
import 'package:chat/src/ui/pages/chat.dart';
import 'package:chat/src/ui/pages/home.dart';
import 'package:chat/src/ui/pages/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PageRouter extends StatelessWidget {
final UIBloc _uiBloc;
final UserBloc _userBloc;
final UserPropsObject _userProps;
PageRouter(this._uiBloc, this._userBloc, this._userProps);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: _uiBloc,
        builder: (BuildContext context, UIState state){
            if(state is UIStateLoaded){
                switch(state.nav){
                    case Nav.auth: return AuthPage();
                    case Nav.chat: return ChatPage();
                    case Nav.home: return HomePage();
                    case Nav.profile: return Profile(_userProps, _userBloc);
                }
            }
           return CircularProgressIndicator();
        },
    );
  }
}
