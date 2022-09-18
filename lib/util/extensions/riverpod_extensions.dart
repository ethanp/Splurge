import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetNotifier<T> extends StateNotifier<Set<T>> {
  SetNotifier(super.state);

  bool contains(T e) => state.contains(e);

  void add(T e) => state = {...state..add(e)};

  void remove(T e) => state = {...state..remove(e)};

  void addAll(Iterable<T> es) => state = {...state..addAll(es)};

  bool containsAll(Iterable<T> es) => state.containsAll(es);

  void clear() => state = {};
}
