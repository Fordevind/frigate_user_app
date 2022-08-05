import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/models/provider.dart';
import 'package:flutter_frigate_user_app/screens/login_page.dart';
import 'package:flutter_frigate_user_app/utils/netcode.dart';

class ProvidersPageNew extends StatefulWidget {
  @override
  _ProvidersPageNewState createState() => _ProvidersPageNewState();
}

class _ProvidersPageNewState extends State<ProvidersPageNew> {
  List<Provider> providers;
  Future<List<Provider>> data;
  String dpi;

  @override
  void initState() {
    getProvidersList();
    super.initState();
  }

  void getProvidersList() async {
    try {
      data = Netcode.getProvidersList();
    }
    on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: const Text("Не удалось получить список поставщиков услуг от сервера, превышен лимит времени"),
      ));
    }
    on FormatException {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: const Text("Не удалось расшифровать данные, полученные от сервера"),
      ));
    }
    catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: new Text(error.toString()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new RefreshIndicator(
        child: new FutureBuilder(
        future: data,
        builder: (BuildContext context, AsyncSnapshot<List<Provider>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isNotEmpty) {
              return new Container(
                padding: new EdgeInsets.all(24.0),
                child: new Align(
                  alignment: new Alignment(0.0, -0.5),
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _frigateLogo(),
                      new SizedBox(height: 20.0),
                      const Text('Выберите поставщика услуг'),
                      _providers(snapshot.data),
                    ],
                  )
                )
              );
            }
            else {
              return new SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: new Container(
                  child: new Center(
                    child: new Text('Не удалось загрузить данные с сервера'),
                  ),
                  height: MediaQuery.of(context).size.height,
                )
              );
            }
          }
          else {
            return new Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)
              )
            );
          }
        }
      ),
        onRefresh: _refresh,
      )
    );
  }

  Future<void> _refresh() async {
    if (this.mounted) setState(() {data = Netcode.getProvidersList();});
    //if (this.mounted) setState(() {});
  }

  Widget _frigateLogo() {
    return new CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 48.0,
      child: new Image.asset('images/logo.png'),
    );
  }

  Widget _providers(List<Provider> providers) {
    return new NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {overscroll.disallowIndicator();},
      child: new ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context, index) => new Divider(),
        itemCount: providers.length,
        itemBuilder: (context, index) => _buildProvider(providers[index]),
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
      title: new Text(provider.title?? provider.name, maxLines: 1, overflow: TextOverflow.ellipsis,),
      subtitle: provider.description != null? new Text(provider.description, maxLines: 1, overflow: TextOverflow.ellipsis,) : null,
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