
import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/definitions/theme.dart';

import 'package:flutter_frigate_user_app/models/device.dart';

import 'package:flutter_frigate_user_app/ui/device_listview.dart';
import 'package:flutter_frigate_user_app/utils/netcode.dart';
import 'package:flutter_frigate_user_app/utils/shared_prefs.dart';

class NotificationsList extends StatefulWidget {
  @override
  _NotificationsListState createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  /// общий массив устройств, полученных со страницы авторизации
  List<Device> _devices = globalDevices;
  /// массив выделенных виджетов
  List<Device> _selected = [];

  @override
  void initState() {
    _selected.clear();

    for (int i = 0; i < notificationDevicesList.length; i++) {
      int index = globalDevices.indexWhere((device) => device.id == notificationDevicesList[i] && device.devClass == classZone);
      if (index >= 0) _selected.add(globalDevices[index]);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: const Text('Выберите устройства'),
        leading: new IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {Navigator.of(context).pop();}
        ),
      ),
      body: new Container(
        child: new DeviceListView(
          devices: _devices,
          selectedDevices: _selected,
          onChanged: (value) {
            setState(() {_selected = value;});
          },
        )
      ),
      floatingActionButton: new FloatingActionButton(
        heroTag: 'ScenarioAddButton',
        child: const Icon(Icons.done),
        backgroundColor: colorFAB,
        onPressed: _addButton,
      ),
    );
  }

  // Обработчик нажатия кнопки "Добавить"
  void _addButton() async {
    notificationDevicesList.clear();
    for (Device elem in _selected) {
      notificationDevicesList.add(elem.id);
    }

    await SharedPrefs.saveNotificationsList(notificationDevicesList);
    await Netcode.saveNotificationsList(notificationDevicesList);
    print("Notifications list zones IDs: $notificationDevicesList");
    Navigator.of(context).pop();
  }
}