import 'package:chat/src/globals.dart';
import 'package:flutter/material.dart';

AppBar appBar(Function navFunction){
    // Functions //
    final Function homeFunction = ()=> navFunction(Nav.home);
    final Function profileFunction = ()=> navFunction(Nav.profile);
    final Function chatFunction = ()=> navFunction(Nav.chat);

    return AppBar(
        leading: IconButton(icon: Icon( iconHome, color: Colors.white), onPressed: homeFunction),
        title: Text(title),
        actions: <Widget>[
             IconButton(icon: Icon( iconChat, color: Colors.white), onPressed: chatFunction),
            IconButton(icon: Icon( iconProfile, color: Colors.white), onPressed: profileFunction),
        ],
    );

}