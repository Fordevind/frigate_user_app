import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/models/device.dart';
import 'package:flutter_frigate_user_app/models/scenario.dart';
import 'package:flutter_frigate_user_app/definitions/theme.dart';
import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/ui/device_listview.dart';

class ScenarioAdd extends StatefulWidget {
  @override
  _ScenarioAddState createState() => _ScenarioAddState();
}

class _ScenarioAddState extends State<ScenarioAdd> {
  /// имя нового сценария
  String _name;
  /// тип сценария: arm или disarm
  String _type;
  /// общий массив устройств, полученных со страницы авторизации
  List<Device> _devices = globalDevices;
  /// массив выделенных виджетов
  List<Device> _selected = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: const Text('Добавление сценария'),
        leading: new IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {Navigator.of(context).pop();}
        ),
      ),
      body: new Container(
        child: new DeviceListView(
          devices: _devices,
          onChanged: (value) {
            setState(() {_selected = value;});
          },
        )
      ),
      floatingActionButton: new FloatingActionButton(
        heroTag: 'ScenarioAddButton',
        child: const Icon(Icons.done),
        backgroundColor: _selected.isEmpty? colorDisabledFAB : colorFAB,
        onPressed: _selected.isEmpty? null : _addButton,
      ),
    );
  }

  // Обработчик нажатия кнопки "Добавить"
  void _addButton() async {
    dynamic result = await materialAppNavigator.currentState.pushNamed('/home/add/params');
    if (result != null) {
      _name = result['name'];
      _type = result['type'];
      Scenario _msg = new Scenario(_name, _selected, _type);
      Navigator.of(context).pop(_msg);
    }
  }
}