import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/definitions/constants.dart';
import 'package:flutter_frigate_user_app/models/device.dart';
import 'package:flutter_frigate_user_app/models/scenario.dart';
import 'package:flutter_frigate_user_app/models/event.dart';
import 'package:flutter_frigate_user_app/models/provider.dart';

const defaultURL = 'http://192.168.11.32:22000';
const providersListURL = 'http://list.frigate03.ru';

const _httpTimeOut = Duration(seconds: 10);
const _simulationDelay = Duration(milliseconds: 1500);

/// A method returns a human readable string representing a file_size
String filesize(dynamic size, [int round = 2]) {
  /**
   * [size] can be passed as number or as string
   *
   * the optional parameter [round] specifies the number
   * of digits after comma/point (default is 2)
   */
  int divider = 1024;
  int _size;
  try {
    _size = int.parse(size.toString());
  } catch (e) {
    throw ArgumentError("Can not parse the size parameter: $e");
  }

  if (_size < divider) {
    return "$_size B";
  }

  if (_size < divider * divider && _size % divider == 0) {
    return "${(_size / divider).toStringAsFixed(0)} KB";
  }

  if (_size < divider * divider) {
    return "${(_size / divider).toStringAsFixed(round)} KB";
  }

  if (_size < divider * divider * divider && _size % divider == 0) {
    return "${(_size / (divider * divider)).toStringAsFixed(0)} MB";
  }

  if (_size < divider * divider * divider) {
    return "${(_size / divider / divider).toStringAsFixed(round)} MB";
  }

  if (_size < divider * divider * divider * divider && _size % divider == 0) {
    return "${(_size / (divider * divider * divider)).toStringAsFixed(0)} GB";
  }

  if (_size < divider * divider * divider * divider) {
    return "${(_size / divider / divider / divider).toStringAsFixed(round)} GB";
  }

  if (_size < divider * divider * divider * divider * divider &&
      _size % divider == 0) {
    num r = _size / divider / divider / divider / divider;
    return "${r.toStringAsFixed(0)} TB";
  }

  if (_size < divider * divider * divider * divider * divider) {
    num r = _size / divider / divider / divider / divider;
    return "${r.toStringAsFixed(round)} TB";
  }

  if (_size < divider * divider * divider * divider * divider * divider &&
      _size % divider == 0) {
    num r = _size / divider / divider / divider / divider / divider;
    return "${r.toStringAsFixed(0)} PB";
  } else {
    num r = _size / divider / divider / divider / divider / divider;
    return "${r.toStringAsFixed(round)} PB";
  }
}

class Netcode {
  //static var cookie;
  static var sessionUID;
	static Map<String, String> _headers = {
		//"Cookie" : cookie,
		"Content-type": contentTypeAppJSON
	};

  /// Получение списка поставщиков услуг от сервера
  static Future<List<Provider>> getProvidersList({String url,}) async {
    String _url = url?? providersListURL;
    String _dpi;

    List<Provider> result = [];

    Map<String, String> _packet = {
      'device_pixel_ratio' : _dpi?? '1.0'
    };

    final response = await http.post(Uri.parse(_url), body: _packet).timeout(_httpTimeOut);
    final _body = utf8.decode(response.bodyBytes);

    result = _parseProviders(_body);

    await new Future.delayed(_simulationDelay);
    return result;
  }

  /// Авторизация
  static Future<void> auth(String login, String password, {String url}) async {
    String _url = url?? authURL;
    Map<String, dynamic> _packet = {
      "client_class": "user",
      "mes_type": "hello",
      "login": "$login",
      "pass": "$password"
    };

    try {
      final response = await http.post(Uri.parse(_url), body: json.encode(_packet), headers: _headers).timeout(_httpTimeOut);
      print("Netcode.auth: request packet size = ${filesize(json.encode(_packet).length * 2)}");
      final _body = utf8.decode(response.bodyBytes);
      print("Netcode.auth: response body size = ${filesize(response.contentLength)}");
      //cookie = response.headers['set-cookie'];

      if (response.statusCode == HttpStatus.forbidden)
        throw Exception("Request error: 403, wrong login/password");
      if (response.statusCode == HttpStatus.ok && _body != null) {
        final parsedJson = json.decode(_body);
        sessionUID = parsedJson[0]['ses_uid'];
        fcmTopic = parsedJson[0]['topic'];

        print("SessionUID: $sessionUID");
        print("FCM Topic: $fcmTopic");
      }
      else
        throw Exception("Authorize fail: statusCode is not 200 or response body is null");
    }
    on Exception {
      rethrow;
    }
  }

