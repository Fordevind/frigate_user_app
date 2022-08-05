import 'package:flutter/foundation.dart';

class Event {
  Event({
    @required this.dt,
    @required this.id,
    this.addInfo,
    @required this.code,
    this.sourceName,
    this.style
  }) :  assert(dt != null),
        assert(id != null),
        assert(code != null);

  /// Дата и время события
  final DateTime dt;
  /// ID события
  final int id;
  /// Строка дополнительной информации
  final String addInfo;
  /// Описание события
  final String code;
  /// Цвет события
  final String style;
  /// Источник события
  final String sourceName;

  factory Event.fromJson(Map<String, dynamic> json) {
    if (json.isNotEmpty) return new Event(
      dt: DateTime.tryParse(json['dt']),
      id: json['id'] as int,
      addInfo: json['add_info'] as String,
      code: json['code'] as String,
      sourceName: json['sourceName'] as String?? '',
      style: json['style'] as String
    );
    else return null;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = new Map();
    json =
    {
      'dt': dt.toIso8601String(),
      'id': id,
      'add_info': addInfo,
      'code': code,
      'sourceName': sourceName,
      'style': style,
    };

    return json;
  }

  int get unixMicroSecondsOfEvent => dt.microsecondsSinceEpoch;
}