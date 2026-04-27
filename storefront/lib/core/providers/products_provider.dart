import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import 'app_providers.dart';

// Category filter state
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Categories list
final categoriesProvider = FutureProvider<List<ProductCategory>>((ref) async {
  return ref.watch(productsApiProvider).listCategories();
});

// Product list filtered by category / search
final productsProvider = FutureProvider.family<List<Product>, _ProductsFilter>(
  (ref, filter) async {
    return ref.watch(productsApiProvider).listProducts(
          categoryId: filter.categoryId,
          search: filter.search,
          limit: filter.limit,
          offset: filter.offset,
        );
  },
);

// Convenience provider that wires up the selected filters
final filteredProductsProvider = FutureProvider<List<Product>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final search = ref.watch(searchQueryProvider);
  return ref.watch(productsProvider(_ProductsFilter(
    categoryId: category,
    search: search.isNotEmpty ? search : null,
  )).future);
});

// Single product
final productDetailProvider =
    FutureProvider.family<Product, String>((ref, id) async {
  return ref.watch(productsApiProvider).getProduct(id);
});

class _ProductsFilter {
  final String? categoryId;
  final String? search;
  final int limit;
  final int offset;

  const _ProductsFilter({
    this.categoryId,
    this.search,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  bool operator ==(Object other) =>
      other is _ProductsFilter &&
      other.categoryId == categoryId &&
      other.search == search &&
      other.limit == limit &&
      other.offset == offset;

  @override
  int get hashCode =>
      Object.hash(categoryId, search, limit, offset);
}
