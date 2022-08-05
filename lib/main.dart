import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/screens/home.dart';
import 'package:flutter_frigate_user_app/screens/scenario_add.dart';
import 'package:flutter_frigate_user_app/screens/scenario_edit.dart';
import 'package:flutter_frigate_user_app/screens/scenario_params.dart';
import 'package:flutter_frigate_user_app/screens/device_history.dart';
import 'package:flutter_frigate_user_app/screens/about_program.dart';
import 'package:flutter_frigate_user_app/screens/decider_screen.dart';
import 'package:flutter_frigate_user_app/screens/notifications_list.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  Route onGenerateRoute(RouteSettings settings) {
    Route page;
    switch (settings.name) {
      case "/home":
        page = CupertinoPageRoute(builder: (context) => Home());
        break;
    }
    return page;
  }

  /// блокировка поворота экрана
  void _lockRotate() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.black));
  }

  @override
  Widget build(BuildContext context) {
    _lockRotate();
    return new MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: [const Locale('ru')],
      navigatorKey: materialAppNavigator,
      title: 'Фрегат ППКОП',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => DeciderScreen(),
        '/home/about': (BuildContext context) => AboutProgram(),
        '/home/deviceHistory': (BuildContext context) => DeviceHistory(),
        '/home/add': (BuildContext context) => ScenarioAdd(),
        '/home/edit': (BuildContext context) => ScenarioEdit(),
        '/home/notifications_list': (BuildContext context) => NotificationsList(),
        '/home/add/params': (BuildContext context) => ScenarioParams()
      },
      onGenerateRoute: onGenerateRoute,
    );
  }
}