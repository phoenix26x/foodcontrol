// ignore_for_file: duplicate_import, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:zzz/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  get locationId => 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: LoginPage(locationId: locationId,)
    );
  }
}
