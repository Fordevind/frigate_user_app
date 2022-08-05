import 'package:collection/collection.dart';

import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/definitions/constants.dart';
import 'package:flutter_frigate_user_app/models/device.dart';

class Scenario extends Object {
  /// Имя сценария
  final String name;
  /// Тип сценария
  final String type;
  /// Массив устройств
  final List<Device> devices;
  /// Флаг возможности удаления сценария
  final bool persistance;

  const Scenario(
    this.name,
    this.devices,
    this.type,
    {this.persistance = false}
  );

  /// Создание экземпляра из JSON
  factory Scenario.fromJson(Map<String, dynamic> parsedJSON,) {
    List<Device> _devices = [];
    List<dynamic> buf = parsedJSON['objects'];

    // Поиск устройств среди хранящихся в памяти программы
    for (int i = 0; i < buf.length; i++) {
      int index = globalDevices.indexWhere((device) => device.id == buf[i]['dev_id'] && device.parID == buf[i]['par_id'] && device.pcnID == buf[i]['pcn_id']);
      if (index >= 0) _devices.add(globalDevices[index]);
    }

    return new Scenario(parsedJSON['name'] as String, _devices, parsedJSON['action'] as String);
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = new Map();
    List<Map<String, dynamic>> _buf = [];


    // Преобразование Device в сокращенный JSON формат
    for (int i = 0; i < devices.length; i++)
      _buf.add({
        "pcn_id": devices[i].pcnID,
        "dev_id": devices[i].id,
        "par_id": devices[i].parID,
        "cust_id": devices[i].custID,
        "dev_name": devices[i].name
      });

    json =
    {
      'name': name,
      'action': type,
      'objects': _buf
    };

    return json;
  }

  @override
  bool operator == (Object o) {
    return o != null && o is Scenario && name == o.name && type == o.type && persistance == o.persistance && DeepCollectionEquality().equals(devices, o.devices);
  }

  @override
  int get hashCode {
    final int prime = 31;
    int result = 1;

    result = prime * result + ((name == null) ? 0 : name.hashCode);
    result = prime * result + ((type == null) ? 0 : type.hashCode);
    result = prime * result + ((persistance == null)? 0 : persistance.hashCode);
    result = prime * result + ((devices == null) ? 0 : DeepCollectionEquality().hash(devices));
    return result;
  }

  String get stamp {
    String result = 'Взять: ';
    if (type == messageDisarm) result = 'Снять: ';

    for (int i = 0; i < devices.length - 1; i++) {
      result = result + devices[i].name + ', ';
    }

    result = result + devices.last.name;

    return result;
  }
}