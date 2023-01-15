import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/data_loading/copilot_parser.dart';
import 'package:splurge/data_loading/perscap_parser_new.dart';
import 'package:splurge/data_loading/perscap_parser_old.dart';
import 'package:splurge/global/data_model.dart';
import 'package:splurge/util/extensions/riverpod_extensions.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

class SelectedDateRange extends StateNotifier<DateTimeRange>
    with GlobalDatasetFilter {
  SelectedDateRange() : super(allTimeRange);

  static final provider =
      StateNotifierProvider<SelectedDateRange, DateTimeRange>(
          (ref) => SelectedDateRange());

  static DateTimeRange get allTimeRange => DateTimeRange(
        start: DateTime(2020, 12, 1),
        end: DateTime.now(),
      );

  @override
  bool includes(Transaction txn) => txn.isWithinDateRange(range);

  void reset() => state = allTimeRange;

  DateTimeRange get range => state;

  void priorMonths(int count) {
    final now = DateTime.now();
    final startOfLastMonth = DateTime(now.year, now.month - count);
    final startOfThisMonth = DateTime(now.year, now.month);
    state = DateTimeRange(start: startOfLastMonth, end: startOfThisMonth);
  }

  void setRange(DateTimeRange range) => state = range;

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

  void checkFor(String v) => state = v;

  static final provider =
      StateNotifierProvider<TextFilter, String>((ref) => TextFilter());

  /// True iff every "word" in the query is a substring of the transaction's
  /// title, ignoring case.
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
          (ref) => DatasetNotifier.empty().._loadData());

  /// View of the entire transaction dataset that has been pre-filtered by the
  /// active filters.
  ///
  /// Empty until the database loads from disk.
  static final filteredProvider =
      StateNotifierProvider<DatasetNotifier, Dataset>(
          (ref) => DatasetNotifier(_txnsMatchingAllFilters(ref)));

  /// Import all datasets in parallel.
  Future<void> _loadData() async {
    // The code is formatted with the loads explicitly *initiated* before any of
    // the `await`s get evaluated.

    // Initiate all loads before doing any awaiting.
    final Future<Dataset?> copilotF = CopilotExportReader.loadData;
    final Future<Dataset?> perscapF = () async {
      // First try old format then new format.
      final Dataset? oldFormat = await OldPerscapExportReader.loadData;
      if (oldFormat != null)
        return oldFormat;
      else
        return await NewPerscapExportReader.loadData;
    }();

    // Awaits.
    state = Dataset.merge([
      await copilotF,
      await perscapF,
    ]);
  }

  static Dataset _txnsMatchingAllFilters(
      StateNotifierProviderRef<DatasetNotifier, Dataset> ref) {
    ref.watch(TextFilter.provider);
    final TextFilter textFieldFilter = ref.read(TextFilter.provider.notifier);
    ref.watch(SelectedCategories.provider);
    final SelectedCategories selectedCategoryFilter =
        ref.read(SelectedCategories.provider.notifier);
    ref.watch(SelectedDateRange.provider);
    final SelectedDateRange dateRangeFilter =
        ref.read(SelectedDateRange.provider.notifier);
    final Dataset allTxns = ref.watch(unfilteredProvider);

    bool matchesAllFilters(Transaction txn) => [
          textFieldFilter,
          selectedCategoryFilter,
          dateRangeFilter,
        ].all((_) => _.includes(txn));

    return allTxns.where(matchesAllFilters);
  }
}
