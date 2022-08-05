import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/models/event.dart';
import 'package:flutter_frigate_user_app/definitions/theme.dart';

import 'package:intl/intl.dart';

const int millisecondsInDay = 86400000;

class HistoryListView extends StatelessWidget {
  const HistoryListView(this.events, {Key key,}) : super(key: key);
  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    List<Widget> items = _buildItems(events);
    return new ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return items[index];
      }
    );
  }

  List<Widget> _buildItems(List<Event> data) {
    List<Widget> result = [];
    Queue<Event> queue = Queue.from(data);
    DateTime previousDate = DateTime.fromMillisecondsSinceEpoch(0);

    while (queue.isNotEmpty) {
      DateTime date = queue.first.dt;

      if ((getUnixMillisecondsOfMidnight(date) - getUnixMillisecondsOfMidnight(previousDate)).abs() >= millisecondsInDay) {
        result.add(_buildDayMark(date));
        previousDate = date;
      }
      result.add(_buildEvent(queue.removeFirst()));
    }

    return result;
  }

  int getUnixMillisecondsOfMidnight(DateTime date) {
    final lastMidnight = new DateTime(date.year, date.month, date.day);
    return lastMidnight.millisecondsSinceEpoch;
  }

  Widget _buildDayMark(DateTime date) {
    DateFormat formatter = new DateFormat('dd.MM, EE', Locale.fromSubtags(languageCode: 'ru', countryCode: 'RU').toLanguageTag());
    String text = formatter.format(date);

    DateTime today = new DateTime.now();
    const int oneDay = millisecondsInDay;
    const int twoDay = 2 * oneDay;
    int difference = getUnixMillisecondsOfMidnight(today) - getUnixMillisecondsOfMidnight(date);

    if (difference < oneDay && difference >= 0) {
      text = "Сегодня";
    }
    else
    if (difference < twoDay) {
      text = "Вчера";
    }

    return new Container(
      child: new ListTile(
        dense: true,
        title: new Text(text, style: new TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
      )
    );
  }

  Widget _buildEvent(Event event) {
    DateFormat formatter = new DateFormat('HH:mm:ss');
    String addInfo;
    event.addInfo.isEmpty? addInfo = '' : addInfo = "\t (" + event.addInfo + ")";
    return new Container(
      child: new ListTile(
        leading: selectIcon(event.code),
        title: new Text(event.code, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: new Text(event.sourceName + addInfo, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: new Text(formatter.format(event.dt.toLocal()), maxLines: 1, overflow: TextOverflow.ellipsis),
      )
    );
  }

  Icon selectIcon(String eventType) {
    switch (eventType) {
      case 'Авария':
        return const Icon(Icons.warning, color: historyColorAlarm);
      case 'Взятие':
        return const Icon(Icons.lock_outline, color: historyColorArmed);
      case 'Взят':
        return const Icon(Icons.lock_outline, color: historyColorArmed);
      case 'Запрос на взятие':
        return const Icon(Icons.call, color: historyColorArmed,);
      case 'Запрос на снятие':
        return const Icon(Icons.call, color: historyColorDisarmed,);
      case 'Извещение':
        return const Icon(Icons.priority_high,);
      case 'Команда':
        return const Icon(Icons.cake,);
      case 'Не охраняется':
        return const Icon(Icons.lock_open, color: historyColorDisarmed);
      case 'Охраняется':
        return const Icon(Icons.lock_outline, color: historyColorArmed);
      case 'Ошибка':
        return const Icon(Icons.cake, color: historyColorAlarm,);
      case 'Патруль':
        return const Icon(Icons.cake,);
      case 'Предупреждение':
        return const Icon(Icons.cake,);
      case 'Пропуск теста':
        return const Icon(Icons.cake,);
      case 'Сброс тревоги':
        return const Icon(Icons.cake,);
      case 'Снятие':
        return const Icon(Icons.lock_open, color: historyColorDisarmed);
      case 'Снят':
        return const Icon(Icons.lock_open, color: historyColorDisarmed);
      case 'Тест':
        return const Icon(Icons.cake,);
      case 'Тревога':
        return const Icon(Icons.warning, color: historyColorAlarm);
      case 'Устранение аварии':
        return const Icon(Icons.cake,);
      default:
        return null;
    }
  }
}