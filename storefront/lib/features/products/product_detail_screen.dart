import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/product.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/products_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart' as shared;

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  String? _selectedVariantId;
  bool _adding = false;

  void _selectVariant(String id) => setState(() => _selectedVariantId = id);

  ProductVariant? _variant(Product p) {
    if (_selectedVariantId != null) {
      return p.variants
          .where((v) => v.id == _selectedVariantId)
          .firstOrNull;
    }
    return p.defaultVariant;
  }

  Future<void> _addToCart(Product p) async {
    final variant = _variant(p);
    if (variant == null) return;
    setState(() => _adding = true);
    try {
      await ref
          .read(cartProvider.notifier)
          .addItem(variant.id, quantity: _quantity);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${p.title} added to cart'),
          backgroundColor: AppColors.success,
        ),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productDetailProvider(widget.productId));
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: product.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => shared.ErrorState(
          message: 'Product not found',
          onRetry: () =>
              ref.invalidate(productDetailProvider(widget.productId)),
        ),
        data: (p) {
          final variant = _variant(p);
          final price = variant?.kesPrice;
          final inStock = variant?.inStock ?? false;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                leading: IconButton(
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8)
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 16, color: AppColors.textPrimary),
                  ),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8)
                            ],
                          ),
                          child: const Icon(Icons.shopping_cart_outlined,
                              size: 18, color: AppColors.textPrimary),
                        ),
                        onPressed: () => context.push('/cart'),
                      ),
                      if (cartCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle),
                            child: Center(
                              child: Text('$cartCount',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: shared.ProductImage(
                    url: p.thumbnail ??
                        (p.images.isNotEmpty ? p.images.first.url : null),
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category chips
                      if (p.categories.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          children: p.categories
                              .map((c) => Chip(
                                    label: Text(c.name,
                                        style: const TextStyle(fontSize: 11)),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ))
                              .toList(),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        p.title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            price?.formatted ?? '—',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: inStock
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              inStock ? 'In stock' : 'Out of stock',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: inStock
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (p.description != null &&
                          p.description!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Description',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p.description!,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ],
                      // Variants
                      if (p.variants.length > 1) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Options',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: p.variants
                              .map((v) => ChoiceChip(
                                    label: Text(v.title),
                                    selected: (_selectedVariantId ?? p.defaultVariant?.id) == v.id,
                                    onSelected: (sel) {
                                      if (sel) _selectVariant(v.id);
                                    },
                                    selectedColor: AppColors.primary
                                        .withOpacity(0.15),
                                    labelStyle: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: (_selectedVariantId ??
                                                  p.defaultVariant?.id) ==
                                              v.id
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Quantity selector
                      Row(
                        children: [
                          const Text('Quantity',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                          const Spacer(),
                          _QuantitySelector(
                            quantity: _quantity,
                            onChanged: (q) =>
                                setState(() => _quantity = q),
                          ),
                        ],
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: product.valueOrNull != null
          ? SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: ElevatedButton.icon(
                  onPressed: (product.valueOrNull?.defaultVariant?.inStock ??
                              false) &&
                          !_adding
                      ? () => _addToCart(product.valueOrNull!)
                      : null,
                  icon: _adding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.add_shopping_cart),
                  label: Text(_adding ? 'Adding…' : 'Add to Cart'),
                ),
              ),
            )
          : null,
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantitySelector(
      {required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QBtn(
            icon: Icons.remove,
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null),
        const SizedBox(width: 4),
        SizedBox(
          width: 40,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 4),
        _QBtn(icon: Icons.add, onTap: () => onChanged(quantity + 1)),
      ],
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.primary : AppColors.divider,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
