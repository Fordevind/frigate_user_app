import 'dart:convert';

import 'package:flutter_frigate_user_app/models/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_frigate_user_app/models/scenario.dart';

class SharedPrefs {
  static Future<void> saveScenariosToSharedPrefs(List<Scenario> scenarios) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs != null) {
        return prefs.setString('scenarios', json.encode(scenarios));
      }
      else throw Exception("Failed saving scenarios to Shared Preferences");
    }
    on Exception {
      rethrow;
    }
  }

  static Future<List<Scenario>> getScenariosFromSharedPrefs() async {
    List<Scenario> result = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs != null) {
        final bufPrefs = prefs.getString('scenarios');
        if (bufPrefs != null) {
          final buf = json.decode(bufPrefs).cast<Map<String, dynamic>>();
          result = buf.map<Scenario>((json) => Scenario.fromJson(json)).toList();
        }
        else return result;
      }
      else throw Exception("Failed getting scenarios from Shared Preferences");
      return result;
    }
    on Exception {
      rethrow;
    }
  }

  static Future<void> saveLogin(String login) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs != null) {
        return prefs.setString('login', login);
      }
      else throw Exception("Failed saving login to Shared Preferences");
    }
    on Exception {
      rethrow;
    }
  }

  static Future<String> getLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs != null) {
        final bufPrefs = prefs.getString('login')?? '';
        return bufPrefs;
      }
      else throw Exception("Failed getting login from Shared Preferences");
    }
    on Exception {
      rethrow;
    }
  }

  static Future<void> savePassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs != null) {
        return prefs.setString('password', password);
      }
      else throw Exception("Failed saving password to Shared Preferences");
    }
    on Exception {
      rethrow;
    }
  }

  static Future<String> getPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs != null) {
        final bufPrefs = prefs.getString('password')?? '';
        return bufPrefs;
      }
      else throw Exception("Failed getting password from Shared Preferences");
    }
    on Exception {
      rethrow;
    }
  }

  static Future<void> savePincode(String pincode) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs != null) {
        return prefs.setString('PIN', pincode);
      }
      else throw Exception("Failed saving pincode to Shared Preferences");
    }
    on Exception {
      rethrow;
    }
  }

  static Future<String> getPincode() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs != null) {
        final bufPrefs = prefs.getString('PIN')?? '';
        return bufPrefs;
      }
      else throw Exception("Failed getting pincode from Shared Preferences");
    }
    on Exception {
      rethrow;
    }
  }

  static Future<void> saveProvider(Provider provider) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs != null) {
        return prefs.setString('provider', json.encode(provider));
      }
      else throw Exception("Failed saving provider to Shared Preferences");
    }
    on Exception {
      rethrow;
    }
  }

  static Future<Provider> getProvider() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs != null) {
        final bufPrefs = prefs.getString('provider')?? '';
        print("bufPrefs: $bufPrefs");
        if (bufPrefs.isNotEmpty) {
          return Provider.fromJson(json.decode(bufPrefs));
        }
        else return null;
      }
      else throw Exception("Failed getting pincode from Shared Preferences");
    }
    on Exception {
      rethrow;
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs != null) {
        prefs.clear();
      }
      else throw Exception("Failed clear Shared Preferences");
    }
    on Exception {
      rethrow;
    }
  }

  static Future<void> setPincodeInputCounts(int counts) async {
    assert(counts >= 0);
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs != null) {
        return prefs.setInt('counts', counts);
      }
      else throw Exception("Failed saving counts to Shared Preferences");
    }
    on Exception {
      rethrow;
    }
  }

  static Future<int> getPincodeInputCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs != null) {
        return prefs.getInt('counts')?? 1;
      }
      else throw Exception("Failed getting counts from Shared Preferences");
    }
    on Exception {
      rethrow;
    }
  }

  static Future<void> saveNotificationsList(List<int> notificationsList) async {
    assert(notificationsList != null);
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs != null) {
        return prefs.setString('notificationsList', json.encode(notificationsList));
      }
      else throw Exception("Failed saving counts to Shared Preferences");
    }
    on Exception {
      rethrow;
    }
  }

  static Future<List<int>> getNotificationsList() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs != null) {
        final bufPrefs = prefs.getString('notificationsList');
        if (bufPrefs != null) return List.from(json.decode(bufPrefs));
        else return null;
      }
      else throw Exception("Failed getting counts from Shared Preferences");
    }
    on Exception {
      rethrow;
    }
  }
}