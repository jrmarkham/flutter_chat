import 'package:chat/src/data/blocs/chat/bloc.dart';
import 'package:chat/src/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatBloc _chatBloc;
  MessagePropsObject _message;
  bool _ready = false;
  final TextEditingController _addChatTextController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  _updateMessage(String text) {
    _message = MessagePropsObject(
        messageType: MessageType.text, content: _addChatTextController.text);
    setState(() {
      _ready = _addChatTextController.text.length > 0;
    });
  }

  Widget _messageInputField() {
    return Container(
      width: 285.0,
      child: TextField(
          controller: _addChatTextController,
          keyboardType: TextInputType.text,
          maxLength: 120,
          maxLengthEnforced: true,
          onChanged: _updateMessage,
          style: TextStyle(fontSize: 20),
          decoration: InputDecoration(
              hintText: ENTER_CHAT,
              labelStyle: TextStyle(color: Colors.blue, fontSize: 16))),
    );
  }


  @override
  void didChangeDependencies() {

    _chatBloc = BlocProvider.of<ChatBloc>(context);
    super.didChangeDependencies();
  }


  _sendChatMessage(BuildContext context) {
    _chatBloc.add(ChatEventAddMessage(_message));
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _addChatTextController.clear();
    });
  }

  void _setScroll() {
    if (_chatScrollController != null && _chatScrollController.hasClients)
      _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    final Function _sendMessage = () => _sendChatMessage(context);
//    final Function _deleteMessage =
//        (String mid) => _chatBloc.add(ChatEventDeleteMessage(mid));

    return BlocBuilder(
        bloc: _chatBloc,
        builder: (BuildContext context, ChatState state) {
            if(state is ChatStateInactive){
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
                        Text('CHAT INACTIVE -- SELECT A USER TO CHAT WITH FROM THE HOME PAGE',
                        style: TextStyle(color: Colors.green, fontSize: 20)),
                    ]));

            }
          if (state is ChatStateLoaded) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
                Text(state.chatTitle,
                    style: TextStyle(color: Colors.green, fontSize: 20)),
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.messages.length,
                      controller: _chatScrollController,
                      itemBuilder: (BuildContext context, int idx) {
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) => _setScroll());
                        final MessageObject msg = state.messages[idx];
                        return msg.currentUser
                            ? Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    margin: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                        border: Border.all(
                                            color: Colors.black, width: 3.0)),
                                    child: Text(
                                      '$idx ${msg.content}',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                      softWrap: true,
                                      textAlign: TextAlign.right,
                                    )),
                              )
                            : Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.all(12.0),
                                  margin: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(24.0),
                                      border: Border.all(
                                          color: Colors.black, width: 3.0)),
                                  child: Text(
                                    '$idx ${msg.userName}:\n${msg.content}',
                                    softWrap: true,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 22),
                                  ),
                                ),
                              );
                      }),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _messageInputField(),
                    IconButton(
                      icon: Icon(iconPost,
                          color: _ready ? Colors.green : Colors.grey),
                      onPressed: _ready ? _sendMessage : null,
                    )
                  ],
                ),
              ]),
            );
          }
          return Container(
              width: 200.0,
              height: 200.0,
              child: Center(child: CircularProgressIndicator()));
        });
  }
}
