import 'package:flutter/material.dart';

class AboutProgram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: const Text('О приложении'),
      ),
      body: new Center(
        child: const Text('Lorem Ipsum'),
      ),
    );
  }
}