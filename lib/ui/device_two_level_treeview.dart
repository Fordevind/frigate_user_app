import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/definitions/constants.dart';
import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/definitions/theme.dart';
import 'package:flutter_frigate_user_app/models/device.dart';
import 'package:flutter_frigate_user_app/ui/device_listile.dart';
import 'package:flutter_frigate_user_app/utils/netcode.dart';

class DeviceTwoLevelTreeView extends StatefulWidget {
  const DeviceTwoLevelTreeView(this.prd, {Key key, this.onChanged,}) : super(key: key);
  final Device prd;
  final ValueChanged<List<Device>> onChanged;

  @override
  _DeviceTwoLevelTreeViewState createState() => _DeviceTwoLevelTreeViewState();
}

class _DeviceTwoLevelTreeViewState extends State<DeviceTwoLevelTreeView> with AutomaticKeepAliveClientMixin {
  List<Device> selected = [];
  bool isCheckBoxMode = false;
  Duration changeColorDuration = const Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    selected.isNotEmpty? isCheckBoxMode = true : isCheckBoxMode = false;
    return ListView(
      children: _buildList(),
    );
  }

  List<Widget> _buildList() {
    List<Widget> widgets = [];
    List<Device> ppkops = new List.from(globalDevices.where((elem) => elem.devClass == classPPKOP && elem.parID == widget.prd.id));

    for (int i = 0; i < ppkops.length; i++) {
      List<Device> zones = new List.from(globalDevices.where((elem) => elem.devClass == classZone && elem.parID == ppkops[i].id));

      widgets.add(_buildPPKOP(ppkops[i]));
      widgets.addAll(_buildZones(zones));
      if (i != ppkops.length - 1) widgets.addAll([new Divider()]);
    }
    return widgets;
  }

  Widget _buildPPKOP(Device ppkop) {
    return DeviceListTile(
      ppkop,
      checkboxMode: isCheckBoxMode,
      leading: _buildLeading(ppkop),
      onLongPress: () {
        List<Device> ownedDevices = new List.from(globalDevices.where((elem) => elem.devClass == classZone && elem.parID == ppkop.id));

        int i = 0;
        for (Device elem in ownedDevices) {
          if (selected.contains(elem)) i++;
        }

        if (i >= ownedDevices.length)
          setState(() {
            selected.retainWhere((device) => !ownedDevices.contains(device));
            widget.onChanged(selected);
          });
        else
          setState(() {
            selected.addAll(ownedDevices.where((device) => !selected.contains(device)));
            widget.onChanged(selected);
          });
      },
      onTap: () {
        if (isCheckBoxMode) {
          List<Device> ownedDevices = new List.from(globalDevices.where((elem) => elem.devClass == classZone && elem.parID == ppkop.id));

          int i = 0;
          for (Device elem in ownedDevices) {
            if (selected.contains(elem)) i++;
          }

          if (i >= ownedDevices.length)
            setState(() {
              selected.retainWhere((device) => !ownedDevices.contains(device));
              widget.onChanged(selected);
            });
          else
            setState(() {
              selected.addAll(ownedDevices.where((device) => !selected.contains(device)));
              widget.onChanged(selected);
            });
        }
      },
      showMore: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                showHistory(ppkop),
                armPPKOP(ppkop),
                disarmPPKOP(ppkop)
              ],
            );
          }
        );
      },
    );
  }

  List<Widget> _buildZones(List<Device> zones) {
    List<Widget> result = new List.generate(zones.length, (index) => _buildZone(zones[index]));
    return result;
  }

  Widget _buildZone(Device zone) {
    bool contains = selected.contains(zone);
    return DeviceListTile(
      zone,
      checkboxMode: isCheckBoxMode,
      isSelected: contains,
      leading: _buildLeading(zone),
      onTap: () {
        if (isCheckBoxMode) {
          setState(() {
            contains? selected.remove(zone) : selected.add(zone);
          });
          widget.onChanged(selected);
        }
        else {
          materialAppNavigator.currentState.pushNamed('/home/deviceHistory', arguments: zone);
        }
      },
      onLongPress: () {
        setState(() {
          contains? selected.remove(zone) : selected.add(zone);
          widget.onChanged(selected);
        });
      },
    );
  }

  Widget _buildLeading(Device device) {
    Widget icon;
    Checkbox checkbox;
    bool contains = selected.contains(device);

    if (device.devClass == classZone) {
      icon = zoneIcon(device.style);
      checkbox = new Checkbox(
        tristate: false,
        value: contains,
        onChanged: (newValue) {
          if (contains) {
            setState(() {selected.remove(device);});
            widget.onChanged(selected);
          }
          else {
            setState(() {selected.add(device);});
            widget.onChanged(selected);
          }
        },
      );
    }
    else if (device.devClass == classPPKOP) {
      List<Device> ownedDevices = new List.from(globalDevices.where((elem) => elem.devClass == classZone && elem.parID == device.id));
      //List<Device> ownedDevices = device.getChildren(globalDevices);
      bool calcCheckboxValue() {
        int i = 0;
        for (Device elem in ownedDevices) {
          if (selected.contains(elem)) i++;
        }
        if (i == 0) return false;
        if (i == ownedDevices.length) return true;
        else return null;
      }

      icon = ppkopIcon(device.style);
      bool value = calcCheckboxValue();
      checkbox = new Checkbox(
        tristate: true,
        value: value,
        onChanged: (bool newValue) {
          if (value == true)
            setState(() {
              selected.retainWhere((device) => !ownedDevices.contains(device));
              widget.onChanged(selected);
            });
          else
            setState(() {
              selected.addAll(ownedDevices.where((device) => !selected.contains(device)));
              widget.onChanged(selected);
            });
        }
      );
    }
    if (isCheckBoxMode) {
      return new Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          checkbox,
          icon
        ],
      );
    }
    else {
      return icon;
    }
  }

  Widget showHistory(Device ppkop) {
    return new ListTile(
      leading: const Icon(Icons.history),
      title: const Text('Показать историю'),
      onTap: () async {
        await materialAppNavigator.currentState.pushNamed('/home/deviceHistory', arguments: ppkop);
        Navigator.pop(context);
      },
    );
  }

  Widget armPPKOP(Device ppkop) {
    return new ListTile(
      leading: const Icon(Icons.lock),
      title: const Text('Взять под охрану'),
      onTap: () async {
        Navigator.pop(context);
        await changeStatus(CommandType.arm, ppkop);
      }
    );
  }

  Widget disarmPPKOP(Device ppkop) {
    return new ListTile(
      leading: const Icon(Icons.lock_open),
      title: const Text('Снять с охраны'),
      onTap: () async {
        Navigator.pop(context);
        await changeStatus(CommandType.disarm, ppkop);
      },
    );
  }

  Future<void> changeStatus(CommandType type, Device ppkop) async {
    assert(ppkop.devClass == classPPKOP);
    List<Device> ownedDevices = new List.from(globalDevices.where((elem) => elem.devClass == classZone && elem.parID == ppkop.id));

    try {
      if (type == CommandType.arm) {
        await Netcode.arm(globalDevices, ownedDevices);
      }
      else {
        await Netcode.disarm(globalDevices, ownedDevices);
      }
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

    if (this.mounted) setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}