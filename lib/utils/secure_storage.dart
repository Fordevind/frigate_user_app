import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_frigate_user_app/definitions/constants.dart';
import 'package:flutter_frigate_user_app/models/provider.dart';

class SecureStorage {
  static FlutterSecureStorage _secureStorage = new FlutterSecureStorage();

  static void saveLogin(String login) async {
    try {
      await _secureStorage.write(key: 'login', value: login);
    }
    catch (e) {
      print("SecureStorage.saveLogin: ${e.toString()}");
    }
  }

  static Future<String> getLogin() async {
    try {
      return await _secureStorage.read(key: 'login');
    }
    catch (e) {
      print("SecureStorage.getLogin: ${e.toString()}");
      return null;
    }
  }

  static void savePassword(String password) async {
    try {
      await _secureStorage.write(key: 'password', value: password);
    }
    catch (e) {
      print("SecureStorage.savePassword: ${e.toString()}");
    }
  }

  static Future<String> getPassword() async {
    try {
      return await _secureStorage.read(key: 'password');
    }
    catch (e) {
      print("SecureStorage.getPassword: ${e.toString()}");
      return null;
    }
  }

  static void savePincode(String pincode) async {
    try {
      await _secureStorage.write(key: 'PIN', value: pincode);
    }
    catch (e) {
      print("SecureStorage.savePincode: ${e.toString()}");
    }
  }

  static Future<String> getPincode() async {
    try {
      return await _secureStorage.read(key: 'PIN');
    }
    catch (e) {
      print("SecureStorage.getPincode: ${e.toString()}");
      return null;
    }
  }

  static void saveProvider(Provider provider) async {
    try {
      await _secureStorage.write(key: 'provider', value: json.encode(provider));
    }
    catch (e) {
      print("SecureStorage.saveProvider: ${e.toString()}");
    }
  }

  static Future<Provider> getProvider() async {
    try {
      final buf = await _secureStorage.read(key: 'provider');
      if (buf != null) {
        return Provider.fromJson(json.decode(buf));
      }
      else {
        return null;
      }
    }
    catch (e) {
      print("SecureStorage.getProvider: ${e.toString()}");
      return null;
    }
  }

  static void setCountsInput(int counts) async {
    assert(counts >= 0);
    try {
      if (counts >= 0 ) await _secureStorage.write(key: 'countsInput', value: counts.toString());
      else await _secureStorage.write(key: 'countsInput', value: '0');
    }
    catch (e) {
      print("SecureStorage.setCountsInput: ${e.toString()}");
    }
  }

  static Future<int> getCountsInput() async {
    try {
      final buf = await _secureStorage.read(key: 'countsInput');
      if (buf != null) {
        return int.tryParse(buf);
      }
      else {
        return defaultAttempts;
      }
    }
    catch (e) {
      print("SecureStorage.getCountsInput: ${e.toString()}");
      return 3;
    }
  }

  static void clear() async {
    try {
      await _secureStorage.deleteAll();
    }
    catch (e) {
      print("SecureStorage.deleteAll: ${e.toString()}");
    }
  }

}