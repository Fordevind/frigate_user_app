// Global variables
import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/models/device.dart';

/// Массив устройств
List<Device> globalDevices;
/// Cookie
var globalCookie;
/// Ключ для доступа к навигатору приложения
final GlobalKey<NavigatorState> materialAppNavigator = new GlobalKey();
/// Ключ для доступа к странице "Зоны"
final GlobalKey zonesKey = new GlobalKey();
/// Ключ для доступа к скаффолду, содержащему BottomNavigationBar
final homeScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: 'homeScaffoldKey');

String authURL;
String commandURL;

List<int> notificationDevicesList;

String fcmTopic;