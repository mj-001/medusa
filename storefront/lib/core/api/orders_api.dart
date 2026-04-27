import '../models/order.dart';
import 'medusa_client.dart';

class OrdersApi {
  final MedusaClient _client;
  OrdersApi(this._client);

  Future<List<Order>> listOrders({int limit = 20, int offset = 0}) async {
    final response = await _client.dio.get('/orders', queryParameters: {
      'limit': limit,
      'offset': offset,
    });
    final data = response.data as Map<String, dynamic>;
    return (data['orders'] as List<dynamic>)
        .map((o) => Order.fromJson(o as Map<String, dynamic>))
        .toList();
  }

  Future<Order> getOrder(String id) async {
    final response = await _client.dio.get('/orders/$id');
    final data = response.data as Map<String, dynamic>;
    return Order.fromJson(data['order'] as Map<String, dynamic>);
  }

  Future<Order?> getOrderByDisplayId(String displayId) async {
    final response = await _client.dio.get('/orders', queryParameters: {
      'display_id': displayId,
    });
    final data = response.data as Map<String, dynamic>;
    final orders = data['orders'] as List<dynamic>;
    if (orders.isEmpty) return null;
    return Order.fromJson(orders.first as Map<String, dynamic>);
  }
}
