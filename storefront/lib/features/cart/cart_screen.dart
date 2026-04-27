import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/cart.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart' as shared;

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => shared.ErrorState(
          message: 'Could not load cart',
          onRetry: () => ref.invalidate(cartProvider),
        ),
        data: (cart) {
          if (cart == null || cart.items.isEmpty) {
            return _EmptyCart();
          }
          return _CartContent(cart: cart);
        },
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined,
                size: 80, color: AppColors.textSecondary),
            const SizedBox(height: 20),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add some fresh produce to get started!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => context.go('/products'),
                child: const Text('Browse Products'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartContent extends ConsumerWidget {
  final Cart cart;
  const _CartContent({required this.cart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) =>
                _CartItemCard(item: cart.items[i], cartId: cart.id),
          ),
        ),
        _OrderSummary(cart: cart),
      ],
    );
  }
}

class _CartItemCard extends ConsumerStatefulWidget {
  final LineItem item;
  final String cartId;
  const _CartItemCard({required this.item, required this.cartId});

  @override
  ConsumerState<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends ConsumerState<_CartItemCard> {
  bool _updating = false;

  Future<void> _update(int quantity) async {
    setState(() => _updating = true);
    try {
      if (quantity == 0) {
        await ref.read(cartProvider.notifier).removeItem(widget.item.id);
      } else {
        await ref
            .read(cartProvider.notifier)
            .updateItem(widget.item.id, quantity);
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.thumbnail != null
                ? CachedNetworkImage(
                    imageUrl: item.thumbnail!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.formattedUnitPrice,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QBtn(
                      icon: item.quantity == 1
                          ? Icons.delete_outline
                          : Icons.remove,
                      onTap: _updating
                          ? null
                          : () => _update(item.quantity - 1),
                      destructive: item.quantity == 1,
                    ),
                    const SizedBox(width: 8),
                    _updating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                    const SizedBox(width: 8),
                    _QBtn(
                      icon: Icons.add,
                      onTap: _updating
                          ? null
                          : () => _update(item.quantity + 1),
                    ),
                    const Spacer(),
                    Text(
                      item.formattedTotal,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 72,
        height: 72,
        color: const Color(0xFFEEF2EE),
        child: const Icon(Icons.eco, color: AppColors.primaryLight),
      );
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool destructive;
  const _QBtn({required this.icon, this.onTap, this.destructive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: destructive
              ? AppColors.error.withOpacity(0.1)
              : (onTap == null
                  ? AppColors.divider
                  : AppColors.primary.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: destructive
              ? AppColors.error
              : (onTap == null ? AppColors.textSecondary : AppColors.primary),
        ),
      ),
    );
  }
}

class _OrderSummary extends ConsumerWidget {
  final Cart cart;
  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _Row('Subtotal', cart.formattedSubtotal),
            const SizedBox(height: 6),
            _Row('Delivery', cart.formattedShipping),
            const Divider(height: 24),
            _Row(
              'Total',
              cart.formattedTotal,
              bold: true,
              valueColor: AppColors.primary,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/checkout'),
              child: const Text('Proceed to Checkout'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _Row(this.label, this.value,
      {this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: bold ? 15 : 14,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            color:
                bold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
