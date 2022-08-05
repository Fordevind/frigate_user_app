import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/models/provider.dart';
import 'package:flutter_frigate_user_app/definitions/constants.dart';
import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/screens/login_page.dart';

class ProvidersPage extends StatefulWidget {
  @override
  _ProvidersPageState createState() => _ProvidersPageState();
}

class _ProvidersPageState extends State<ProvidersPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        padding: new EdgeInsets.all(24.0),
        child: new Align(
          alignment: new Alignment(0.0, -0.5),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _logo(),
              new SizedBox(height: 20.0),
              const Text('Выберите поставщика услуг'),
              _providers(),
            ],
          )
        )
      )
    );
  }

  Widget _logo() {
    return new CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 48.0,
      child: new Image.asset('images/logo.png'),
    );
  }

  Widget _providers() {
    List<Provider> _providers = [
      new Provider(name: 'ОБ Дозор-Р', urls: ['http://192.168.11.231:14002'], imageLocal: 'images/dozor_r.png', imageURL: 'http://dozor-r.ru/themes/dozor/img/logo.png'),
      new Provider(name: 'Купол', urls: [myServer], imageURL: 'https://static.tildacdn.com/tild3332-6638-4531-a232-326132323764/40-_copy.png'),
      new Provider(name: 'Локальный тестовый сервер', urls: [myServer], imageLocal: 'images/logo.png')
    ];
    return new NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {overscroll.disallowIndicator();},
      child: new ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context, index) => new Divider(),
        itemCount: _providers.length,
        itemBuilder: (context, index) => _buildProvider(_providers[index]),
      ),
    );
  }

  Widget _buildProvider(Provider provider) {
    return new ListTile(
      leading: new Hero(
        tag: provider.name,
        child: new CircleAvatar(
          backgroundColor: Colors.transparent,
          child: provider.imageLocal != null? new Image.asset(provider.imageLocal): new Image.network(provider.imageURL),
        )
      ),
      title: new Text(provider.name, maxLines: 1, overflow: TextOverflow.ellipsis,),
      onTap: () {
        materialAppNavigator.currentState.push(
          new MaterialPageRoute(
            builder: (context) => new LoginPage(provider),
          )
        );
      },
    );
  }
}