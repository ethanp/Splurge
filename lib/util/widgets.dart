import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shows a spinner until the [future] loads, then renders [widgetBuilder].
class LoadThenShow<T> extends StatelessWidget {
  const LoadThenShow({
    required this.future,
    required this.widgetBuilder,
  });

  final Future<T> future;
  final Widget Function(T) widgetBuilder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (ctx, snapshot) => snapshot.hasData
          ? widgetBuilder(snapshot.data as T)
          : const CircularProgressIndicator(),
    );
  }
}

final appFont = GoogleFonts.merriweather();

final titleStyle = appFont.copyWith(fontSize: 20);
