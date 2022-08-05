import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/models/device.dart';
import 'package:flutter_frigate_user_app/models/event.dart';
import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/definitions/constants.dart';
import 'package:flutter_frigate_user_app/ui/history_listview_stateless.dart';
import 'package:flutter_frigate_user_app/ui/device_two_level_treeview.dart';
import 'package:flutter_frigate_user_app/utils/exit.dart';
import 'package:flutter_frigate_user_app/utils/netcode.dart';
import 'package:flutter_frigate_user_app/utils/secure_storage.dart';

import 'package:flutter_frigate_user_app/screens/my_passcode_screen.dart';

const int tabCount = 2;

class DeviceInfo extends StatefulWidget {
  DeviceInfo(this.prd, {this.onChanged, Key key}) : super(key: key);

  final Device prd;
  final ValueChanged<List<Device>> onChanged;

  @override
  _DeviceInfoState createState() => _DeviceInfoState();
}

class _DeviceInfoState extends State<DeviceInfo> {
  final historyRefreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  final devicesRefreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  /// выключатель кнопки Взять
  bool isButtonArmDisabled = true;
  /// выключатель кнопки Снять
  bool isButtonDisarmDisabled = true;
  /// индикатор отправки
  bool _sending = false;
  /// массив выделенных устройств
  List<Device> _selected = [];
  /// массив устройств, отправленных для изменения состояния
  List<Device> _needToExecute = [];

  Future<List<Event>> data;

  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();

  bool isPincodeEmpty = true;
  bool isPincodeCorrect = false;

  String pincode = '';
  String title = 'Введите код доступа';

  int counts;

  @override
  void initState() {
    getHistory();
    getPincode();
    getPincodeInputCounts();
    super.initState();
  }

  void getPincode() async {
    pincode = await SecureStorage.getPincode()?? '';
    print("PIN: $pincode");
  }

  void getPincodeInputCounts() async {
    counts = await SecureStorage.getCountsInput();
  }

