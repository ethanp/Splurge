import 'package:flutter/material.dart';

void main() => runApp(EmptyApp());

class EmptyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Empty app')),
        body: const Center(
          child: Text('App booted successfully'),
        ),
      ),
    );
  }
}
