import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/definitions/constants.dart';
import 'package:flutter_frigate_user_app/models/device.dart';
import 'package:flutter_frigate_user_app/models/scenario.dart';
import 'package:flutter_frigate_user_app/ui/show_alert_dialog.dart';
import 'package:flutter_frigate_user_app/utils/netcode.dart';
import 'package:flutter_frigate_user_app/utils/shared_prefs.dart';
import 'package:flutter_frigate_user_app/ui/scenario_listtile.dart';

class ScenarioPage extends StatefulWidget {
  const ScenarioPage({Key key}) : super(key: key);
  @override
  _ScenarioPageState createState() => _ScenarioPageState();
}

class _ScenarioPageState extends State<ScenarioPage> {
  /// Массив сценариев
  List<Scenario> _scenarios = [];
  /// Массив сценариев по умолчанию
  List<Scenario> _defaultScenarios = [];
  /// Сценарии по умолчанию, "Взять всё" и "Снять всё"
  Scenario armAll, disarmAll;


  final _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  final _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _addDefaultScenarios();
    _initFromSharedPrefs();
  }

  void _addDefaultScenarios() {
    armAll = new Scenario('Взять всё', List.from(globalDevices.where((device) => device.devClass == classZone)), messageArm, persistance: true);
    disarmAll = new Scenario('Снять всё', List.from(globalDevices.where((device) => device.devClass == classZone)), messageDisarm, persistance: true);
    _defaultScenarios.addAll([armAll, disarmAll]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: const Text('Сценарии'),
        leading: new IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {homeScaffoldKey.currentState.openDrawer();},
        ),
      ),
      body: new RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: new Container(
          child: new ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            shrinkWrap: true,
            children: <Widget>[
              //_buildAddButton(),
              _buildListDefaultScenarios(),
              _buildListScenarios(),
              new ListTile(),
            ],
          )
        ),
      ),
      floatingActionButton: _floatingActionButton(),
    );
  }

  Widget _buildListDefaultScenarios() {
    return new Card(
      //shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
      elevation: 5.0,
      child: new ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: <Widget>[
          new ScenarioListTile(armAll, onDelete: null, onEdit: _edit),
          new ScenarioListTile(disarmAll, onDelete: null, onEdit: _edit)
        ],
      ),
    );
  }

  Widget _buildListScenarios() {
    return new Card(
      elevation: 5.0,
      child: new ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _scenarios.length,
        itemBuilder: (context, index) {
          return new ScenarioListTile(_scenarios[index], onDelete: _confirmDelete, onEdit: _edit);
        }
      )
    );
  }

  Widget _floatingActionButton() {
    return new FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: _add,
    );
  }

  /// Получение сценариев с сервера
  Future<void> _refresh() async {
    try {
      List<Scenario> _received = await Netcode.getScenarios();

      if (_received.isNotEmpty) {
        List<Scenario> diff = [];
        for (int i = 0; i < _received.length; i++) {
          if (!_scenarios.contains(_received[i])) diff.add(_received[i]);
        }

        setState(() { _scenarios.addAll(diff); });
      }
      else
        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
          content: const Text("Нет сценариев на сервере"),
        ));
    }
    on TimeoutException {
      /*
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: const Text("Не удалось загрузить сценарии, превышен лимит времени")
      ));
      */
      showAlertDialog(context, title: 'Timeout Exception', message: "Не удалось загрузить сценарии, превышен лимит времени");
    }
    catch (error) {
      /*
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(error.toString()),
      ));
      */
      showAlertDialog(context, message: error.toString());
    }
  }

  // Создание нового сценария и добавление его на сервер
  void _add() async {
    final result = await materialAppNavigator.currentState.pushNamed('/home/add');

    if (result != null) {
      // workaround
      Scenario _res = result as Scenario;

      setState(() {_scenarios.add(_res);});
      try {
        //await Netcode.deleteScenarios();
        await Netcode.saveScenarios(_scenarios);
        await SharedPrefs.saveScenariosToSharedPrefs(_scenarios);
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      }
      on TimeoutException {

        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
          content: new Text('Не удалось отправить сценарий "${_res.name}" на сервер, превышен лимит времени'),
        ));

        //showAlertDialog(context, title: "Timeout Exception", message: 'Не удалось отправить сценарий "${_res.name}" на сервер, превышен лимит времени');
      }
      catch (e) {
        /*
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text(e.toString()),
        ));
        */
        showAlertDialog(context, title: "Timeout Exception", message: 'Не удалось отправить сценарий "${_res.name}" на сервер, превышен лимит времени');
      }
    }
  }

  // Редактирование сценария, удаление старого и добавление нового на сервер
  void _edit(Scenario sc) async {
    final result = await materialAppNavigator.currentState.pushNamed('/home/edit', arguments: (sc));

    if (result != null) {
      Scenario _res = result as Scenario;

      setState(() {
        //replace or add to end of list
        //_scenarios.remove(sc);
        //_scenarios.add(_res);
        _scenarios.replaceRange(_scenarios.indexOf(sc), _scenarios.indexOf(sc) + 1, [_res]);
      });
      try {
        //await Netcode.deleteScenarios();
        await Netcode.saveScenarios(_scenarios);
        await SharedPrefs.saveScenariosToSharedPrefs(_scenarios);
      }
      on TimeoutException {
        /*
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: const Text("Не удалось изменить сценарий на сервере, превышен лимит времени"),
        ));
        */
        showAlertDialog(context, title: 'Timeout Exception', message: "Не удалось изменить сценарий на сервере, превышен лимит времени");
      }
      catch (e) {
        /*
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text(e.toString()),
        ));
        */
        showAlertDialog(context, message: e.toString());
      }
    }
  }

  // Удаление сценария
  void _confirmDelete(Scenario sc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          content: new Text('Действительно удалить сценарий "${sc.name}"?'),
          actions: <Widget>[
            new FlatButton(
              child: const Text('Отмена'),
              onPressed: () {Navigator.of(context).pop();},
            ),
            new FlatButton(
              child: const Text('OK'),
              onPressed: () {
                _onPressedOKConfirmDelete(sc);
                Navigator.of(context).pop();
              }
            )
          ],
        );
      }
    );
  }

  void _onPressedOKConfirmDelete(Scenario sc) async {
    try {
      setState(() { _scenarios.remove(sc); });
      await Netcode.saveScenarios(_scenarios);
      await SharedPrefs.saveScenariosToSharedPrefs(_scenarios);
    }
    on TimeoutException {
      /*
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: const Text("Не удалось удалить сценарий на сервере, превышен лимит времени"),
      ));
      */
      showAlertDialog(context, title: 'Timeout Exception', message: "Не удалось удалить сценарий на сервере, превышен лимит времени");
    }
    catch (e) {
      /*
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(e.toString()),
      ));
      */
      showAlertDialog(context, message: e.toString());
    }
  }

  void _initFromSharedPrefs() async {
    try {
      final buf = await SharedPrefs.getScenariosFromSharedPrefs();
      List<Scenario> diff = [];
      for (int i = 0; i < buf.length; i++) {
        if (!_scenarios.contains(buf[i])) diff.add(buf[i]);
      }
      _scenarios.addAll(diff);
    }
    catch (e) {
      /*
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(e.toString()),
      ));
      */
      showAlertDialog(context, message: e.toString());
    }

    setState(() {});
  }

}