import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/pages/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // So far, it doesn't seem to work to call this *after* calling runApp() :(
  const minReasonableSize = Size(1600, 800);
  if (Platform.isMacOS) await DesktopWindow.setWindowSize(minReasonableSize);

  runApp(AppWidget());
}

class AppWidget extends StatelessWidget {
  const AppWidget();

  @override
  Widget build(BuildContext context) {
    // [ProviderScope] is where the state of our providers will be stored.
    // See: https://riverpod.dev/docs/getting_started
    return ProviderScope(
      child: MaterialApp(
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
      ),
    );
  }
}
