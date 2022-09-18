import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/data_loading/copilot_parser.dart';
import 'package:splurge/data_loading/perscap_parser.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

class SelectedCategories extends StateNotifier<Set<String>>
    with GlobalDatasetFilter {
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

  bool contains(String category) => state.contains(category);

  void add(String category) => state = {...state, category};

  void remove(String category) => state = {...state..remove(category)};
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

  DatasetNotifier({required Dataset preloaded}) : super(preloaded);

  /// Global view of ALL transactions.
  ///
  /// Empty until the database loads from disk.
  static final unfilteredProvider =
      StateNotifierProvider<DatasetNotifier, Dataset>(
          (ref) => DatasetNotifier.empty()..loadData());

  // TODO(Big bug): When no txns match the filter the app goes into the loading
  //  screen, with no way to come back out :(. We should probably return [null]
  //  for the not-loaded state, and leave empty for the no-data state.
  /// View of the entire transaction dataset that has been pre-filtered by the
  /// active filters.
  ///
  /// Empty until the database loads from disk.
  static final filteredProvider =
      StateNotifierProvider<DatasetNotifier, Dataset>((ref) {
    final up = ref.watch(unfilteredProvider);
    ref.watch(TextFilter.provider);
    ref.watch(SelectedCategories.provider);

    final tf = ref.read(TextFilter.provider.notifier);
    final sc = ref.read(SelectedCategories.provider.notifier);

    return DatasetNotifier(
      preloaded: Dataset(
        up.txns.whereL(
          (txn) => [tf, sc].all(
            (_) => _.includes(txn),
          ),
        ),
      ),
    );
  });

  /// Import all datasets in parallel.
  Future<void> loadData() async {
    final copilotF = CopilotExportReader.loadData;
    final perscapF = PerscapExportReader.loadData;
    state = Dataset.merge([await copilotF, await perscapF]);
  }
}
