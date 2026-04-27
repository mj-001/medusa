import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/cart_provider.dart';
import '../../core/providers/products_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart' as shared;
import '../home/widgets/category_chip.dart';
import '../home/widgets/product_card.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final products = ref.watch(filteredProductsProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.push('/cart'),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                        color: AppColors.secondary, shape: BoxShape.circle),
                    child: Center(
                      child: Text('$cartCount',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).state = v,
              decoration: const InputDecoration(
                hintText: 'Search fresh produce...',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: null,
              ),
            ),
          ),
          categories.when(
            data: (cats) => CategoryGrid(
              categories: cats,
              selectedId: selectedCategory,
              onSelect: (id) =>
                  ref.read(selectedCategoryProvider.notifier).state = id,
            ),
            loading: () =>
                const SizedBox(height: 90, child: LinearProgressIndicator()),
            error: (_, __) =>
                CategoryGrid(categories: [], selectedId: null, onSelect: (_) {}),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: products.when(
              data: (prods) => prods.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off,
                              size: 56, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          Text(
                            searchQuery.isNotEmpty
                                ? 'No results for "$searchQuery"'
                                : 'No products in this category',
                            style: const TextStyle(
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: prods.length,
                      itemBuilder: (ctx, i) =>
                          ProductCard(product: prods[i]),
                    ),
              loading: () => GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: 8,
                itemBuilder: (_, __) => const shared.ProductCardSkeleton(),
              ),
              error: (e, _) => shared.ErrorState(
                message: 'Failed to load products.\nCheck your connection.',
                onRetry: () => ref.invalidate(filteredProductsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
