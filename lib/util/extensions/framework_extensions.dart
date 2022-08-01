import 'dart:math' as math;

import 'package:intl/intl.dart';

/// The goal of this package is to provide methods that "satisfying" in the
/// way using Ruby on Rails is "satisfying". In part, it's that feeling that
/// there are people out there with good design sense.

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

  T? get maybeLast => isEmpty ? null : last;

  double sumBy(double Function(T) fn) => map(fn).sum;

  double avgBy(double Function(T) fn) => map(fn).sum / length;

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

extension EDateTime on DateTime {
  /// Eg. 'Sat Jul 30 2022'
  String get formatted {
    final dayOfWeek = DateFormat.E().format(this);
    final date = DateFormat.MMMd().format(this);
    final year = DateFormat.y().format(this);
    return '$dayOfWeek $date $year';
  }

  /// Eg. 'Jul 2022'
  String get monthString {
    final date = DateFormat.MMM().format(this);
    final year = DateFormat.y().format(this);
    return '$date $year';
  }

  int get qtr => (month ~/ 4) + 1;

  /// Eg. 'Q1 2022'
  String get qtrString {
    final year = DateFormat.y().format(this);
    return 'Q$qtr $year';
  }

  double get toDouble => millisecondsSinceEpoch.toDouble();
}

extension EDouble on double {
  DateTime get toDate => DateTime.fromMillisecondsSinceEpoch(toInt());

  /// Eg. 235768.2359 => '$235K'
  String asCompactDollars() {
    return NumberFormat.compactCurrency(
      locale: 'en_US',
      symbol: '\$',
    ).format(this);
  }
}

extension ENum on num {
  double get degreesToRadians => this * math.pi / 180;

  double get radianToDegree => this * 180 / math.pi;
}

extension EInt on int {
  /// Eg. 1 => '1st', 2 => '2nd', 3 => '3rd', 4 => '4th', etc.
  String get ith {
    String suffix;
    if (this == 1 || this > 20 && this % 10 == 1)
      suffix = 'st';
    else if (this == 2 || this > 20 && this % 10 == 2)
      suffix = 'nd';
    else if (this == 3 || this > 20 && this % 10 == 3)
      suffix = 'rd';
    else
      suffix = 'th';
    return '${toString()}$suffix';
  }

  int mustBeAtLeast(int n) => math.max(this, n);
}

extension SeparatorI<T> on Iterable<T> {
  List<T> separatedBy(T separator) =>
      expand((e) => [e, separator]).toList()..removeLast();
}