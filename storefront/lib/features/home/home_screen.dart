import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/cart_provider.dart';
import '../../core/providers/products_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart' as shared;
import 'widgets/category_chip.dart';
import 'widgets/product_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final products = ref.watch(filteredProductsProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _AppBar(cartCount: cartCount),
          SliverToBoxAdapter(child: _SearchBar()),
          SliverToBoxAdapter(child: _PromoBanners()),
          SliverToBoxAdapter(
            child: shared.SectionHeader(
              title: 'Categories',
              onSeeAll: () => context.go('/products'),
            ),
          ),
          SliverToBoxAdapter(
            child: categories.when(
              data: (cats) => CategoryGrid(
                categories: cats,
                selectedId: selectedCategory,
                onSelect: (id) =>
                    ref.read(selectedCategoryProvider.notifier).state = id,
              ),
              loading: () => const SizedBox(
                  height: 90,
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2))),
              error: (_, __) =>
                  CategoryGrid(categories: [], selectedId: null, onSelect: (_) {}),
            ),
          ),
          SliverToBoxAdapter(
            child: shared.SectionHeader(
              title: selectedCategory != null ? 'Products' : 'Fresh Picks',
              onSeeAll: () => context.go('/products'),
            ),
          ),
          products.when(
            data: (prods) => prods.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('No products found',
                            style:
                                TextStyle(color: AppColors.textSecondary)),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => ProductCard(product: prods[i]),
                        childCount: prods.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                    ),
                  ),
            loading: () => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const shared.ProductCardSkeleton(),
                  childCount: 6,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: shared.ErrorState(
                message: 'Could not load products',
                onRetry: () => ref.invalidate(filteredProductsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBar extends ConsumerWidget implements SliverWidget {
  final int cartCount;
  const _AppBar({required this.cartCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      title: Row(
        children: [
          const Icon(Icons.eco_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: 8),
          const Text(
            'FreshKe',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Kenya',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () => context.push('/cart'),
              tooltip: 'Cart',
            ),
            if (cartCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

mixin SliverWidget on Widget {}

class _SearchBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: GestureDetector(
        onTap: () => context.go('/products'),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: const [
              SizedBox(width: 14),
              Icon(Icons.search, color: AppColors.textSecondary, size: 20),
              SizedBox(width: 10),
              Text('Search fresh produce...',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontFamily: 'Poppins')),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoBanners extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final banners = [
      _BannerData(
        label: 'Free delivery',
        subtitle: 'Orders over KES 2,000',
        color: const Color(0xFF1B5E20),
        icon: Icons.delivery_dining_rounded,
      ),
      _BannerData(
        label: 'Organic Veggies',
        subtitle: 'Up to 20% off this week',
        color: const Color(0xFF33691E),
        icon: Icons.eco_rounded,
      ),
      _BannerData(
        label: 'M-Pesa',
        subtitle: 'Fast & secure checkout',
        color: const Color(0xFF006064),
        icon: Icons.phone_android_rounded,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 140,
          viewportFraction: 0.88,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 4),
          enlargeCenterPage: true,
        ),
        items: banners
            .map((b) => _BannerCard(data: b))
            .toList(),
      ),
    );
  }
}

class _BannerData {
  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;
  _BannerData(
      {required this.label,
      required this.subtitle,
      required this.color,
      required this.icon});
}

class _BannerCard extends StatelessWidget {
  final _BannerData data;
  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          Icon(data.icon, size: 60, color: Colors.white.withOpacity(0.25)),
        ],
      ),
    );
  }
}
