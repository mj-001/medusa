import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/order.dart';
import '../../core/providers/orders_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart' as shared;

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => shared.ErrorState(
            message: 'Order not found',
            onRetry: () => ref.invalidate(orderDetailProvider(orderId))),
        data: (order) => _OrderDetailContent(order: order),
      ),
    );
  }
}

class _OrderDetailContent extends StatelessWidget {
  final Order order;
  const _OrderDetailContent({required this.order});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusCard(order: order),
          const SizedBox(height: 16),
          _Card(
            title: 'Items',
            child: Column(
              children: order.items
                  .map((item) => _ItemRow(item: item))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (order.shippingAddress != null)
            _Card(
              title: 'Delivery Address',
              child: _AddressBlock(address: order.shippingAddress!),
            ),
          const SizedBox(height: 16),
          _Card(
            title: 'Payment Summary',
            child: Column(
              children: [
                _Row('Subtotal', order.formattedSubtotal),
                const SizedBox(height: 6),
                _Row('Delivery', order.formattedShipping),
                const Divider(height: 20),
                _Row('Total', order.formattedTotal, bold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final Order order;
  const _StatusCard({required this.order});

  Color _color(OrderStatus s) => switch (s) {
        OrderStatus.delivered => AppColors.success,
        OrderStatus.cancelled => AppColors.error,
        OrderStatus.shipped => const Color(0xFF1565C0),
        OrderStatus.processing => AppColors.secondary,
        OrderStatus.pending => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color(order.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Order ${order.displayId}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Placed on ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (order.status != OrderStatus.delivered &&
              order.status != OrderStatus.cancelled) ...[
            const SizedBox(height: 16),
            const _DeliveryTimeline(),
          ],
        ],
      ),
    );
  }
}

class _DeliveryTimeline extends StatelessWidget {
  const _DeliveryTimeline();

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Order received',
      'Being packed',
      'Out for delivery',
      'Delivered',
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(height: 2, color: AppColors.primary.withOpacity(0.3)),
          );
        }
        final step = i ~/ 2;
        final done = step <= 1;
        return Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: done ? AppColors.primary : Colors.white,
                border: Border.all(
                    color: done ? AppColors.primary : AppColors.divider,
                    width: 2),
                shape: BoxShape.circle,
              ),
              child: done
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              steps[step],
              style: const TextStyle(fontSize: 9, fontFamily: 'Poppins'),
            ),
          ],
        );
      }),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco, color: AppColors.primaryLight),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 13)),
                Text('Qty: ${item.quantity}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text(
            item.formattedTotal,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressBlock extends StatelessWidget {
  final address;
  const _AddressBlock({required this.address});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (address.firstName != null)
          Text(
            '${address.firstName} ${address.lastName}',
            style: const TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w500),
          ),
        if (address.address1 != null)
          Text(address.address1,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontFamily: 'Poppins')),
        if (address.city != null)
          Text(address.city,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontFamily: 'Poppins')),
        Text('Kenya',
            style: const TextStyle(
                color: AppColors.textSecondary, fontFamily: 'Poppins')),
        if (address.phone != null)
          Row(
            children: [
              const Icon(Icons.phone, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(address.phone,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontFamily: 'Poppins')),
            ],
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _Row(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: bold ? 15 : 14,
                fontWeight:
                    bold ? FontWeight.w600 : FontWeight.w400,
                color: bold
                    ? AppColors.textPrimary
                    : AppColors.textSecondary)),
        Text(value,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: bold ? 16 : 14,
                fontWeight:
                    bold ? FontWeight.w700 : FontWeight.w500,
                color:
                    bold ? AppColors.primary : AppColors.textPrimary)),
      ],
    );
  }
}
