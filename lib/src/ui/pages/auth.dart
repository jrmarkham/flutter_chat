import 'package:chat/src/data/blocs/auth/bloc.dart';
import 'package:chat/src/globals.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_code_picker/country_codes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_view/pin_view.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with WidgetsBindingObserver {
  AuthBloc _authBloc;
  bool _emailValid = true;
  bool _mobileValid = true;
  Locale _locale;
  String _countryCode;
  String _verificationCode;
  bool _private = false;
  UserPropsObject _userProps;

  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _mobileTextController = TextEditingController();
  final TextEditingController _nameTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mobileValid = false; //(_mobileTextController.text);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {

    super.didChangeDependencies();

    _authBloc = BlocProvider.of<AuthBloc>(context);
    _locale = Localizations.localeOf(context);
    debugPrint('locale ${_locale.toString()}');

    List<CountryCode> elements = codes
        .map((s) => CountryCode(
              name: "",
              code: s['code'],
              dialCode: s['dial_code'],
              flagUri: "",
            ))
        .toList();
    _countryCode =
        elements.firstWhere((c) => c.code == _locale.countryCode).dialCode;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('::::  didChangeAppLifecycleState   ${state.toString()}');
    if (state == AppLifecycleState.resumed) {
      // send to auth bloc
      // retrieveDynamicLink();
      _authBloc.add(AuthEventGetDynamicLink());
    }
  }


  @override
  Widget build(BuildContext context) {
    // USER SETTINGS
    // PRIVACY

    _saveUserProps() {
      _userProps = UserPropsObject(name: _nameTextController.text, private: _private);

      //
    }

    _privacyToggle(bool val) {
      setState(() {
        _private = val;
      });
    }

    Widget _privateSwitch() {
      return Container(
          child: SwitchListTile(
              title: Text(
                LABEL_PRIVACY,
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
              value: _private,
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
          style: TextStyle(fontSize: 20),
          decoration: InputDecoration(
              hintText: ENTER_NAME,
              labelText: LABEL_NAME,
              labelStyle: TextStyle(color: Colors.blue, fontSize: 16)));
    }

    // EMAIL FUNCTIONS
    _validEmail(String email) {
      setState(() {
        _emailValid = email.length > 0
            ? RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(_emailTextController.text)
            : true;
      });
    }

    Widget _emailInputField() {
      return TextField(
          controller: _emailTextController,
          keyboardType: TextInputType.emailAddress,
          maxLength: 50,
          maxLengthEnforced: true,
          onChanged: _validEmail,
          style: TextStyle(fontSize: 20),
          decoration: InputDecoration(
              hintText: ENTER_EMAIL,
              errorText: _emailValid ? null : ERROR_EMAIL,
              labelText: LABEL_EMAIL,
              labelStyle: TextStyle(color: Colors.blue, fontSize: 16)));
    }

    //

    _submitEmailFunction() {
      _saveUserProps();
      _authBloc
          .add(AuthEventInitEmailLogin(_emailTextController.text, _userProps));
    }

    Widget emailUI() {
      final Function _authMobile =
          () => _authBloc.add(AuthEventSetAuthType(AuthType.mobile));
      final Function _submitEmail = () => _submitEmailFunction();

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(LABEL_EMAIL),
            FlatButton(child: Text(USE_MOBILE), onPressed: _authMobile),
            _emailInputField(),
            RaisedButton(
                child: Text(SUBMIT),
                onPressed: _emailValid ? _submitEmail : null)
          ],
        ),
      );
    }

    // MOBILE FUNCTIONS

    _validMobile(String mobile) {
      setState(() {
        _mobileValid = mobile.isEmpty ? false :
             RegExp(r"^(?:[+0]+)?[0-9]{6,14}$")
                .hasMatch(_mobileTextController.text);
      });
    }

    _setCountryCode(CountryCode cc) {
      debugPrint('coutry code ${cc.toString()}');
      setState(() {
        _countryCode = cc.toString();
      });
    }

    Widget _mobileInputFields() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
              child: Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: CountryCodePicker(
              onChanged: (CountryCode cc) => _setCountryCode(cc),
              initialSelection: _locale.countryCode,
              favorite: [_locale.countryCode],
              showCountryOnly: false,
              alignLeft: true,
            ),
          )),
          Expanded(
            flex: 2,
            child: TextField(
                controller: _mobileTextController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                maxLengthEnforced: true,
                onChanged: _validMobile,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    hintText: ENTER_MOBILE,
                    errorText: _mobileValid ? null : ERROR_MOBILE,
                    labelText: LABEL_MOBILE,
                    labelStyle: TextStyle(color: Colors.blue, fontSize: 16))),
          ),
        ],
      );
    }

    _initMobileLogin() {
      _saveUserProps();
      final String _mobile = _countryCode + _mobileTextController.text;
      final PhoneCodeAutoRetrievalTimeout _autoRetrievalTimeout =
          (String verId) {
        _verificationCode = verId;
      };

      final PhoneCodeSent _phoneCodeSent =
          (String verId, [int forceCodeResend]) {
        _verificationCode = verId;
      };

      _authBloc.add(AuthEventInitMobileLogin(
          mobile: _mobile,
          userProps: _userProps,
          codeSent: _phoneCodeSent,
          codeAutoRetrievalTimeout: _autoRetrievalTimeout));
    }

    Widget mobileUI() {
      final Function authEmail =
          () => _authBloc.add(AuthEventSetAuthType(AuthType.email));
      final Function _submitMobile = () => _initMobileLogin();
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('$LABEL_MOBILE $_countryCode'),
            FlatButton(child: Text(USE_EMAIL), onPressed: authEmail),
            _mobileInputFields(),
            RaisedButton(
                child: Text(SUBMIT),
                onPressed: _mobileValid ? _submitMobile : null)
          ],
        ),
      );
    }

    Widget _validateMobileInputField() {
      return PinView(
        count: 6,
        margin: EdgeInsets.all(2.5),
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
        submit: (String smsCode) {
          AuthCredential credential = PhoneAuthProvider.getCredential(
              verificationId: _verificationCode, smsCode: smsCode);
          _authBloc.add(AuthEventVerifyMobile(credential));
        },
      );
    }

    Widget mobileVerifyUI() {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(LABEL_MOBILE),
            Text('code $_countryCode number ${_mobileTextController.text}'),
            _validateMobileInputField()
            //_mobileInputFields(),
            // RaisedButton(child: Text(SUBMIT), onPressed: null)
          ],
        ),
      );
    }

    final Function reset = () => _authBloc.add(AuthEventReset());
    return BlocBuilder(
        bloc: _authBloc,
        builder: (BuildContext context, AuthState state) {
          if (state is AuthStateLoaded) {
            debugPrint('::: auth status ::: ${state.authStatus.toString()}');

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(AUTH + state.authStatus.toString(),
                        style: TextStyle(color: Colors.blue, fontSize: 16)),
                    if (state.authStatus == AuthStatus.notAuth) ...[
                      _privateSwitch(),
                      _nameInputField(),
                      state.authType == AuthType.email ? emailUI() : mobileUI(),
                    ],
                    if (state.authStatus == AuthStatus.error) ...[
                      Text('Error  '),
                      RaisedButton(child: Text('reset'), onPressed: reset)
                    ],
                    if (state.authStatus == AuthStatus.linkSent) ...[
                      Text('LINK SENT CHECK EMAIL -- do link check here '),
                    ],
                    if (state.authStatus == AuthStatus.smsSent) ...[
                      Text('SMS SENT CHECK MOBILE -- do link check here '),
                      mobileVerifyUI(),
                    ],
                    if (state.authStatus == AuthStatus.auth) ...[
                      Text('AUTH ${state.authStatus.toString()} '),
                    ],
                  ],
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