  void getHistory() async {
    try {
      data = Netcode.getHistoryDevice(widget.prd);
    }
    catch (e){
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selected.isEmpty || _sending) {
      isButtonArmDisabled = true;
      isButtonDisarmDisabled = true;
    }
    else {
      isButtonArmDisabled = false;
      isButtonDisarmDisabled = false;
    }
    return DefaultTabController(
      length: tabCount,
      child: new Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(
          leading: _selected.isEmpty? new IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context),) : new IconButton(icon: Icon(Icons.arrow_back), onPressed: () => setState(() {_selected.clear();}),),
          title: _selected.isNotEmpty? new Text("Выбрано: ${_selected.length}") : new Text(widget.prd.name),
          actions: _selected.isNotEmpty? <Widget>[
            new IconButton(
              icon: const Icon(Icons.lock),
              onPressed: isButtonArmDisabled? null : _arm,
            ),
            new IconButton(
              icon: const Icon(Icons.lock_open),
              onPressed: isButtonDisarmDisabled? null : _disarm,
            ),
          ] : null,
          bottom: new TabBar(
            labelStyle: TextStyle(),
            tabs: <Widget>[
              new Tab(child: const Text('Зоны', maxLines: 1, overflow: TextOverflow.ellipsis,)),
              new Tab(child: const Text('История', maxLines: 1, overflow: TextOverflow.ellipsis,)),
            ],
          ),
        ),
        body: new TabBarView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            _devices(),
            _history(),
          ],
        )
      )
    );
  }

  Widget _devices() {
    //possbile use of FutureBuilder
    return new RefreshIndicator(
      key: devicesRefreshIndicatorKey,
      onRefresh: _refreshDevices,
      child: new DeviceTwoLevelTreeView(
        widget.prd,
        onChanged: (value) {
          setState(() {_selected = value;});
        },
      )
    );
  }

  Widget _history() {
    return new FutureBuilder(
      future: data,
      builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
        if (snapshot.hasError) {
          return new RefreshIndicator(
            key: historyRefreshIndicatorKey,
            onRefresh: _refreshHistory,
            child: new SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: new Container(
                height: MediaQuery.of(context).size.height - Scaffold.of(context).appBarMaxHeight,
                child: new Center(
                  child: new Text('Не удалось загрузить историю с сервера'),
                ),
              )
            )
          );
        }
        if (snapshot.hasData) {
          if (snapshot.data.isEmpty) {
            return new RefreshIndicator(
              key: historyRefreshIndicatorKey,
              onRefresh: _refreshHistory,
              child: new SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: new Container(
                  height: MediaQuery.of(context).size.height - Scaffold.of(context).appBarMaxHeight,
                  child: new Center(
                    child: new Text('Нет событий за последние пять дней'),
                  ),
                )
              )
            );
          }
          else {
            return new RefreshIndicator(
              key: historyRefreshIndicatorKey,
              onRefresh: _refreshHistory,
              child: new HistoryListView(snapshot.data)
            );
          }
        }
        else {
          return new Center(
            child: new CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)
            )
          );
        }
      },
    );
  }

  Future<void> _refreshDevices() async {
    try {
      globalDevices = await Netcode.getState();
    }
    on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: const Text("Не удалось получить от сервера состояние устройств, превышен лимит времени"),
      ));
    }
    on FormatException {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: const Text("Не удалось расшифровать данные, полученные от сервера"),
      ));
    }
    catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: new Text(error.toString()),
      ));
    }
    if (this.mounted) setState(() {});
  }

  Future<void> _refreshHistory() async {
    try {
      data = null;
      if (this.mounted) setState(() {data = Netcode.getHistoryDevice(widget.prd);});
    }
    catch (e) {
      print(e.toString());
    }
  }

  /// Обработчик нажатия кнопки "Снять"
  void _arm() async {
    _needToExecute.clear();
    _needToExecute.addAll(_selected);
    await changeStatus(CommandType.arm);
    //update();
  }

  /// Обработчик нажатия кнопки "Снять"
  void _disarm() async {
    _needToExecute.clear();
    _needToExecute.addAll(_selected);
    if (pincode.isNotEmpty) {
      Navigator.of(context).push(
        new PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) => new MyPasscodeScreen(
            passwordDigits: maxPincodeLength,
            title: title,
            shouldShowCancel: false,
            passwordEnteredCallback: _onPasscodeEntered,
            shouldTriggerVerification: _verificationNotifier.stream,
            isValidCallback: () async {
              SecureStorage.setCountsInput(countsOfPincodeInput);
              counts = countsOfPincodeInput;
              changeStatus(CommandType.disarm);
              update();
            },
          )
        )
      );
    }
    else {
      changeStatus(CommandType.disarm);
      // await new Future.delayed(const Duration(milliseconds: 500));
      //update();
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
    exit();
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

  Future<void> changeStatus(CommandType type) async {
    if (this.mounted) setState(() {_sending = true;});
    try {
      if (type == CommandType.arm) await Netcode.arm(globalDevices, _needToExecute);
      else await Netcode.disarm(globalDevices, _needToExecute);
      _selected.retainWhere((device) => !_needToExecute.contains(device) );
    }
    on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: const Text("Не удалось изменить состояние устройства, превышен лимит времени"),
      ));
    }
    catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: new Text(error.toString()),
      ));
    }
    _needToExecute.clear();
    if (this.mounted) setState(() { _sending = false; });
  }

  Future<void> update() async {
    try {
      await new Future.delayed(const Duration(seconds: 5), () async {
        globalDevices = await Netcode.getState();
        if (this.mounted) setState(() {});
      });
    }
    on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: const Text("Не удалось получить состояние устройства, превышен лимит времени"),
      ));
    }
    catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: new Text(error.toString()),
      ));
    }
  }

  @override
  void dispose() {
    _verificationNotifier.close();
    super.dispose();
  }
}