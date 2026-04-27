import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/auth_api.dart';
import '../api/cart_api.dart';
import '../api/medusa_client.dart';
import '../api/orders_api.dart';
import '../api/products_api.dart';

final medusaClientProvider = Provider<MedusaClient>((ref) => MedusaClient());

final productsApiProvider =
    Provider<ProductsApi>((ref) => ProductsApi(ref.watch(medusaClientProvider)));

final cartApiProvider =
    Provider<CartApi>((ref) => CartApi(ref.watch(medusaClientProvider)));

final authApiProvider =
    Provider<AuthApi>((ref) => AuthApi(ref.watch(medusaClientProvider)));

final ordersApiProvider =
    Provider<OrdersApi>((ref) => OrdersApi(ref.watch(medusaClientProvider)));
