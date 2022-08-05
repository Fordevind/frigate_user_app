import 'dart:math';

import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/models/event.dart';
import 'package:flutter_frigate_user_app/models/device.dart';

const secondsInDay = 86400;

class RandomData {
  RandomData({this.minEvents = 5, this.maxEvents = 50});

  final int minEvents;
  final int maxEvents;
  Random rand = new Random();

  Future<List<Event>> generateEvents(Device device) async {
    int eventCount = rand.nextInt(maxEvents - minEvents) + minEvents;

    List<Event> result = new List.generate(eventCount, (index) {
      return new Event(
        dt: _randomTenDaysAgoFromToday(),
        id: rand.nextInt(1 << 32),
        //code: rand.nextInt(300),
        code: _randomName(),
        sourceName: _randomSource(device),
        addInfo: _randomAddInfo(),
      );
    });
    result.sort((event1, event2) => event1.dt.compareTo(event2.dt));

    await new Future.delayed(const Duration(seconds: 1));
    return new Future.value(
      result.reversed.toList()
    );
  }

  DateTime _randomTenDaysAgoFromToday() {
    return DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch - (rand.nextInt(secondsInDay * 10) * 1000));
  }

  String _randomName() {
    Random rand = new Random();
    switch (rand.nextInt(15)) {
      case 0:
        return 'Авария';
      case 1:
        return 'Взятие';
      case 2:
        return 'Запрос на взятие';
      case 3:
        return 'Запрос на снятие';
      case 4:
        return 'Извещение';
      case 5:
        return 'Команда';
      case 6:
        return 'Ошибка';
      case 7:
        return 'Патруль';
      case 8:
        return 'Предупреждение';
      case 9:
        return 'Пропуск теста';
      case 10:
        return 'Сброс тревоги';
      case 11:
        return 'Снятие';
      case 12:
        return 'Тест';
      case 13:
        return 'Тревога';
      case 14:
        return 'Устранение аварии';
      default:
        return '';
    }
  }

  String _randomSource(Device device) {
    if (device.devClass == classZone) return device.name + "\t(id: " + device.id.toString() + ")";

    List<Device> sources = [];
    if (device.devClass == classPPKOP)
      sources.addAll(globalDevices.where((elem) => elem.devClass == classZone && elem.parID == device.id));
    else {
      List<Device> ppkops = [];
      ppkops.addAll(globalDevices.where((elem) => elem.devClass == classPPKOP && elem.parID == device.id));
      for (int i = 0; i < ppkops.length; i++) {
        sources.addAll(globalDevices.where((elem) => elem.devClass == classZone && elem.parID == ppkops[i].id));
      }
    }

    int index = rand.nextInt(sources.length);
    return sources[index].name + "\t(id: " + sources[index].id.toString() + ")";
  }

  String _randomAddInfo() {
    if (rand.nextInt(10) == 0) return 'Дополнительная информация';
    else return '';
  }
}