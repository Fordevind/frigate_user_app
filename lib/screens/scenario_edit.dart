import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/models/device.dart';
import 'package:flutter_frigate_user_app/models/scenario.dart';
import 'package:flutter_frigate_user_app/definitions/theme.dart';
import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/ui/device_listview.dart';

class ScenarioEdit extends StatefulWidget {
  @override
  _ScenarioEditState createState() => _ScenarioEditState();
}

class _ScenarioEditState extends State<ScenarioEdit> {
  /// общий массив устройств, полученных со страницы авторизации
  List<Device> _devices = globalDevices;
  /// массив выделенных виджетов
  List<Device> _selected = [];
  /// сценарий, выделенный на странице сценариев
  Scenario _scenarioRecived;
  /// отредактированный сценарий
  Scenario _scenarioEdited;
  /// workaround, first initiliaze
  bool first = true;

  @override
  Widget build(BuildContext context) {
    // workaround for first initiliaze
    if (first) {
      _scenarioRecived = ModalRoute.of(context).settings.arguments as Scenario;
      _selected.addAll(_scenarioRecived.devices);
      first = false;
    }

    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        appBar: new AppBar(
          title: const Text('Редактирование сценария'),
          leading: new IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {Navigator.of(context).pop();}
          )
        ),
        body: new Container(
          //child: new ListView(children: BuildListView.bulidListView(_devices, _selected, setState),)
          child: new DeviceListView(
            devices: _devices,
            selectedDevices: _selected,
            onChanged: (value) {
              setState(() {_selected = value;});
            },
          )
        ),
        floatingActionButton: new FloatingActionButton(
          heroTag: 'ScenarioEditButton',
          child: const Icon(Icons.done),
          backgroundColor: _selected.isEmpty? colorDisabledFAB : colorFAB,
          onPressed: _selected.isEmpty? null : _edit,
        ),
      )
    );
  }


  Future<bool> _onWillPop() {
    //Navigator.of(context).pop();
    return Future.value(true);
  }

  void _edit() {
    showForm(title: 'Введите имя сценария');
  }

  // Создание диалогового модального окна с формой ввода данных о новом сценарии
  void showForm({String title = "Alert Dialog Title"}) {
    String _name;
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: new Text(title),
          content: new Form(
            key: _formKey,
            child: new SingleChildScrollView(
              child: new TextFormField(
                textInputAction: TextInputAction.done,
                initialValue: _scenarioRecived.name,
                maxLength: 30,
                decoration: new InputDecoration(
                  labelText: 'Название сценария',
                  helperText: 'Не более 30 символов',
                  filled: false
                ),
                //autovalidate: true,
                validator: (value) {
                  if (value.isEmpty) return 'Пожалуйста введите имя';
                  else _name = value.trim();
                },
              ),
            ),
          ),
          actions: <Widget>[
            new TextButton(
              child: const Text("Отмена"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: const Text("OK"),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  // Создание нового сценария
                  _scenarioEdited = new Scenario(_name, _selected, _scenarioRecived.type);
                  // Возврат и передача нового сценария на страницу со сценариями
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(_scenarioEdited);
                }
              },
            ),
          ],
        );
      },
    );
  }
}