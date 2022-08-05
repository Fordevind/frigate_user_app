import 'package:flutter/material.dart';

void showAlertDialog(BuildContext context, {String title, String message, Duration displayDuration}) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return new AlertDialog(
        title: title != null? new Text(title) : null,
        content: new Text(message?? ''),
      );
    }
  );
  //await new Future.delayed(displayDuration?? defaultDisplayDuration);
  //Navigator.of(context).pop();
}

void showSnackBar(BuildContext context, String message) async {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message),));
}