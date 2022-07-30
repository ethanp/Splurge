import 'package:flutter/material.dart';

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
