import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/definitions/constants.dart';
import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/definitions/theme.dart';
import 'package:flutter_frigate_user_app/models/device.dart';

class DeviceTreeView extends StatefulWidget {
  const DeviceTreeView(
      {Key key, @required this.devices, this.selectedDevices, this.onChanged})
      : assert(devices != null),
        super(key: key);

  final List<Device> devices;
  final List<Device> selectedDevices;
  final ValueChanged<List<Device>> onChanged;
  @override
  _DeviceTreeViewState createState() => _DeviceTreeViewState();
}

class _DeviceTreeViewState extends State<DeviceTreeView> {
  List<Widget> _widgets = [];
  List<Device> _devices = [];
  List<Device> _selectedDevices = [];

  bool isCheckboxMode = false;

  @override
  void initState() {
    _selectedDevices = widget.selectedDevices ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isCheckboxMode = _selectedDevices.isNotEmpty;
    _devices = widget.devices;
    _widgets = _buildDevices();

    return new ListView.builder(
      itemCount: _widgets.length,
      itemBuilder: (context, index) {
        return _widgets[index];
      },
    );
  }

  List<Widget> _buildDevices() {
    List<Widget> result = [];

    /// массив передатчиков
    List<Device> _prd = [];

    /// массив устройств ППКОП
    List<Device> _ppkops = [];

    /// массив шлейфов
    List<Device> _zones = [];

    for (Device elem in _devices) {
      int type = elem.devClass;
      if (type == classZone) {
        _zones.add(elem);
        continue;
      }
      if (type == classPPKOP) {
        _ppkops.add(elem);
        continue;
      }
      if (type == classPRD) _prd.add(elem);
    }

    for (var i = 0; i < _prd.length; i++) {
      List<Widget> level1 = [];
      for (var j = 0; j < _ppkops.length; j++) {
        List<Widget> level2 = [];
        for (var k = 0; k < _zones.length; k++) {
          if (_ppkops[j].id == _zones[k].parID) {
            level2.add(_buildZone(_zones[k]));
          }
        }

        if (_prd[i].id == _ppkops[j].parID)
          level1.add(_buildPPKOP(_ppkops[j], level2));
      }

      result.add(_buildPRD(_prd[i], level1));
    }
    result.addAll([new ListTile(), new ListTile(), new ListTile()]);

    return result;
  }

  Widget _buildPRD(Device prd, List<Widget> children) {
    List<Widget> buf = [];
    buf.add(new ListTile(
      title: new Text(prd.name),
      trailing: new GestureDetector(
        child: const Icon(Icons.more_vert),
        onTap: () {
          _showHistory(prd);
        },
      ),
    ));
    buf.addAll(children);
    return new Card(
        elevation: 7.0,
        child: new ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: buf));
  }

  Widget _buildPPKOP(Device ppkop, List<Widget> children) {
    return new GestureDetector(
        onLongPress: () => _showHistory(ppkop),
        child: new ExpansionTile(
          key: new PageStorageKey(ppkop.name),
          title: new Text(ppkop.name),
          leading: _selectIconPPKOP(ppkop.style),
          children: children,
        ));
  }

  Widget _buildZone(Device zone) {
    TextStyle _bold = const TextStyle(fontWeight: FontWeight.bold);
    bool _contains = _selectedDevices.contains(zone);
    return new Container(
      color: _contains ? colorSelected : null,
      child: new ListTile(
        title: new Text(
          zone.name,
          style: _contains ? _bold : null,
        ),
        //subtitle: new Text(zone.stamp, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: new Text(zone.id.toString(),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        //leading: _selectIconZone(zone.style),
        leading: _buildLeading(zone, _contains),
        contentPadding: new EdgeInsets.fromLTRB(32.0, 0, 0, 0),
        /*
          onTap: () => _showHistory(zone),
          onLongPress: () {
            if (_contains)
              setState(() {
                _selectedDevices.remove(zone);
                widget.onChanged(_selectedDevices);
              });
            else
              setState(() {
                _selectedDevices.add(zone);
                widget.onChanged(_selectedDevices);
              });
          },
          */
        onTap: () {
          if (isCheckboxMode) {
            setState(() {
              _contains
                  ? _selectedDevices.remove(zone)
                  : _selectedDevices.add(zone);
              widget.onChanged(_selectedDevices);
              if (_selectedDevices.isEmpty) isCheckboxMode = false;
            });
          } else {
            _showHistory(zone);
          }
        },
        onLongPress: () {
          if (!_contains)
            setState(() {
              isCheckboxMode = true;
              _selectedDevices.add(zone);
              widget.onChanged(_selectedDevices);
            });
        },
      ),
    );
  }

  Widget _buildLeading(Device zone, bool contains) {
    if (isCheckboxMode) {
      return new Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          contains
              ? new Icon(Icons.check_box)
              : new Icon(Icons.check_box_outline_blank),
          _selectIconZone(zone.style),
        ],
      );
    } else {
      return _selectIconZone(zone.style);
    }
  }

  /// Меняет иконку зоны в зависимости от статуса устройства
  Icon _selectIconZone(String status) {
    switch (status) {
      case statusArmed:
        //return new Icon(CustomIcon.key_inv, color: Colors.green);
        return const Icon(Icons.radio_button_checked, color: colorArmed);
      case statusDanger:
        //return new Icon(Icons.access_alarm, color: Colors.red);
        return const Icon(Icons.radio_button_checked, color: colorDanger);
      case statusDisarmed:
        //return new Icon(Icons.lock_open, color: Colors.blue);
        return const Icon(Icons.radio_button_checked, color: colorDisarmed);
      default:
        //return new Icon(Icons.device_unknown,);
        return const Icon(Icons.radio_button_checked);
    }
  }

  /// Меняет иконку ППКОП в зависимости от статуса устройства
  Icon _selectIconPPKOP(String status) {
    switch (status) {
      case statusArmed:
        return const Icon(const IconData(0xe963, fontFamily: 'icomoon'),
            color: colorArmed);
      case statusDanger:
        return const Icon(const IconData(0xe963, fontFamily: 'icomoon'),
            color: colorDanger);
      case statusDisarmed:
        return const Icon(const IconData(0xe963, fontFamily: 'icomoon'),
            color: colorDisarmed);
      default:
        return const Icon(const IconData(0xe963, fontFamily: 'icomoon'),
            color: colorUnknown);
    }
  }

  void _showHistory(Device zone) {
    /*
    if (zone.devClass != typeZone)
      throw new Exception('Type of argument is not Device.typeZone');

    else
    */
    materialAppNavigator.currentState
        .pushNamed('/home/deviceHistory', arguments: zone);
  }
}
