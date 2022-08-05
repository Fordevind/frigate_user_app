import 'package:flutter/foundation.dart';

import 'package:intl/intl.dart';

const int classPRD = 1;
const int classPPKOP = 2;
const int classZone = 3;

class Device {
  Device({
    this.pcnID,
    @required this.id,
    @required this.devClass,
    @required this.parID,
    this.number,
    @required this.name,
    this.custID,
    this.custName,
    this.address,
    this.devState,
    this.event,
    this.eventTime,
    this.pultNumber,
    this.style
  }) :  assert(id != null),
        assert(devClass != null),
        assert(parID != null),
        assert(name != null);

  /// ID пульца централизованного наблюдения
  final int pcnID;
  /// ID устройства (не уникальный, передатчики, ППКОПы и зоны могут иметь одинаковый ID)
  final int id;
  /// класс устройства: 1 - передатчик, 2 - ППКОП, 3 - шлейф
  final int devClass;
  /// ?ID устройства верхнего уровня?
  final int parID;

  final int number;

  final String name;

  final int custID;

  final String custName;

  final String address;

  final int devState;

  /// последнее событие
  final String event;
  /// время последнего события
  final String eventTime;

  final String pultNumber;
  /// статус
  final String style;

  /// Создание экземпляра из JSON
  factory Device.fromJson(Map<String, dynamic> json) {
    return new Device(
      pcnID: json['pcn_id'],
      id: json['dev_id'],
      devClass: json['dev_class'],
      parID: json['parid'],
      number: json['num'],
      name: json['dev_name'],
      custID: json['cust_id'],
      custName: json['cust_name'],
      address: json['adres'],
      devState: json['dev_state'],
      event: json['event'],
      eventTime: json['event_time'],
      pultNumber: json['pult_num'],
      style: json['style'],
    );
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = new Map();
    json = {
      'pcn_id': pcnID,
      'dev_id': id,
      'dev_class': devClass,
      'parid': parID,
      'num': number,
      'dev_name': name,
      'cust_id': custID,
      'cust_name': custName,
      'adres': address,
      'dev_state': devState,
      'event': event,
      'event_time': eventTime,
      'pult_num': pultNumber,
      'style': style
    };

    return json;
  }

  List<Device> getChildren(List<Device> devices) {
    return new List.from(devices
        .where((elem) => elem.devClass == classZone && elem.parID == this.id));
  }

  Device getParent(List<Device> devices) {
    return devices.firstWhere(
        (elem) => elem.devClass == classZone && elem.id == this.parID,
        orElse: () => null);
  }

  @override
  bool operator ==(Object o) =>
      o != null &&
      o is Device &&
      id == o.id &&
      devClass == o.devClass;

  @override
  int get hashCode {
    final int prime = 31;
    int result = 1;

    result = prime * result + id.hashCode;
    result = prime * result + devClass.hashCode;
    return result;
  }

  String get stamp {
    String result = '';
    DateFormat formatter = new DateFormat("dd.MM.yy\tHH:mm:ss");

    if (eventTime != null && event != null) {
      result = formatter.format(DateTime.tryParse(eventTime).toLocal()) + ' ' + event;
    }

    return result;
  }
}
