import 'package:chat/src/data/blocs/auth/bloc.dart';
import 'package:chat/src/data/blocs/chat/bloc.dart';
import 'package:chat/src/data/blocs/ui/bloc.dart';
import 'package:chat/src/data/blocs/user/bloc.dart';
import 'package:chat/src/globals.dart';

import 'package:chat/src/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  Globals.initGlobalData().then((_) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runApp(MaterialApp(
          debugShowCheckedModeBanner: false,
          title: title,
          theme:
          ThemeData(primaryColor: Colors.green, accentColor: Colors.black),

          // load up the bloc from the start //
          home: MultiBlocProvider(providers: [
            BlocProvider<AuthBloc>(
                create: (BuildContext context) => AuthBloc()),
            BlocProvider<UIBloc>(create: (BuildContext context) => UIBloc()),
            BlocProvider<UserBloc>(
                create: (BuildContext context) => UserBloc()),
            BlocProvider<ChatBloc>(create: (BuildContext context) => ChatBloc())
          ], child: App())));
    });
  });
}
