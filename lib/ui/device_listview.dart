import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/models/device.dart';
import 'package:flutter_frigate_user_app/definitions/theme.dart';

class DeviceListView extends StatefulWidget {
  const DeviceListView({
    Key key,
    @required this.devices,
    this.selectedDevices,
    this.onChanged
  }) :  assert(devices != null),
        super(key: key);

  final List<Device> devices;
  final List<Device> selectedDevices;
  final ValueChanged<List<Device>> onChanged;
  @override
  _DeviceListViewState createState() => _DeviceListViewState();
}

class _DeviceListViewState extends State<DeviceListView> {
  List<Widget> _widgets = [];

  List<Device> _devices = [];
  List<Device> _selectedDevices = [];

  @override
  void initState() {
    _devices = widget.devices;
    _selectedDevices = widget.selectedDevices?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _widgets = _buildDevices();
    return ListView.builder(
      itemCount: _widgets.length,
      itemBuilder: (context, index) {return _widgets[index];},
    );
  }

  List<Widget> _buildDevices() {
    // массив устройств ППКОП
    List<Device> _ppkops = [];
    // массив шлейфов
    List<Device> _zones = [];

    List<Widget> result = [];

    TextStyle _bold = const TextStyle(fontWeight: FontWeight.bold);
    // разделение общего массива устройств по типам

    for (Device elem in _devices) {
      int _type = elem.devClass;
      if (_type == classZone) {_zones.add(elem); continue;}
      if (_type == classPPKOP) _ppkops.add(elem);
    }

    for (var j = 0; j < _ppkops.length; j++)
    {
      List<Widget> level2 = [];
      List<Device> ownedDevices = [];

      bool calcCheckboxValue() {
        int i = 0;
        for (Device elem in ownedDevices) {
          if (_selectedDevices.contains(elem)) i++;
        }
        if (i == 0) return false;
        if (i == ownedDevices.length) return true;
        else return null;
      }

      for (var k = 0; k < _zones.length; k++)
      {
        if (_ppkops[j].id == _zones[k].parID) {
          ownedDevices.add(_zones[k]);
          bool _contains = _selectedDevices.contains(_zones[k]);
          level2.add(
            new AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.fromLTRB(24.0, 0.0, 0.0, 0.0),
              decoration: new BoxDecoration(
                color: _contains? colorSelected : null
              ),
              //color: _contains ? colorSelected : null,
              child: new CheckboxListTile(
                value: _contains,
                title: new Text(_zones[k].name, style: _contains ?  _bold : null,),
                //subtitle: new Text(_zones[k].id.toString()),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged:
                  (bool value) {
                    if (_contains)
                      setState(() {
                        _selectedDevices.remove(_zones[k]);
                        widget.onChanged(_selectedDevices);
                      });
                    else
                      setState(() {
                        _selectedDevices.add(_zones[k]);
                        widget.onChanged(_selectedDevices);
                      });

                  },
              )
            )
          );
        }
      }
      bool checkbox = calcCheckboxValue();
      result.add(
        new ExpansionTile(
          title: new Text(_ppkops[j].name),
          initiallyExpanded: true,
          leading: new Checkbox(
            tristate: true,
            value: checkbox,
            onChanged: (bool value) {
              if (checkbox == true)
                setState(() {
                  _selectedDevices.retainWhere((device) => !ownedDevices.contains(device));
                  widget.onChanged(_selectedDevices);
                });
              else
                setState(() {
                  _selectedDevices.addAll(ownedDevices.where((device) => !_selectedDevices.contains(device)));
                  widget.onChanged(_selectedDevices);
                });
            },
          ),
          children: level2,
        )
      );
    }
    return result;
  }
}