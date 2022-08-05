import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/utils/exit.dart';

class MorePage extends StatelessWidget {
  Future<String> getVersionName() async {
    return Future.value('0.2.1');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(),
      body: new ListView(
        children: <Widget> [
          new ListTile(
            leading: new CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.phone),
            ),
            title: const Text('Связаться с поставщиком услуг'),
            onTap: () {},
          ),
          new ListTile(
            leading: new CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.book),
            ),
            title: const Text('Лицензии'),
            onTap: () {},
          ),
          new ListTile(
            leading: new CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.info),
            ),
            title: const Text('О приложении'),
            subtitle: new FutureBuilder(
              future: getVersionName(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return new Text("Версия: ${snapshot.data}");
                }
                return new Text('Обновление информации о версии ...');
              },
            ),
            onTap: () async {
              await materialAppNavigator.currentState.pushNamed('/home/about');
            },
          ),
          new ListTile(
            leading: new CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.notifications),
            ),
            title: const Text('Настроить список уведомлений'),
            onTap: () async {
              await materialAppNavigator.currentState.pushNamed('/home/notifications_list');
            },
          ),
          new ListTile(
            leading: new CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.exit_to_app),
            ),
            title: const Text('Выход'),
            onTap: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return new AlertDialog(
                    title: const Text('Подтверждение'),
                    content: const Text('Вы уверены, что хотите выйти? При этом сбросится код доступа и удалятся сценарии.'),
                    actions: <Widget>[
                      new TextButton(
                        child: const Text('Отмена'),
                        onPressed: () {Navigator.of(context).pop();},
                      ),
                      new TextButton(
                        child: const Text('Подтвердить'),
                        onPressed: exit
                      )
                    ],
                  );
                }
              );
            },
          )
        ]
      )
    );
  }
}