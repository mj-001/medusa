import '../models/product.dart';
import 'medusa_client.dart';

class ProductsApi {
  final MedusaClient _client;
  ProductsApi(this._client);

  Future<List<Product>> listProducts({
    String? categoryId,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      'fields': '*variants.prices,+variants.inventory_quantity',
    };
    if (categoryId != null) params['category_id[]'] = categoryId;
    if (search != null && search.isNotEmpty) params['q'] = search;

    final response = await _client.dio.get('/products', queryParameters: params);
    final data = response.data as Map<String, dynamic>;
    final products = (data['products'] as List<dynamic>)
        .map((p) => Product.fromJson(p as Map<String, dynamic>))
        .toList();
    return products;
  }

  Future<Product> getProduct(String id) async {
    final response = await _client.dio.get(
      '/products/$id',
      queryParameters: {'fields': '*variants.prices,+variants.inventory_quantity'},
    );
    final data = response.data as Map<String, dynamic>;
    return Product.fromJson(data['product'] as Map<String, dynamic>);
  }

  Future<List<ProductCategory>> listCategories() async {
    final response = await _client.dio.get('/product-categories');
    final data = response.data as Map<String, dynamic>;
    return (data['product_categories'] as List<dynamic>)
        .map((c) => ProductCategory.fromJson(c as Map<String, dynamic>))
        .toList();
  }
}