  /// Получить устройства с сервера
  static Future<List<Device>> getState({String url}) async {
    String _url = url?? commandURL;
    List<Device> result = [];
    Map<String, String> _packet = {"ses_uid" : sessionUID, "mes_type": "get_user_devices"};
    try {
      final response = await http.post(Uri.parse(_url), headers: _headers, body: json.encode(_packet)).timeout(_httpTimeOut);
      print("Netcode.getState: request packet size = ${filesize(json.encode(_packet).length * 2)}");

      final _body = utf8.decode(response.bodyBytes);
      final parsedJson = json.decode(_body);
      print("Netcode.getState: response body size = ${filesize(response.contentLength)}");

      if (response.statusCode == HttpStatus.ok && _body != null) {
        result = _parseDevices(json.encode(parsedJson[0]['records']));
      }
      else
        throw Exception("GetState fail: statusCode is not 200 or response body is null");
    }
    on Exception {
      rethrow;
    }
    await new Future.delayed(_simulationDelay);
    return result;
  }

  /// Взять под охрану
	static Future<void> arm(List<Device> devices, List<Device> selectedDevices, {String url}) async {
    String _url = url?? commandURL;
    await _changeStatusWithSplit(devices, selectedDevices, true, url: _url);
	}
  /// Снять с охраны
	static Future<void> disarm(List<Device> devices, List<Device> selectedDevices, {String url}) async {
    String _url = url?? commandURL;
    await _changeStatusWithSplit(devices, selectedDevices, false, url: _url);
	}

  static Future<void> _changeStatusWithSplit(List<Device> devices, List<Device> selectedDevices, bool flag, {String url}) async {
    String _url = url?? commandURL;
    Map<String, dynamic> packet;
    List<Device> selected = new List.from(selectedDevices);

    while (selected.isNotEmpty) {
      int parID = selected.first.parID;
      int pcnID = selected.first.pcnID;

      List<int> packetBuf = [];

      List<Device> buf = [];
      // поиск и добавление зон с одинаковым parID в буфер
      buf.addAll(selected.where((device) => device.parID == parID && device.devClass == classZone));
      // удаление найденных устройств из массива выбранных
      selected.removeWhere((device) => device.parID == parID && device.devClass == classZone);

      for (Device elem in buf)
        packetBuf.add(elem.id);

      packet = {
        "ses_uid": sessionUID,
        "mes_type": flag ? messageArm : messageDisarm,
        "pcn_id": pcnID,
        "dev_id": parID,
        "zones": packetBuf
      };

      try {
        final response = await http.post(Uri.parse(_url), headers: _headers, body: json.encode(packet)).timeout(_httpTimeOut);
        print("Netcode.changeStatusWithSplit: request packet size = ${filesize(json.encode(packet).length * 2)}");
        print("Netcode.changeStatusWithSplit: response = ${json.decode(utf8.decode(response.bodyBytes))}");
        print("Netcode.changeStatusWithSplit: response body size = ${filesize(response.contentLength)}");
        if (response.statusCode == HttpStatus.ok && utf8.decode(response.bodyBytes).contains('confirm')) {
          await new Future.delayed(_simulationDelay);
        }
        else
          throw Exception("${flag ? 'Arm' : 'Disarm'} fail: statusCode is not 200 or response body is not true");
      }
      on Exception {
        rethrow;
      }
    }
  }

  /// Получить все сценарии с сервера
  static Future<List<Scenario>> getScenarios({String url}) async {
    String _url = url?? commandURL;
    List<Scenario> result = [];
    Map<String, dynamic> _packet = {
      "ses_uid": sessionUID,
      "mes_type": "get_scenarios"
    };

    try {
      final response = await http.post(Uri.parse(_url), headers: _headers, body: json.encode(_packet)).timeout(_httpTimeOut);
      print("Netcode.getScenarios: request packet size = ${filesize(json.encode(_packet).length * 2)}");
      print("Netcode.getScenarios: response = ${json.decode(utf8.decode(response.bodyBytes))}");
      print("Netcode.getScenarios: response body size = ${filesize(response.contentLength)}");
      if (response.statusCode == HttpStatus.ok && response.body != null) {
        final parsedJson = json.decode(response.body);
        result = _parseScenarios(json.encode(parsedJson[0]['records']));
      }
      else
        throw Exception("getScenario fail: statusCode is not 200 or response body is null");
    }
    on Exception {
      rethrow;
    }

    return result;
  }
  /// Сохранить все локальные сценарии на сервере
  static Future<bool> saveScenarios(List<Scenario> scenarios, {String url}) async {
    String _url = url?? commandURL;
    Map<String, dynamic> _packet = {
      "ses_uid": sessionUID,
      "mes_type": "save_scenarios",
      "records": scenarios
    };
    try {
      final response = await http.post(Uri.parse(_url), headers: _headers, body: json.encode(_packet)).timeout(_httpTimeOut);
      print("Netcode.saveScenarios: request packet size = ${filesize(json.encode(_packet).length * 2)}");
      print("Netcode.saveScenarios: response = ${json.decode(utf8.decode(response.bodyBytes))}");
      print("Netcode.saveScenarios: response body size = ${filesize(response.contentLength)}");
      if (response.statusCode == HttpStatus.ok && utf8.decode(response.bodyBytes).contains("confirm")) {
        return true;
      }
      else
        throw Exception("Save all Scenarios fail: statusCode is not 200 or response body is null");
    }
    on Exception {
      rethrow;
    }
  }

