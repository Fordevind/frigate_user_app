// ignore_for_file: missing_return

import 'package:flutter/material.dart';

import 'package:flutter_frigate_user_app/definitions/constants.dart';
import 'package:flutter_frigate_user_app/definitions/theme.dart';

class ScenarioParams extends StatefulWidget {
  @override
  _ScenarioParamsState createState() => _ScenarioParamsState();
}

class _ScenarioParamsState extends State<ScenarioParams> {
  /// key формы
  final _formKey = GlobalKey<FormState>();
  /// параметры, возвращаемые на предыдущую страницу
  Map<String, dynamic> _params = new Map();
  /// переменная, управляющая значением RadioButton
  int _radioValue1 = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: new Scaffold(
        appBar: new AppBar(
          title: const Text('Введите параметры сценария'),
            leading: new IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {Navigator.of(context).pop();}
          )
        ),
        body: new Container(
          padding: new EdgeInsets.all(16.0),
          child: _buildForm(),
        )
      ),
    );
  }

  Form _buildForm() {
    _params = { 'name': '', 'type': '' };
    return new Form(
      key: _formKey,
      child: new NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {overscroll.disallowIndicator();},
        child: new ListView(
          children: <Widget>[
            new Center(child: const Text('Выберите тип сценария')),
            _selectType(),
            new SizedBox(height: 16.0),
            _inputName(),
            new SizedBox(height: 16.0),
            _okButton()
          ],
        )
      )
    );
  }

  ListView _selectType() {
    return new ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        new RadioListTile(
          title: const Text('Взять'),
          value: 0,
          groupValue: _radioValue1,
          onChanged: _handleRadioValueChange,
        ),
        new RadioListTile(
          title: const Text('Снять'),
          value: 1,
          groupValue: _radioValue1,
          onChanged: _handleRadioValueChange,
        )
      ],
    );
  }

  TextFormField _inputName() {
    return new TextFormField(
      textInputAction: TextInputAction.done,
      //autovalidate: true,
      maxLength: 30,
      initialValue: 'Новый сценарий',
      decoration: new InputDecoration(
        hintText: 'Название сценария',
        helperText: 'Не более 30 символов',
        filled: false,
        border: textFormFieldBorder,
        enabledBorder: textFormFieldBorder,
        focusedBorder: textFormFieldBorder,
        contentPadding: EdgeInsets.all(16.0)
      ),
      validator: (value) {
        if (value.isEmpty) return 'Пожалуйста, введите название';
        _params['name'] = value.trim();
      },
    );
  }

  RaisedButton _okButton() {
    return RaisedButton(
      child: const Text('OK'),
      color: Colors.blue,
      textColor: Colors.white,
      onPressed: _onPressed,
    );
  }

  void _handleRadioValueChange(int value) {
    setState(() { _radioValue1 = value; });
  }

  String selectType(int radioValue) {
    switch (radioValue) {
      case 0 :
        return messageArm;
      case 1:
        return messageDisarm;
      default:
        return messageArm;
    }
  }

  void _onPressed() {
    if (_formKey.currentState.validate()) {
      _params['type'] = selectType(_radioValue1);
      Navigator.of(context).pop(_params);
    }
  }
}