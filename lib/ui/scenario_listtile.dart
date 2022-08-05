import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/definitions/constants.dart';
import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/models/scenario.dart';
import 'package:flutter_frigate_user_app/screens/my_passcode_screen.dart';
import 'package:flutter_frigate_user_app/utils/netcode.dart';
import 'package:flutter_frigate_user_app/utils/secure_storage.dart';
import 'package:flutter_frigate_user_app/utils/shared_prefs.dart';

typedef DeleteScenarioCallback = void Function(Scenario sc);
typedef EditScenarioCallback = void Function(Scenario sc);

class ScenarioListTile extends StatefulWidget {
  const ScenarioListTile(this.scenario, {Key key, this.onDelete, this.onEdit, }) : super(key: key);

  final Scenario scenario;
  final DeleteScenarioCallback onDelete;
  final EditScenarioCallback onEdit;

  @override
  _ScenarioListTileState createState() => _ScenarioListTileState();
}

class _ScenarioListTileState extends State<ScenarioListTile> {
  bool executing = false;

  String pincode = '';
  int counts;

  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();

  @override
  void initState() {
    super.initState();
    getPincode();
    getPincodeInputCounts();
    widget.scenario.devices.sort((dev1, dev2) => dev1.name.compareTo(dev2.name));
    print("ScenarioListTile #${widget.hashCode} initState now ......................................................");
  }

  void getPincode() async {
    pincode = await SecureStorage.getPincode()?? '';
  }

  void getPincodeInputCounts() async {
    counts = await SecureStorage.getCountsInput();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: new Text(widget.scenario.name),
      subtitle: new Text(widget.scenario.stamp, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: new Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new IconButton(
            icon: executing ? const CircularProgressIndicator(strokeWidth: 1.0,) : const Icon(Icons.play_arrow),
            onPressed: executing ? null : () => _execute(widget.scenario)
          ),
          widget.scenario.persistance ? new Container() : _buttonDelete()
        ],
      ),
      onLongPress: widget.scenario.persistance ? null : () => widget.onEdit(widget.scenario),
    );
  }

  IconButton _buttonDelete() {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed:  () => widget.onDelete(widget.scenario)
    );
  }

  void _execute(Scenario sc) async {
    setState(() {executing = true;});

    try {
      if (sc.type == messageDisarm) {
        if (pincode.isNotEmpty) {
          await materialAppNavigator.currentState.push(new PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              return new MyPasscodeScreen(
                passwordDigits: maxPincodeLength,
                title: 'Введите код доступа',
                cancelLocalizedText: 'ВЫХОД',
                shouldShowCancel: false,
                passwordEnteredCallback: _onPasscodeEntered,
                shouldTriggerVerification: _verificationNotifier.stream,
                isValidCallback: () async {
                  SecureStorage.setCountsInput(countsOfPincodeInput);
                  await Netcode.disarm(globalDevices, sc.devices);
                  ScaffoldMessenger.of(homeScaffoldKey.currentContext).showSnackBar(new SnackBar(
                    content: new Text('Сценарий "${sc.name}" выполнен'),
                  ));
                  /*
                  homeScaffoldKey.currentState.showSnackBar(new SnackBar(
                    content: new Text('Сценарий "${sc.name}" выполнен'),
                  ));
                  */
                },
              );
            }
          ));
        }
        else {
          await Netcode.disarm(globalDevices, sc.devices);
          ScaffoldMessenger.of(homeScaffoldKey.currentContext).showSnackBar(new SnackBar(
            content: new Text('Сценарий "${sc.name}" выполнен'),
          ));
        }
      }
      else {
        await Netcode.arm(globalDevices, sc.devices);
        ScaffoldMessenger.of(homeScaffoldKey.currentContext).showSnackBar(new SnackBar(
          content: new Text('Сценарий "${sc.name}" выполнен'),
        ));
      }
    }
    on TimeoutException {
      ScaffoldMessenger.of(homeScaffoldKey.currentContext).showSnackBar(new SnackBar(
        content: new Text('Не удалось выполнить сценарий "${sc.name}", превышен лимит времени'),
      ));
    }
    catch (e) {
      ScaffoldMessenger.of(homeScaffoldKey.currentContext).showSnackBar(new SnackBar(
        content: new Text(e.toString()),
      ));
    }

    setState(() {executing = false;});
  }

  void _onPasscodeEntered(String enteredPasscode) async {
    bool isValid = pincode == enteredPasscode;
    _verificationNotifier.add(isValid);
    if (!isValid && counts > 0) {
      counts--;
      SecureStorage.setCountsInput(counts);
    }
    if (counts == 0) {
      _noMoreCounts();
    }
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
    globalDevices = null;
    await SharedPrefs.clear();
    SecureStorage.clear();
    await new Future.delayed(const Duration(seconds: 1));
    materialAppNavigator.currentState.pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }
}