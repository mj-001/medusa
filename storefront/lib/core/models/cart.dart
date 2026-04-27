import 'product.dart';

class LineItem {
  final String id;
  final String variantId;
  final String productId;
  final String title;
  final String? thumbnail;
  final int quantity;
  final int unitPrice;
  final int total;

  const LineItem({
    required this.id,
    required this.variantId,
    required this.productId,
    required this.title,
    this.thumbnail,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  String get formattedUnitPrice =>
      'KES ${(unitPrice / 100).toStringAsFixed(2)}';
  String get formattedTotal => 'KES ${(total / 100).toStringAsFixed(2)}';

  factory LineItem.fromJson(Map<String, dynamic> j) => LineItem(
        id: j['id'] as String,
        variantId: (j['variant_id'] ?? j['variant']?['id'] ?? '') as String,
        productId: (j['product_id'] ?? j['variant']?['product_id'] ?? '') as String,
        title: j['title'] as String,
        thumbnail: j['thumbnail'] as String?,
        quantity: (j['quantity'] as num).toInt(),
        unitPrice: (j['unit_price'] as num).toInt(),
        total: (j['total'] as num?)?.toInt() ?? 0,
      );
}

class ShippingAddress {
  final String? firstName;
  final String? lastName;
  final String? address1;
  final String? address2;
  final String? city;
  final String? countryCode;
  final String? phone;

  const ShippingAddress({
    this.firstName,
    this.lastName,
    this.address1,
    this.address2,
    this.city,
    this.countryCode,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'address_1': address1,
        'address_2': address2,
        'city': city,
        'country_code': countryCode ?? 'ke',
        'phone': phone,
      };

  factory ShippingAddress.fromJson(Map<String, dynamic> j) => ShippingAddress(
        firstName: j['first_name'] as String?,
        lastName: j['last_name'] as String?,
        address1: j['address_1'] as String?,
        address2: j['address_2'] as String?,
        city: j['city'] as String?,
        countryCode: j['country_code'] as String?,
        phone: j['phone'] as String?,
      );
}

class ShippingOption {
  final String id;
  final String name;
  final int amount;

  const ShippingOption({
    required this.id,
    required this.name,
    required this.amount,
  });

  String get formattedAmount => 'KES ${(amount / 100).toStringAsFixed(2)}';

  factory ShippingOption.fromJson(Map<String, dynamic> j) => ShippingOption(
        id: j['id'] as String,
        name: j['name'] as String,
        amount: (j['amount'] as num).toInt(),
      );
}

class Cart {
  final String id;
  final List<LineItem> items;
  final int? subtotal;
  final int? shippingTotal;
  final int? total;
  final ShippingAddress? shippingAddress;
  final String? email;
  final String? regionId;

  const Cart({
    required this.id,
    required this.items,
    this.subtotal,
    this.shippingTotal,
    this.total,
    this.shippingAddress,
    this.email,
    this.regionId,
  });

  String get formattedSubtotal =>
      'KES ${((subtotal ?? 0) / 100).toStringAsFixed(2)}';
  String get formattedShipping =>
      'KES ${((shippingTotal ?? 0) / 100).toStringAsFixed(2)}';
  String get formattedTotal =>
      'KES ${((total ?? 0) / 100).toStringAsFixed(2)}';

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  factory Cart.fromJson(Map<String, dynamic> j) => Cart(
        id: j['id'] as String,
        items: (j['items'] as List<dynamic>? ?? [])
            .map((i) => LineItem.fromJson(i as Map<String, dynamic>))
            .toList(),
        subtotal: (j['subtotal'] as num?)?.toInt(),
        shippingTotal: (j['shipping_total'] as num?)?.toInt(),
        total: (j['total'] as num?)?.toInt(),
        shippingAddress: j['shipping_address'] != null
            ? ShippingAddress.fromJson(
                j['shipping_address'] as Map<String, dynamic>)
            : null,
        email: j['email'] as String?,
        regionId: j['region_id'] as String?,
      );
}
