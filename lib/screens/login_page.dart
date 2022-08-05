import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_frigate_user_app/models/provider.dart';
import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/definitions/constants.dart';
import 'package:flutter_frigate_user_app/definitions/theme.dart';
import 'package:flutter_frigate_user_app/screens/my_passcode_screen.dart';

import 'package:flutter_frigate_user_app/ui/password_form_field.dart';
import 'package:flutter_frigate_user_app/ui/show_alert_dialog.dart';
import 'package:flutter_frigate_user_app/utils/netcode.dart';
import 'package:flutter_frigate_user_app/utils/secure_storage.dart';

const int maxLinesTextFormField = 1;

class LoginPage extends StatefulWidget {
  const LoginPage(this.provider, {Key key,}) : super(key: key);

  final Provider provider;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();
  final _loginController = new TextEditingController();
  final _passwordController = new TextEditingController();
  /// логин, пароль, введенные с формы
  String _password, _login;
  /// индикатор процесса отправки
  bool _sending = false;
  /// флаг пустоты поля ввода пароля
  bool _passwordEmpty = true;
  /// флаг пустоты поля ввода логина
  bool _loginEmpty = true;
  /// фокус для полей формы
  FocusNode _passwordFocus;
  /// выключатель кнопки Login
  bool _isButtonDisabled;
  bool setPincode = false;
  String pincode = '';
  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();

  @override
  void initState() {
    super.initState();
    _passwordFocus = new FocusNode();

    _loginController.addListener(_listenerLoginController);
    _passwordController.addListener(_listenerPasswordController);

    _loginController.text = defaultLogin;
    _passwordController.text = defaultPassword;
  }

  @override
  void dispose() {
    _passwordFocus.dispose();

    _verificationNotifier.close();

    _loginController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void _listenerLoginController() {
    if (_loginController.text.isEmpty) setState(() {_loginEmpty = true;});
    else setState(() {_loginEmpty = false;});
  }

  void _listenerPasswordController() {
    if (_passwordController.text.isEmpty) setState(() {_passwordEmpty = true;});
    else setState(() {_passwordEmpty = false;});
  }

  @override
  Widget build(BuildContext context) {
    _isButtonDisabled = _loginEmpty || _passwordEmpty || _sending;

    return new Scaffold(
      key: _scaffoldKey,
      body: new Container(
        padding: new EdgeInsets.all(24.0),
        child: new Align(alignment: new Alignment(0.0, -0.5), child: _buildForm(),)
      )
    );
  }

  Form _buildForm() {
    List<Widget> _widgets = [
      _logo(),
      new SizedBox(height: 60.0),
      _loginField(),
      new SizedBox(height: 6.0),
      _passwordField(),
      _setPin(),
      new SizedBox(height: 6.0),
      _buttonLogin()
    ];
    return new Form(
      key: _formKey,
      child: new ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: _widgets,
      )
    );
  }

