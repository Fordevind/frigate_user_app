import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/definitions/theme.dart';
import 'package:flutter_frigate_user_app/models/device.dart';
import 'package:flutter_frigate_user_app/screens/device_info.dart';

class ZonesPage extends StatefulWidget {
  const ZonesPage({Key key}) : super(key: key);

  @override
  _ZonesPageState createState() => _ZonesPageState();
}

class _ZonesPageState extends State<ZonesPage> {
  List<Device> prd = new List.from(globalDevices.where((elem) => elem.devClass == classPRD));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {homeScaffoldKey.currentState.openDrawer();},
        ),
        title: const Text('Объекты')
      ),
      body: new ListView.builder(
        itemCount: prd.length,
        itemBuilder: (context, index) {
          return _buildItem(prd[index]);
        },
      )
    );
  }

  Widget _buildItem(Device device) {
    return new ListTile(
      leading: prdIcon(device.style),
      title: new Text(device.name),
      subtitle: new Text(device.stamp, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () {
        materialAppNavigator.currentState.push(
          new MaterialPageRoute(builder: (context) => DeviceInfo(device, key: zonesKey)),
        );
      },
    );
  }
}