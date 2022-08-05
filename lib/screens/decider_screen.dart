import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/models/provider.dart';
import 'package:flutter_frigate_user_app/screens/login_pincode.dart';
import 'package:flutter_frigate_user_app/screens/providers_page.dart';
//import 'package:flutter_frigate_user_app/screens/providers_page_new.dart';
import 'package:flutter_frigate_user_app/utils/secure_storage.dart';

class DeciderScreen extends StatelessWidget {
  Future<Map<String, dynamic>> getFromSecureStorage() async {
    String _login = await SecureStorage.getLogin();
    String _password = await SecureStorage.getPassword();
    String _pincode = await SecureStorage.getPincode();
    Provider _provider = await SecureStorage.getProvider();

    if (_login == null || _password == null || _provider == null || _pincode == null) return null;

    Map<String, dynamic> params = {
      'login': _login,
      'password': _password,
      'PIN': _pincode,
      'provider': _provider
    };

    return params;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getFromSecureStorage(),
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.hasData) {
          return new LoginPincode(
            login: snapshot.data['login'],
            password: snapshot.data['password'],
            pincode: snapshot.data['PIN'],
            provider: snapshot.data['provider'],
          );
        }
        else {
          return new ProvidersPage();
          //return new ProvidersPageNew();
        }
      },
    );
  }
}