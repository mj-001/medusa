import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart.dart';
import 'app_providers.dart';

class CartNotifier extends AsyncNotifier<Cart?> {
  @override
  Future<Cart?> build() async {
    final cartId = await ref.read(medusaClientProvider).getCartId();
    if (cartId == null) return null;
    try {
      return await ref.read(cartApiProvider).getCart(cartId);
    } catch (_) {
      return null;
    }
  }

  Future<Cart> _ensureCart() async {
    final current = state.valueOrNull;
    if (current != null) return current;
    final cart = await ref.read(cartApiProvider).createCart();
    state = AsyncData(cart);
    return cart;
  }

  Future<void> addItem(String variantId, {int quantity = 1}) async {
    final cart = await _ensureCart();
    state = const AsyncLoading();
    try {
      final updated =
          await ref.read(cartApiProvider).addLineItem(cart.id, variantId, quantity);
      state = AsyncData(updated);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateItem(String lineItemId, int quantity) async {
    final cart = state.valueOrNull;
    if (cart == null) return;
    state = const AsyncLoading();
    try {
      final updated = await ref
          .read(cartApiProvider)
          .updateLineItem(cart.id, lineItemId, quantity);
      state = AsyncData(updated);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> removeItem(String lineItemId) async {
    final cart = state.valueOrNull;
    if (cart == null) return;
    state = const AsyncLoading();
    try {
      final updated = await ref
          .read(cartApiProvider)
          .removeLineItem(cart.id, lineItemId);
      state = AsyncData(updated);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> setEmail(String email) async {
    final cart = state.valueOrNull;
    if (cart == null) return;
    final updated =
        await ref.read(cartApiProvider).updateCart(cart.id, email: email);
    state = AsyncData(updated);
  }

  Future<void> setShippingAddress(ShippingAddress address) async {
    final cart = state.valueOrNull;
    if (cart == null) return;
    final updated = await ref.read(cartApiProvider).updateCart(cart.id,
        shippingAddress: address.toJson());
    state = AsyncData(updated);
  }

  Future<List<ShippingOption>> getShippingOptions() async {
    final cart = await _ensureCart();
    return ref.read(cartApiProvider).listShippingOptions(cart.id);
  }

  Future<void> selectShippingMethod(String optionId) async {
    final cart = await _ensureCart();
    final updated =
        await ref.read(cartApiProvider).addShippingMethod(cart.id, optionId);
    state = AsyncData(updated);
  }

  Future<Map<String, dynamic>?> completeOrder() async {
    final cart = state.valueOrNull;
    if (cart == null) return null;

    // Initiate M-Pesa payment session
    await ref
        .read(cartApiProvider)
        .initiatePaymentSession(cart.id, 'pp_mpesa_mpesa');

    final result = await ref.read(cartApiProvider).completeCart(cart.id);

    // Clear cart on success
    await ref.read(medusaClientProvider).clearCartId();
    state = const AsyncData(null);
    return result;
  }

  void reset() {
    state = const AsyncData(null);
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, Cart?>(CartNotifier.new);

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).valueOrNull?.itemCount ?? 0;
});