  static Future<List<Event>> getHistoryDevice(Device device, {String url}) async {
    String _url = url?? commandURL;
    List<Event> result = [];
    Map<String, dynamic> _packet = {
      'ses_uid': sessionUID,
      "mes_type": "get_history",
      "dev_id" : device.id,
      "pcn_id": device.pcnID,
    };

    try {
      final response = await http.post(Uri.parse(_url), headers: _headers, body: json.encode(_packet)).timeout(_httpTimeOut);
      print("Netcode.getHistoryDevice(dev_id: ${device.id}): request body size = ${filesize(json.encode(_packet).length * 2)}");
      print("Netcode.getHistoryDevice(dev_id: ${device.id}): response body size = ${filesize(response.contentLength)}");
      if (response.statusCode == HttpStatus.ok && response.body != null) {
        final parsedJson = json.decode(response.body);
        result = _parseHistory(json.encode(parsedJson[0]['records']));
      }
    }
    on Exception {
      rethrow;
    }
    await new Future.delayed(_simulationDelay);
    return result;
  }

  static Future<void> saveNotificationsList(List<int> notificationList, {String url}) async {
    String _url = url?? commandURL;
    List<Map<String, dynamic>> buf = [];
    notificationList.forEach((id) {
      int index = globalDevices.indexWhere((device) => device.id == id);
      if (index >= 0) {
        buf.add({
          "pcn_id": globalDevices[index].pcnID,
          "obj_id": globalDevices[index].custID,
          "dev_id": id
        });
      }
    });
    Map<String, dynamic> _packet = {
      "ses_uid": sessionUID,
      "mes_type": "save_user_notice",
      "zones": buf
    };
    try {
      final response = await http.post(Uri.parse(_url), headers: _headers, body: json.encode(_packet)).timeout(_httpTimeOut);

      if (response.statusCode == HttpStatus.ok) {
        return true;
      }
      else
        throw Exception("saveNotificationsList fail: statusCode is not 200 or response body is null");
    }
    on Exception {
      rethrow;
    }
  }

  /// Преобразование полученного JSON в массив устройств
  static List<Device> _parseDevices(String responseBody) {
    try {
      final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
      return parsed.map<Device>((json) => Device.fromJson(json)).toList();
    }
    on TypeError {
      throw new Exception('Не удалось расшифровать данные, полученные от сервера');
    }
    on Exception {
      rethrow;
    }
  }
  /// Преобразование полученного JSON в массив сценариев
  static List<Scenario> _parseScenarios(String responseBody) {
    try {
      final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
      return parsed.map<Scenario>((json) => Scenario.fromJson(json)).toList();
    }
    on TypeError {
      throw new Exception('Не удалось расшифровать данные, полученные от сервера');
    }
    on Exception {
      rethrow;
    }
  }

  /// Преобразование полученного JSON в массив событий
  static List<Event> _parseHistory(String responseBody) {
    try {
      final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

      List<Event> result = parsed.map<Event>((json) => Event.fromJson(json)).toList();
      result.sort((event1, event2) => event1.dt.compareTo(event2.dt));

      return result.reversed.toList();
    }
    on TypeError {
      throw new Exception('Не удалось расшифровать данные, полученные от сервера');
    }
    on Exception {
      rethrow;
    }
  }

  static List<Provider> _parseProviders(String responseBody) {
    try {
      final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
      return parsed.map<Provider>((json) => Provider.fromJson(json)).toList();
    }
    on TypeError {
      throw new Exception('Не удалось расшифровать данные, полученные от сервера');
    }
    on Exception {
      rethrow;
    }
  }
}