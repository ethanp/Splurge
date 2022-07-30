import 'dart:math' as math;

import 'package:intl/intl.dart';

extension DoubleIterable on Iterable<double> {
  double get min =>
      isEmpty ? 0 : skip(1).fold(first, (acc, e) => math.min(acc, e));

  double get max =>
      isEmpty ? 1 : skip(1).fold(first, (acc, e) => math.max(acc, e));

  double get sum => fold(0.0, (acc, e) => acc + e);
}

extension ComparableIterable<T extends Comparable> on Iterable<T> {
  T get min => skip(1).fold(first, (acc, e) => acc.compareTo(e) <= 0 ? acc : e);

  T get max => skip(1).fold(first, (acc, e) => acc.compareTo(e) >= 0 ? acc : e);

  List<T> get sorted => toList().sortOn<T>((i) => i);
}

extension IterableT<T> on Iterable<T> {
  List<U> mapL<U>(U Function(T) f) => map(f).toList(growable: false);

  double sumBy(double Function(T) fn) => map(fn).sum;

  U max<U extends Comparable>(U Function(T) fn) => fn(maxBy(fn));
  U min<U extends Comparable>(U Function(T) fn) => fn(minBy(fn));

  T minBy<U extends Comparable>(U Function(T) fn) => _inner(fn, (x) => x < 0);
  T maxBy<U extends Comparable>(U Function(T) fn) => _inner(fn, (x) => x > 0);

  List<U> mapWithIdx<U>(U Function(T, int) fn) {
    final ret = <U>[];
    int i = 0;
    for (final item in this) {
      ret.add(fn(item, i++));
    }
    return ret;
  }

  T _inner<U extends Comparable>(U Function(T) fn, bool Function(int) comp) {
    T bestSoFar = first;
    for (T curr in skip(1)) {
      if (comp(fn(curr).compareTo(fn(bestSoFar)))) {
        bestSoFar = curr;
      }
    }
    return bestSoFar;
  }
}

extension ListT<T> on List<T> {
  List<T> sortOn<U extends Comparable>(U Function(T) fn) =>
      this..sort((a, b) => fn(a).compareTo(fn(b)));

  List<T> keepLast({required int atMost}) =>
      sublist(math.max(length - atMost, 0));
}

extension Edouble on double {
  DateTime get toDate => DateTime.fromMillisecondsSinceEpoch(toInt());
}

extension EDateTime on DateTime {
  String get formatted {
    final dayOfWeek = DateFormat.E().format(this);
    final date = DateFormat.MMMd().format(this);
    final year = DateFormat.y().format(this);
    return '$dayOfWeek $date $year';
  }

  double get toDouble => millisecondsSinceEpoch.toDouble();
}
