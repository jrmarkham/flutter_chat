import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:chat/src/globals/content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// GLOBALS
Future<bool> confirmActionAlert(
    BuildContext context, String title, String message) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext content) {
            if (Platform.isIOS) {
                return CupertinoAlertDialog(
                    title: Text(
                        title,
                        style: TextStyle(color: Colors.green, fontSize: 24),
                    ),
                    content: Text(
                        message,
                        style: TextStyle(color: Colors.green, fontSize: 16),
                        textAlign: TextAlign.left,
                    ),
                    actions: <Widget>[
                        FlatButton(
                            child: Text(
                                CANCEL,
                                style: TextStyle(color: Colors.green, fontSize: 16.0),
                            ),
                            onPressed: () => Navigator.pop(context, false),
                        ),
                        FlatButton(
                            child: Text(
                                CONFIRM,
                                style: TextStyle(color: Colors.green, fontSize: 16.0),
                            ),
                            onPressed: () => Navigator.pop(context, true),
                        )
                    ]);
            }

            return AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.green, fontSize: 24.0),
                ),
                content: Text(
                    message,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.green, fontSize: 16.0),
                ),
                actions: <Widget>[
                    FlatButton(
                        child: Text(
                            CANCEL,
                            style:TextStyle(color: Colors.green, fontSize: 16.0),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                    ),
                    FlatButton(
                        child: Text(
                            CONFIRM,
                            style: TextStyle(color: Colors.green, fontSize: 16.0),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                    )
                ]);
        });
}


Future<void> postToast(BuildContext context, String message, {milli = 1800}) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
        SnackBar(
            duration: Duration(milliseconds: milli),
            backgroundColor: Colors.green,
            content: Text(message, style: TextStyle(color: Colors.white, fontSize: 16.0),),
        ),
    );
    return null;
}

// inform alert w/out dismiss option
Future<void> informAlert(
    BuildContext context, String title, String message) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
            if (Platform.isIOS) {
                return CupertinoAlertDialog(
                    title: Text(
                        title,
                        style: TextStyle(color: Colors.green, fontSize: 24),
                    ),
                    content: Text(
                        message,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.green, fontSize: 16.0),
                    ),
                    actions: <Widget>[
                        FlatButton(
                            child: Text(
                                OK,
                                style: TextStyle(color: Colors.green, fontSize: 16.0),
                            ),
                            onPressed: () => Navigator.pop(context),
                        ),
                    ]);
            }

            return AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                    title,
                    style: TextStyle(color: Colors.green, fontSize: 24),
                    textAlign: TextAlign.center,
                ),
                content: Text(
                    message,
                    style: TextStyle(color: Colors.green, fontSize: 16.0),
                    textAlign: TextAlign.left,
                ),
                actions: <Widget>[
                    FlatButton(
                        child: Text(
                            OK,
                            style:TextStyle(color: Colors.green, fontSize: 16.0),
                        ),
                        onPressed: () => Navigator.pop(context),
                    )
                ]);
        });
}

Future<void> fullScreenDialog(
    BuildContext context, String title, Widget widget) async {
    return showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.grey,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
            return Scaffold(
                appBar: AppBar(
                    automaticallyImplyLeading: false,
                    title: Container(
                        alignment: Alignment.center,
                        child: Text(title, style: TextStyle(color: Colors.green, fontSize: 24)),
                        width: double.maxFinite,
                        color: Colors.green, height: 100.0),
                ),
                body: SingleChildScrollView(
                    child: Padding(
                        padding: EdgeInsets.all(25.0),
                        child: widget,
                    )));
        });
}
