import 'package:chat/src/data/blocs/user/bloc.dart';
import 'package:chat/src/globals.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
    final UserPropsObject userProps;
    final UserBloc userBloc;
    Profile(this.userProps, this.userBloc);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
    final TextEditingController _nameTextController = TextEditingController();
    UserPropsObject _newProps;
    Function _updateFunction;
    void initState() {
        // TODO: implement initState
        super.initState();
        _newProps = UserPropsObject(
            name: widget.userProps.name,
            private: widget.userProps.private
        );
        _nameTextController.text = _newProps.name;
    }

    _updateText(String text){
        setState(() {
            _newProps = UserPropsObject(
                name: _nameTextController.text,
                private: _newProps.private
            );

          _checkProps();
        });
    }
    _privacyToggle(bool val) {
        setState(() {
            _newProps = UserPropsObject(
                name: _newProps.name,
                private: val
            );

            _checkProps();

        });
    }


    _checkProps(){
       _updateFunction =  (_newProps.name == widget.userProps.name && _newProps.private == widget.userProps.private) ? null: ()=>widget.userBloc.add(UserEventUpdateUser(_newProps));
    }


    Widget _privateSwitch() {
        return Container(
            child: SwitchListTile(
                title: Text(
                    LABEL_PRIVACY,
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                value: _newProps.private,
                onChanged: _privacyToggle,
                activeColor: Colors.blue,
                activeTrackColor: Colors.grey,
                inactiveTrackColor: Colors.grey,
                inactiveThumbColor: Colors.blueGrey));
    }

    // NAME
    Widget _nameInputField() {
        return TextField(
            controller: _nameTextController,
            keyboardType: TextInputType.text,
            maxLength: 25,
            maxLengthEnforced: true,
            onChanged: _updateText,
            style: TextStyle(fontSize: 20),
            decoration: InputDecoration(
                hintText: ENTER_NAME,
                labelText: LABEL_NAME,
                labelStyle: TextStyle(color: Colors.blue, fontSize: 16)));
    }



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child:Padding(
            padding: const EdgeInsets.all(12.0),

              child: Column(
                mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: <Widget>[
                      Text('UPDATE PROFILE'),
                      _privateSwitch(),
                      _nameInputField(),
            RaisedButton(
                          child: Text(UPDATE), onPressed: _updateFunction),
                      
                  ],
                  //

              ),
            ),
       
    );
  }
}
