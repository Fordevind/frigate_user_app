import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_frigate_user_app/definitions/constants.dart';
import 'package:flutter_frigate_user_app/definitions/global.dart';

import 'package:flutter_frigate_user_app/screens/scenario_page.dart';
import 'package:flutter_frigate_user_app/screens/zones_page.dart';
import 'package:flutter_frigate_user_app/screens/more_page.dart';

import 'package:flutter_frigate_user_app/utils/netcode.dart';
import 'package:flutter_frigate_user_app/utils/shared_prefs.dart';

Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  print("onBackgroundMessage: $message");
  return Future<void>.value();
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final int _pageCount = 3;
  int _currentIndex = 0;
  Timer _timer;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  List<BottomNavigationBarItem> _items = [
    const BottomNavigationBarItem(icon: const Icon(Icons.subject),  label: 'Сценарии'),
    const BottomNavigationBarItem(icon: const Icon(Icons.device_hub), label: 'Устройства'),
    const BottomNavigationBarItem(icon: const Icon(Icons.more_horiz), label: 'Еще')
  ];

  @override
  void initState() {
    super.initState();
    firebaseCloudMessagingListeners();
    getNotificationList();

    WidgetsBinding.instance.addObserver(this);
  }

  void getNotificationList() async {
    notificationDevicesList = await SharedPrefs.getNotificationsList();
    if (notificationDevicesList == null) {
      notificationDevicesList = [];
      globalDevices.forEach((device) {notificationDevicesList.add(device.id);});
      await SharedPrefs.saveNotificationsList(notificationDevicesList);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        _timer = Timer.periodic(inActivityDuration, _logout);
        print('${DateTime.now().toLocal()}: Logout timer started');
        break;
      case AppLifecycleState.resumed:
        _timer.cancel();
        print('${DateTime.now().toLocal()}: Logout timer canceled');
        globalDevices = await Netcode.getState();
        if (zonesKey.currentState != null) zonesKey.currentState.setState(() {});
        break;
      default:
        break;
    }
    print("State: $state");
  }

  void _logout(Timer timer) {
    globalDevices = null;
    materialAppNavigator.currentState.pushNamedAndRemoveUntil('/', (route) => false);
    FirebaseMessaging.instance.unsubscribeFromTopic(fcmTopic);
    timer.cancel();
    print('${DateTime.now().toLocal()}: Logout');
  }

  void firebaseCloudMessagingListeners() async {
    //if (Platform.isIOS) iOSPermission();
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.getToken().then((token){print("FCM token: $token");});

    try {
      await FirebaseMessaging.instance.subscribeToTopic(fcmTopic);
      print("Subscriped to topic: $fcmTopic");
    }
    catch (e) {
      print("Home/firebaseCloudMessagingListeners: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Не удалось подписаться на уведомления"), duration: Duration(seconds: 60),));
    }

    var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/frigate_user_app_icon');

    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidRecieveLocalNotification);

    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    FirebaseMessaging.onMessage.listen((message) async {
      print('on message $message');
      displayNotification(message.toMap());
      globalDevices = await Netcode.getState();
      if (zonesKey.currentState != null) zonesKey.currentState.setState(() {});
    });
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  }
  /*
  void iOSPermission() {
    FirebaseMessaging.instance.requestNotificationPermissions(
      IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }
  */

  Future displayNotification(Map<String, dynamic> message) async{
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'statusChange', 'Изменение состояния',
        importance: Importance.max, priority: Priority.high);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      message['notification']['title'],
      message['notification']['body'],
      platformChannelSpecifics,
      payload: 'hello',);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  Future onDidRecieveLocalNotification(int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text(title),
        content: new Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: homeScaffoldKey,
      body: _body(),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  Widget _body() {
    return new Stack(
      children: new List<Widget>.generate(_pageCount, (int index) {
        return new IgnorePointer(
          ignoring: index != _currentIndex,
          child: new Opacity(
            opacity: _currentIndex == index ? 1.0 : 0.0,
            child: new Navigator(
              onGenerateRoute: (RouteSettings settings) {
                return new MaterialPageRoute(
                  builder: (_) => _page(index),
                  settings: settings,
                );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _page(int index) {
    assert(index < _pageCount && index >= 0);
    switch (index) {
      case 0:
        return new ScenarioPage();
      case 1:
        return new ZonesPage();
      case 2:
        return new MorePage();
      default:
        return new ZonesPage(key: zonesKey);
    }
  }

  BottomNavigationBar _bottomNavigationBar() {
    final theme = Theme.of(context);
    return new BottomNavigationBar(
      fixedColor: theme.colorScheme.secondary,
      currentIndex: _currentIndex,
      items: _items,
      showUnselectedLabels: false,
      onTap: (int index) {setState(() {_currentIndex = index;});}
    );
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}