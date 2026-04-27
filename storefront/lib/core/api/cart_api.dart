import '../models/cart.dart';
import 'medusa_client.dart';

class CartApi {
  final MedusaClient _client;
  CartApi(this._client);

  Future<Cart> createCart({String regionId = ''}) async {
    final response = await _client.dio.post('/carts', data: {
      if (regionId.isNotEmpty) 'region_id': regionId,
    });
    final data = response.data as Map<String, dynamic>;
    final cart = Cart.fromJson(data['cart'] as Map<String, dynamic>);
    await _client.setCartId(cart.id);
    return cart;
  }

  Future<Cart> getCart(String cartId) async {
    final response = await _client.dio.get('/carts/$cartId');
    final data = response.data as Map<String, dynamic>;
    return Cart.fromJson(data['cart'] as Map<String, dynamic>);
  }

  Future<Cart> addLineItem(
      String cartId, String variantId, int quantity) async {
    final response = await _client.dio.post(
      '/carts/$cartId/line-items',
      data: {'variant_id': variantId, 'quantity': quantity},
    );
    final data = response.data as Map<String, dynamic>;
    return Cart.fromJson(data['cart'] as Map<String, dynamic>);
  }

  Future<Cart> updateLineItem(
      String cartId, String lineItemId, int quantity) async {
    final response = await _client.dio.put(
      '/carts/$cartId/line-items/$lineItemId',
      data: {'quantity': quantity},
    );
    final data = response.data as Map<String, dynamic>;
    return Cart.fromJson(data['cart'] as Map<String, dynamic>);
  }

  Future<Cart> removeLineItem(String cartId, String lineItemId) async {
    final response =
        await _client.dio.delete('/carts/$cartId/line-items/$lineItemId');
    final data = response.data as Map<String, dynamic>;
    return Cart.fromJson(data['cart'] as Map<String, dynamic>);
  }

  Future<Cart> updateCart(String cartId,
      {String? email, Map<String, dynamic>? shippingAddress}) async {
    final response = await _client.dio.post('/carts/$cartId', data: {
      if (email != null) 'email': email,
      if (shippingAddress != null) 'shipping_address': shippingAddress,
    });
    final data = response.data as Map<String, dynamic>;
    return Cart.fromJson(data['cart'] as Map<String, dynamic>);
  }

  Future<List<ShippingOption>> listShippingOptions(String cartId) async {
    final response =
        await _client.dio.get('/shipping-options', queryParameters: {'cart_id': cartId});
    final data = response.data as Map<String, dynamic>;
    return (data['shipping_options'] as List<dynamic>)
        .map((o) => ShippingOption.fromJson(o as Map<String, dynamic>))
        .toList();
  }

  Future<Cart> addShippingMethod(
      String cartId, String shippingOptionId) async {
    final response = await _client.dio.post(
      '/carts/$cartId/shipping-methods',
      data: {'option_id': shippingOptionId},
    );
    final data = response.data as Map<String, dynamic>;
    return Cart.fromJson(data['cart'] as Map<String, dynamic>);
  }

  Future<void> initiatePaymentSession(
      String cartId, String providerId) async {
    await _client.dio.post('/carts/$cartId/payment-sessions', data: {
      'provider_id': providerId,
    });
  }

  Future<Map<String, dynamic>> completeCart(String cartId) async {
    final response = await _client.dio.post('/carts/$cartId/complete');
    return response.data as Map<String, dynamic>;
  }
}
