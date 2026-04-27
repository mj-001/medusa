import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/order.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/orders_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart' as shared;

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (!auth.isLoggedIn) {
      return _SignInPrompt();
    }

    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Orders')),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => shared.ErrorState(
          message: 'Could not load orders',
          onRetry: () => ref.invalidate(ordersProvider),
        ),
        data: (orders) => orders.isEmpty
            ? _EmptyOrders()
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(ordersProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
                ),
              ),
      ),
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Orders')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline,
                  size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 20),
              const Text(
                'Sign in to view orders',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track your deliveries and view order history.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textSecondary, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => context.push('/auth/login'),
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/auth/register'),
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 72, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text(
            'No orders yet',
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your orders will appear here once you\nshop with us.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.textSecondary, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 180,
            child: ElevatedButton(
              onPressed: () => context.go('/products'),
              child: const Text('Start Shopping'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  Color _statusColor(OrderStatus s) => switch (s) {
        OrderStatus.delivered => AppColors.success,
        OrderStatus.cancelled => AppColors.error,
        OrderStatus.shipped => const Color(0xFF1565C0),
        OrderStatus.processing => AppColors.secondary,
        OrderStatus.pending => AppColors.textSecondary,
      };

  IconData _statusIcon(OrderStatus s) => switch (s) {
        OrderStatus.delivered => Icons.check_circle_rounded,
        OrderStatus.cancelled => Icons.cancel_rounded,
        OrderStatus.shipped => Icons.local_shipping_rounded,
        OrderStatus.processing => Icons.autorenew_rounded,
        OrderStatus.pending => Icons.hourglass_empty_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_statusIcon(order.status),
                      color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ${order.displayId}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      order.formattedTotal,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status.label,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (order.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontFamily: 'Poppins'),
                  ),
                  const SizedBox(width: 6),
                  const Text('·',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.items.map((i) => i.title).join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary, size: 18),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
