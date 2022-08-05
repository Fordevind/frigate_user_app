import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/definitions/constants.dart';
import 'package:flutter_frigate_user_app/models/provider.dart';
import 'package:flutter_frigate_user_app/screens/my_passcode_screen.dart';
import 'package:flutter_frigate_user_app/utils/exit.dart';
import 'package:flutter_frigate_user_app/utils/netcode.dart';
import 'package:flutter_frigate_user_app/utils/secure_storage.dart';
import 'package:flutter_frigate_user_app/ui/show_alert_dialog.dart';

class LoginPincode extends StatefulWidget {
  const LoginPincode({
    Key key,
    this.provider,
    this.login,
    this.password,
    this.pincode
  }) : super(key: key);

  final Provider provider;
  final String login;
  final String password;
  final String pincode;

  @override
  _LoginPincodeState createState() => _LoginPincodeState();
}

class _LoginPincodeState extends State<LoginPincode> {
  int counts;
  String title = 'Введите код доступа';
  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();

  bool sending = false;

  @override
  void initState() {
    getPincodeInputCounts();
    super.initState();
  }

  void getPincodeInputCounts() async {
    counts = await SecureStorage.getCountsInput();
  }

  @override
  Widget build(BuildContext context) {
    return new MyPasscodeScreen(
      passwordDigits: maxPincodeLength,
      title: title,
      cancelLocalizedText: 'ВЫХОД',
      passwordEnteredCallback: _onPasscodeEntered,
      shouldTriggerVerification: _verificationNotifier.stream,
      bottomWidget: sending? LinearProgressIndicator(backgroundColor: Colors.black.withOpacity(0.8),) : Container(),
      cancelCallback: _exit,
      isValidCallback: _validCallback
    );
  }

  void _onPasscodeEntered(String enteredPasscode) async {
    bool isValid = enteredPasscode == widget.pincode;
    _verificationNotifier.add(isValid);
    if (!isValid && counts > 0) {
      counts--;
      SecureStorage.setCountsInput(counts);
      setState(() {title = 'Осталось попыток: $counts';});
    }
    if (counts == 0) {
      _noMoreCounts();
    }
  }

  void _exit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Подтверждение'),
          content: const Text('Вы уверены, что хотите сбросить код доступа и войти с помощью логина и пароля?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {Navigator.of(context).pop();},
            ),
            TextButton(
              child: const Text('Подтвердить'),
              onPressed: () async {
                exit();
              }
            )
          ],
        );
      }
    );
  }

  void _noMoreCounts() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          content: const Text('Превышено количество попыток ввода кода доступа'),
        );
      }
    );
    exit();
  }

  void _validCallback() async {
    SecureStorage.setCountsInput(countsOfPincodeInput);
    counts = countsOfPincodeInput;
    setState(() {sending = true;});

    for (int i = 0; i < widget.provider.urls.length; i++) {
      authURL = widget.provider.urls[i] + '/login';
      commandURL = widget.provider.urls[i] + '/command';
      try {
        print("Trying authorize to $authURL");

        await Netcode.auth(widget.login, widget.password);
        globalDevices = await Netcode.getState();
        break;
      }
      on TimeoutException {
        if (i == widget.provider.urls.length - 1) {
          showAlertDialog(context, title: 'Timeout Exception', message: "Авторизация не удалась, превышен лимит времени");
        }
        print("$authURL: aвторизация не удалась, превышен лимит времени");
      }
      catch (error) {
        if (i == widget.provider.urls.length - 1) {
          showAlertDialog(context, message: error.toString());
        }
        print(error.toString());
      }
    }
    await new Future.delayed(Duration(seconds: 2));
    setState(() {sending = false;});

    if (globalDevices != null) {
      if (globalDevices.isNotEmpty) {
        materialAppNavigator.currentState.pushReplacementNamed('/home');
      }
    }
  }
}