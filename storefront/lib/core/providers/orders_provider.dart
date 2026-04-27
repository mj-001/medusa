import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import 'app_providers.dart';

final ordersProvider = FutureProvider<List<Order>>((ref) async {
  return ref.watch(ordersApiProvider).listOrders();
});

final orderDetailProvider =
    FutureProvider.family<Order, String>((ref, id) async {
  return ref.watch(ordersApiProvider).getOrder(id);
});
