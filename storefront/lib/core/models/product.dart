class ProductCategory {
  final String id;
  final String name;
  final String handle;
  final String? description;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.handle,
    this.description,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> j) => ProductCategory(
        id: j['id'] as String,
        name: j['name'] as String,
        handle: j['handle'] as String,
        description: j['description'] as String?,
      );
}

class ProductImage {
  final String id;
  final String url;

  const ProductImage({required this.id, required this.url});

  factory ProductImage.fromJson(Map<String, dynamic> j) =>
      ProductImage(id: j['id'] as String, url: j['url'] as String);
}

class MoneyAmount {
  final int amount;
  final String currencyCode;

  const MoneyAmount({required this.amount, required this.currencyCode});

  factory MoneyAmount.fromJson(Map<String, dynamic> j) => MoneyAmount(
        amount: (j['amount'] as num).toInt(),
        currencyCode: j['currency_code'] as String,
      );

  /// Returns amount as a human-readable string (e.g. KES 250.00)
  String get formatted {
    final units = amount / 100;
    return '${currencyCode.toUpperCase()} ${units.toStringAsFixed(2)}';
  }
}

class ProductVariant {
  final String id;
  final String title;
  final int? inventoryQuantity;
  final List<MoneyAmount> prices;
  final bool allowBackorder;

  const ProductVariant({
    required this.id,
    required this.title,
    this.inventoryQuantity,
    required this.prices,
    required this.allowBackorder,
  });

  MoneyAmount? get kesPrice => prices.firstWhere(
        (p) => p.currencyCode == 'kes',
        orElse: () => prices.isNotEmpty ? prices.first : MoneyAmount(amount: 0, currencyCode: 'kes'),
      );

  bool get inStock =>
      allowBackorder || (inventoryQuantity != null && inventoryQuantity! > 0);

  factory ProductVariant.fromJson(Map<String, dynamic> j) => ProductVariant(
        id: j['id'] as String,
        title: j['title'] as String,
        inventoryQuantity: j['inventory_quantity'] as int?,
        prices: (j['prices'] as List<dynamic>? ?? [])
            .map((p) => MoneyAmount.fromJson(p as Map<String, dynamic>))
            .toList(),
        allowBackorder: j['allow_backorder'] as bool? ?? false,
      );
}

class Product {
  final String id;
  final String title;
  final String handle;
  final String? description;
  final String? thumbnail;
  final List<ProductImage> images;
  final List<ProductVariant> variants;
  final List<ProductCategory> categories;
  final String status;

  const Product({
    required this.id,
    required this.title,
    required this.handle,
    this.description,
    this.thumbnail,
    required this.images,
    required this.variants,
    required this.categories,
    required this.status,
  });

  ProductVariant? get defaultVariant =>
      variants.isNotEmpty ? variants.first : null;

  MoneyAmount? get price => defaultVariant?.kesPrice;

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String,
        title: j['title'] as String,
        handle: j['handle'] as String,
        description: j['description'] as String?,
        thumbnail: j['thumbnail'] as String?,
        images: (j['images'] as List<dynamic>? ?? [])
            .map((i) => ProductImage.fromJson(i as Map<String, dynamic>))
            .toList(),
        variants: (j['variants'] as List<dynamic>? ?? [])
            .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
            .toList(),
        categories: (j['categories'] as List<dynamic>? ?? [])
            .map((c) => ProductCategory.fromJson(c as Map<String, dynamic>))
            .toList(),
        status: j['status'] as String? ?? 'published',
      );
}