  Hero _logo() {
    return new Hero(
      tag: widget.provider.name,
      child: new CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: widget.provider.imageLocal != null? new Image.asset(widget.provider.imageLocal): new Image.network(widget.provider.imageURL),
      ),
    );
  }

  TextFormField _loginField() {
    return new TextFormField(
      maxLines: maxLinesTextFormField,
      controller: _loginController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: new InputDecoration(
        contentPadding: new EdgeInsets.all(16.0),
        hintText: 'Логин',
        filled: true,
        border: textFormFieldBorder,
        enabledBorder: textFormFieldBorder,
        focusedBorder: textFormFieldBorder,
      ),
      inputFormatters: [new LengthLimitingTextInputFormatter(maxLengthofInput)],
      validator: (value) {_login = value.trim();},
      onFieldSubmitted: (value) {FocusScope.of(context).requestFocus(_passwordFocus);},
    );
  }

  PasswordFormField _passwordField() {
    return new PasswordFormField(
      maxLines: maxLinesTextFormField,
      controller: _passwordController,
      focusNode: _passwordFocus,
      decoration: new InputDecoration(
        contentPadding: new EdgeInsets.all(16.0),
        border: textFormFieldBorder,
        enabledBorder: textFormFieldBorder,
        focusedBorder: textFormFieldBorder,
        filled: true,
        hintText: 'Пароль'
      ),
      inputFormatters: [new LengthLimitingTextInputFormatter(maxLengthofInput)],
      validator: (value) {_password = value.trim();},
    );
  }

  CheckboxListTile _setPin() {
    return new CheckboxListTile(
      title: const Text('Задать код доступа'),
      value: setPincode,
      onChanged: _sending? null : (value) {
        setState(() {setPincode = !setPincode;});
      },
    );
  }

  RaisedButton _buttonLogin() {
    ElevatedButton(
      child: _sending? new ConstrainedBox(constraints: const BoxConstraints(maxHeight: 20.0, maxWidth: 20.0), child: _progressIndicator()) : const Text("Войти"),
      onPressed: _isButtonDisabled? null : _onPressedLogin,
    );
    return new RaisedButton(
      padding: new EdgeInsets.all(16.0),
      textColor: Colors.white,
      color: raisedButtonEnabled,
      disabledColor: raisedButtonDisabled,
      disabledTextColor: Colors.white,
      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
      child: _sending? new ConstrainedBox(constraints: const BoxConstraints(maxHeight: 20.0, maxWidth: 20.0), child: _progressIndicator()) : const Text("Войти"),
      onPressed: _isButtonDisabled? null : _onPressedLogin,
    );
  }

  Widget _progressIndicator() {
    return new Theme(
      data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(secondary: Colors.white),),
      child: const CircularProgressIndicator(strokeWidth: 2.0),
    );
  }

  void _onPressedLogin() async {
    setState(() {_isButtonDisabled = true;});

    if (_formKey.currentState.validate()) {
      setState(() {_sending = true;});

      for (int i = 0; i < widget.provider.urls.length; i++) {
        authURL = widget.provider.urls[i] + '/login';
        commandURL = widget.provider.urls[i] + '/command';
        try {
          print("Trying authorize to $authURL");
          await Netcode.auth(_login, _password, url: authURL);
          globalDevices = await Netcode.getState();
          break;
        }
        on TimeoutException {
          /*
          if (i == widget.provider.urls.length - 1)
            _scaffoldKey.currentState.showSnackBar(new SnackBar(
              content: const Text("Авторизация не удалась, превышен лимит времени"),
            ));
          */
          if (i == widget.provider.urls.length - 1)
            if (this.mounted) showAlertDialog(context, title: 'Timeout Exception', message: "Авторизация не удалась, превышен лимит времени");
        }
        catch (error) {
          /*
          if (i == widget.provider.urls.length - 1)
            _scaffoldKey.currentState.showSnackBar(new SnackBar(
              content: new Text(error.toString())
            ));
          */
          if (i == widget.provider.urls.length - 1)
            showAlertDialog(context, message: error.toString());
        }
      }
    }
    if (this.mounted) setState(() {_isButtonDisabled = false; _sending = false;} );

    if (globalDevices != null) {
      if (globalDevices.isNotEmpty) {
        if (setPincode) {
          materialAppNavigator.currentState.push(new MaterialPageRoute(
            builder: (context) {
              return new MyPasscodeScreen(
                passwordDigits: maxPincodeLength,
                title: 'Задайте код доступа',
                cancelLocalizedText: 'ВЫХОД',
                passwordEnteredCallback: _onPasscodeEntered,
                shouldTriggerVerification: _verificationNotifier.stream,
                isSettingMode: true,
                isValidCallback: () async {
                  SecureStorage.saveLogin(_login);
                  SecureStorage.savePassword(_password);
                  SecureStorage.savePincode(pincode);
                  SecureStorage.saveProvider(widget.provider);
                  SecureStorage.setCountsInput(countsOfPincodeInput);
                  materialAppNavigator.currentState.pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                },
              );
            }
          ));
        }
        else {
          SecureStorage.saveLogin(_login);
          materialAppNavigator.currentState.pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
        }
      }
      else {
        print('_onPressedLogin: Response body is empty');
        showAlertDialog(context, message: "Не удалось авторизоваться на сервере");
      }
    }
    else {
      print('_onPressedLogin: Response body is null');
    }
  }

  void _onPasscodeEntered(String enteredPasscode) async {
    bool isValid = enteredPasscode.length == maxPincodeLength;
    _verificationNotifier.add(isValid);
    if (isValid) pincode = enteredPasscode;
  }

}