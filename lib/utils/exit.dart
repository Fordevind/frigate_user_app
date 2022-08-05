import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_frigate_user_app/definitions/global.dart';
import 'package:flutter_frigate_user_app/utils/secure_storage.dart';
import 'package:flutter_frigate_user_app/utils/shared_prefs.dart';

/// Удалить все данные из хранилища и вернуться на экран выбора поставщика услуг
void exit() async {
  globalDevices = null;
  await SharedPrefs.clear();
  SecureStorage.clear();
  await new Future.delayed(const Duration(seconds: 1));
  FirebaseMessaging.instance.unsubscribeFromTopic(fcmTopic);
  materialAppNavigator.currentState.pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
}