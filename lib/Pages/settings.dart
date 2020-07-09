import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:buyinglist/globalVariables.dart' as globalVar;

import '../database_helper.dart';

class Settings extends StatefulWidget {
  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Text('Under Development !!!', style: _biggerFont),
      )
    );
  }
}