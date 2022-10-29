import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/pages/main_page.dart';

void main() {
  // TODO(UI): Use that tagger util to set the screen size on init, so that the
  //  content actually *fits*:
  //
  //    "A RenderFlex overflowed by 1446 pixels on the bottom."
  //

  /// [ProviderScope] is where the state of our providers will be stored.
  /// See: https://riverpod.dev/docs/getting_started
  runApp(const ProviderScope(child: AppWidget()));
}

class AppWidget extends StatelessWidget {
  const AppWidget();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        /* Right now, not feeling the AppBar.
        appBar: AppBar(
          title: Text('Personal finances analyzer', style: appFont),
          backgroundColor: Colors.teal[800],
        ),
         */
        body: Center(child: MainPage()),
      ),
    );
  }
}
