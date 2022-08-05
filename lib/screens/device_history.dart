import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/models/device.dart';
import 'package:flutter_frigate_user_app/models/event.dart';
import 'package:flutter_frigate_user_app/utils/netcode.dart';
import 'package:flutter_frigate_user_app/ui/history_listview_stateless.dart';

class DeviceHistory extends StatefulWidget {
  @override
  _DeviceHistoryState createState() => _DeviceHistoryState();
}

class _DeviceHistoryState extends State<DeviceHistory> {
  bool first = true;
  Device deviceReceived;

  final _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  Future<List<Event>> data;

  @override
  Widget build(BuildContext context) {
    if (first) {
      deviceReceived = ModalRoute.of(context).settings.arguments as Device;
      data = fetchHistory();
      first = false;
    }

    return Scaffold(
      appBar: new AppBar(
        title: new Text(deviceReceived.name),
        actions: [
          //new IconButton(icon: Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: new FutureBuilder(
        future: data,
        builder: (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
          /*
          if (snapshot.hasError) {
            return new RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _refresh,
              child: new SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: new Container(
                  height: MediaQuery.of(context).size.height - Scaffold.of(context).appBarMaxHeight,
                  child: new Center(
                    child: new Text('Не удалось загрузить историю с сервера'),
                  ),
                )
              )
            );
          }
          */
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty) {
              return new RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refresh,
                child: new SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: new Container(
                    height: MediaQuery.of(context).size.height - Scaffold.of(context).appBarMaxHeight,
                    child: new Center(
                      child: new Text('Нет событий за последние пять дней'),
                    ),
                  )
                )
              );
            }
            else {
              return new RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refresh,
                child: new HistoryListView(snapshot.data)
              );
            }
          }
          else {
            return new Center(
              child: new CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)
              )
            );
          }
        },
      )
    );
  }

  Future<List<Event>> fetchHistory() async {
    return await Netcode.getHistoryDevice(deviceReceived);
  }

  Future<void> _refresh() async {
    if (this.mounted) setState(() {data = fetchHistory();});
  }

  NestedScrollView nestedScrollView() {
    return new NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          new SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: new FlexibleSpaceBar(
              centerTitle: true,
              title: new Text(deviceReceived.name),
            ),
          ),
        ];
      },

      body: new StreamBuilder(
        //stream: ,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Center(
              child: new CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)
              )
            );
          }
          else {
            return ListView.separated(
              padding: new EdgeInsets.all(12.0),
              itemBuilder: (context, index) => new ListTile(),
              separatorBuilder: (context, index) => new Divider(),
              itemCount: snapshot.data.documents.length,
            );
          }
        }
      )
    );
  }
}