import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/global/style.dart';
import 'package:splurge/pages/main_page.dart';

void main() => runApp(
    // https://riverpod.dev/docs/getting_started
    // This is where the state of our providers will be stored.
    const ProviderScope(child: AppWidget()));

class AppWidget extends StatelessWidget {
  const AppWidget();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Personal finances analyzer', style: appFont),
          backgroundColor: Colors.teal[800],
        ),
        body: Center(child: MainPage()),
      ),
    );
  }
}
