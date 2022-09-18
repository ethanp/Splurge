import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/data_loading/copilot_parser.dart';
import 'package:splurge/data_loading/perscap_parser.dart';
import 'package:splurge/global/data_model.dart';
import 'package:splurge/util/extensions/riverpod_extensions.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

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

    bool matchesAllFilters(Transaction txn) {
      return [
        textFieldFilter,
        selectedCategoryFilter,
      ].all(
        (_) => _.includes(txn),
      );
    }

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
