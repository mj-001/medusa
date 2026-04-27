import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer.dart';
import 'app_providers.dart';

class AuthState {
  final Customer? customer;
  final bool isLoading;
  final String? error;

  const AuthState({this.customer, this.isLoading = false, this.error});

  bool get isLoggedIn => customer != null;

  AuthState copyWith({
    Customer? customer,
    bool? isLoading,
    String? error,
    bool clearCustomer = false,
  }) =>
      AuthState(
        customer: clearCustomer ? null : customer ?? this.customer,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _loadCurrentUser();
    return const AuthState();
  }

  Future<void> _loadCurrentUser() async {
    final token = await ref.read(medusaClientProvider).getToken();
    if (token == null) return;
    try {
      final customer = await ref.read(authApiProvider).getProfile();
      state = AuthState(customer: customer);
    } catch (_) {
      await ref.read(medusaClientProvider).clearToken();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authApiProvider).login(email: email, password: password);
      final customer = await ref.read(authApiProvider).getProfile();
      state = AuthState(customer: customer);
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: _friendly(e), clearCustomer: true);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authApiProvider).register(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
          );
      final customer = await ref.read(authApiProvider).getProfile();
      state = AuthState(customer: customer);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _friendly(e));
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authApiProvider).logout();
    state = const AuthState();
  }

  String _friendly(Object e) => e.toString().contains('401')
      ? 'Invalid email or password.'
      : 'Something went wrong. Please try again.';
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
