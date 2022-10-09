import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/data_loading/copilot_parser.dart';
import 'package:splurge/data_loading/perscap_parser.dart';
import 'package:splurge/global/data_model.dart';
import 'package:splurge/util/extensions/riverpod_extensions.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

class SelectedDateRange extends StateNotifier<DateTimeRange>
    with GlobalDatasetFilter {
  SelectedDateRange() : super(allTimeRange);

  static final provider =
      StateNotifierProvider<SelectedDateRange, DateTimeRange>(
          (ref) => SelectedDateRange());

  @override
  bool includes(Transaction txn) {
    final afterStart =
        txn.date.isAtSameMomentAs(state.start) || txn.date.isAfter(state.start);
    final beforeEnd = txn.date.isBefore(state.end);
    return afterStart && beforeEnd;
  }

  void reset() => state = allTimeRange;

  DateTimeRange get range => state;

  void lastMonths(int count) {
    final now = DateTime.now();
    final startOfLastMonth = DateTime(now.year, now.month - count);
    final startOfThisMonth = DateTime(now.year, now.month);
    state = DateTimeRange(start: startOfLastMonth, end: startOfThisMonth);
  }

  static DateTimeRange get allTimeRange => DateTimeRange(
        start: DateTime(2020, 12, 1),
        end: DateTime.now(),
      );

  void setStart(DateTime newStart) =>
      state = DateTimeRange(start: newStart, end: state.end);
}

class SelectedCategories extends SetNotifier<String> with GlobalDatasetFilter {
  SelectedCategories() : super({});

  /// One of several pre-filters for the global view of transactions.
  ///
  /// Rule: Let all pass if empty set, otw txn category must be in the set.
  ///
  static final provider =
      StateNotifierProvider<SelectedCategories, Set<String>>(
          (ref) => SelectedCategories());

  @override
  bool includes(Transaction txn) => state.isEmpty || contains(txn.category);
}

class TextFilter extends StateNotifier<String> with GlobalDatasetFilter {
  TextFilter() : super('');

  void updateTo(String v) => state = v;

  static final provider =
      StateNotifierProvider<TextFilter, String>((ref) => TextFilter());

  @override
  bool includes(Transaction txn) =>
      state.toLowerCase().split(' ').all(txn.title.toLowerCase().contains);
}

/// Interface for filters that can be applied to the global Dataset.
mixin GlobalDatasetFilter {
  /// True iff the given txn matches this filter.
  bool includes(Transaction txn);
}

class DatasetNotifier extends StateNotifier<Dataset> {
  DatasetNotifier.empty() : super(Dataset([]));

  DatasetNotifier(Dataset preloaded) : super(preloaded);

  /// Global view of ALL transactions.
  ///
  /// Empty until the database loads from disk.
  static final unfilteredProvider =
      StateNotifierProvider<DatasetNotifier, Dataset>(
          (ref) => DatasetNotifier.empty()..loadData());

  /// View of the entire transaction dataset that has been pre-filtered by the
  /// active filters.
  ///
  /// Empty until the database loads from disk.
  static final filteredProvider =
      StateNotifierProvider<DatasetNotifier, Dataset>((ref) {
    ref.watch(TextFilter.provider);
    final textFieldFilter = ref.read(TextFilter.provider.notifier);
    ref.watch(SelectedCategories.provider);
    final selectedCategoryFilter =
        ref.read(SelectedCategories.provider.notifier);
    ref.watch(SelectedDateRange.provider);
    final dateRangeFilter = ref.read(SelectedDateRange.provider.notifier);

    bool matchesAllFilters(Transaction txn) => [
          textFieldFilter,
          selectedCategoryFilter,
          dateRangeFilter,
        ].all((_) => _.includes(txn));

    final allTxns = ref.watch(unfilteredProvider);
    return DatasetNotifier(Dataset(allTxns.txns.whereL(matchesAllFilters)));
  });

  /// Import all datasets in parallel.
  Future<void> loadData() async {
    final copilotF = CopilotExportReader.loadData;
    final perscapF = PerscapExportReader.loadData;
    state = Dataset.merge([await copilotF, await perscapF]);
  }
}
