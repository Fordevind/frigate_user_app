import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/definitions/constants.dart';

const Color colorDanger   = Colors.red;
const Color colorArmed    = Colors.green;
const Color colorDisarmed = Colors.blue;
const Color colorUnknown  = Colors.grey;
const Color colorSelected = Color(0xFFCFD8DC);

const Color colorDisabledFAB = Colors.grey;
const Color colorFAB = Colors.blue;

const Color colorBackgroundSnackBar = Color(0xFFFFFFFF);
const Color colorTextSnackBar = Colors.black;

const Color raisedButtonEnabled = Colors.blue;
const Color raisedButtonDisabled = Color(0xFF90CAF9);

// Event related colors

const Color historyColorArmed = Color(0xFFA5D6A7);
const Color historyColorDisarmed = Color(0xFF4FC3F7);
const Color historyColorAlarm = Color(0xFFE57373);

SnackBar buildSnackBar(String text) {
  return new SnackBar(
    content: Text(text, style: TextStyle(color: colorTextSnackBar),),
    backgroundColor: colorBackgroundSnackBar,
  );
}

final textFormFieldBorder = new OutlineInputBorder(
  borderSide: const BorderSide(color: const Color(0xFFBDBDBD)),
  borderRadius: new BorderRadius.all(new Radius.circular(5.0))
);

Widget zoneIcon(String status) {
  switch (status) {
    case statusArmed:
      return const Icon(Icons.radio_button_checked, color: colorArmed);
    case statusDanger:
      return const Icon(Icons.radio_button_checked, color: colorDanger);
    case statusDisarmed:
      return const Icon(Icons.radio_button_checked, color: colorDisarmed);
    default:
      return const Icon(Icons.radio_button_checked, color: colorUnknown);
  }
}

Widget ppkopIcon(String status) {
  switch (status) {
    case statusArmed:
      return const Icon(const IconData(0xe963, fontFamily: 'icomoon'), color: colorArmed);
    case statusDanger:
      return const Icon(const IconData(0xe963, fontFamily: 'icomoon'), color: colorDanger);
    case statusDisarmed:
      return const Icon(const IconData(0xe963, fontFamily: 'icomoon'), color: colorDisarmed);
    default:
      return const Icon(const IconData(0xe963, fontFamily: 'icomoon'), color: colorUnknown);
  }
}

Icon prdIcon(String status) {
  switch (status) {
    case statusArmed:
      return const Icon(Icons.rss_feed, color: colorArmed);
    case statusDanger:
      return const Icon(Icons.rss_feed, color: colorDanger);
    case statusDisarmed:
      return const Icon(Icons.rss_feed, color: colorDisarmed);
    default:
      return const Icon(Icons.rss_feed, color: colorUnknown);
  }
}