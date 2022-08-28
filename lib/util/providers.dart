import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/data_model.dart';

// TODO: Implement.
/// Global view of ALL transactions.
final fullDatasetProvider =
    StateNotifierProvider((ref) => SelectedCategories());

/// One of several pre-filters for the global view of transactions.
///
/// Rule: Let all pass if empty set, otw txn category must be in the set.
///
final selectedCategoriesProvider =
    StateNotifierProvider<SelectedCategories, Set<String>>(
        (ref) => SelectedCategories());

// TODO: Implement.
/// One of several pre-filter for the global view of transactions.
///
/// Rule: Txn title must match text.
///
final textFilterProvider =
    StateNotifierProvider<TextNotifier, TextEditingController>(
        (ref) => TextNotifier());

// TODO: Implement.
/// View of the entire transaction dataset that has been pre-filtered by the
/// active filters.
final filteredDatasetProvider =
    StateNotifierProvider((ref) => DatasetNotifier());

class SelectedCategories extends StateNotifier<Set<String>>
    with GlobalDatasetFilter {
  SelectedCategories() : super({});

  @override
  bool includes(Transaction txn) => state.isEmpty || contains(txn.category);

  bool contains(String category) => state.contains(category);

  void add(String category) => state = {...state, category};

  void remove(String category) => state = {...state..remove(category)};
}

// TODO: Implement.
class TextFilter extends StateNotifier<String> with GlobalDatasetFilter {
  TextFilter() : super('');

  @override
  bool includes(Transaction txn) => txn.title.contains(state);
}

/// Interface for filters that can be applied to the global Dataset.
mixin GlobalDatasetFilter {
  /// True iff the given txn matches this filter.
  bool includes(Transaction txn);
}

class DatasetNotifier extends StateNotifier<Dataset> {
  DatasetNotifier() : super(Dataset([]));
}

class TextNotifier extends StateNotifier<TextEditingController> {
  TextNotifier() : super(TextEditingController());
}
