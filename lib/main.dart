import 'package:flutter/material.dart';
import 'package:splurge/copilot_parser.dart';
import 'package:splurge/pages/main_page.dart';
import 'package:splurge/util/widgets.dart';

void main() => runApp(AppWidget());

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Personal finances analyzer', style: appFont),
          backgroundColor: Colors.teal[800],
        ),
        body: Center(
          child: LoadThenShow(
            future: CopilotExportReader.loadData,
            widgetBuilder: MainPage.new,
          ),
        ),
      ),
    );
  }
}
