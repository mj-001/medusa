import 'cart.dart';

class OrderItem {
  final String id;
  final String title;
  final String? thumbnail;
  final int quantity;
  final int unitPrice;
  final int total;

  const OrderItem({
    required this.id,
    required this.title,
    this.thumbnail,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  String get formattedTotal => 'KES ${(total / 100).toStringAsFixed(2)}';

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        id: j['id'] as String,
        title: j['title'] as String,
        thumbnail: j['thumbnail'] as String?,
        quantity: (j['quantity'] as num).toInt(),
        unitPrice: (j['unit_price'] as num).toInt(),
        total: (j['total'] as num?)?.toInt() ?? 0,
      );
}

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled;

  static OrderStatus fromString(String s) =>
      OrderStatus.values.firstWhere((e) => e.name == s,
          orElse: () => OrderStatus.pending);

  String get label => switch (this) {
        OrderStatus.pending => 'Pending',
        OrderStatus.processing => 'Processing',
        OrderStatus.shipped => 'Shipped',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
      };
}

class Order {
  final String id;
  final String displayId;
  final OrderStatus status;
  final List<OrderItem> items;
  final int subtotal;
  final int shippingTotal;
  final int total;
  final ShippingAddress? shippingAddress;
  final String? email;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.displayId,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.shippingTotal,
    required this.total,
    this.shippingAddress,
    this.email,
    required this.createdAt,
  });

  String get formattedTotal => 'KES ${(total / 100).toStringAsFixed(2)}';
  String get formattedSubtotal => 'KES ${(subtotal / 100).toStringAsFixed(2)}';
  String get formattedShipping =>
      'KES ${(shippingTotal / 100).toStringAsFixed(2)}';

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'] as String,
        displayId: '#${j['display_id']}',
        status: OrderStatus.fromString(j['status'] as String? ?? 'pending'),
        items: (j['items'] as List<dynamic>? ?? [])
            .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
            .toList(),
        subtotal: (j['subtotal'] as num?)?.toInt() ?? 0,
        shippingTotal: (j['shipping_total'] as num?)?.toInt() ?? 0,
        total: (j['total'] as num?)?.toInt() ?? 0,
        shippingAddress: j['shipping_address'] != null
            ? ShippingAddress.fromJson(
                j['shipping_address'] as Map<String, dynamic>)
            : null,
        email: j['email'] as String?,
        createdAt: DateTime.parse(
            j['created_at'] as String? ?? DateTime.now().toIso8601String()),
      );
}
