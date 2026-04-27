import '../models/customer.dart';
import 'medusa_client.dart';

class AuthApi {
  final MedusaClient _client;
  AuthApi(this._client);

  Future<String> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    // Medusa v2: POST /auth/customer/emailpass returns a JWT token
    final response = await _client.dio.post(
      '/auth/customer/emailpass',
      data: {
        'email': email,
        'password': password,
      },
    );
    final token = response.data['token'] as String;
    await _client.setToken(token);

    // Create the customer record
    await _client.dio.post('/customers', data: {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      if (phone != null) 'phone': phone,
    });

    return token;
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post(
      '/auth/customer/emailpass',
      data: {'email': email, 'password': password},
    );
    final token = response.data['token'] as String;
    await _client.setToken(token);
    return token;
  }

  Future<void> logout() async {
    await _client.clearToken();
    await _client.clearCartId();
  }

  Future<Customer> getProfile() async {
    final response = await _client.dio.get('/customers/me');
    final data = response.data as Map<String, dynamic>;
    return Customer.fromJson(data['customer'] as Map<String, dynamic>);
  }

  Future<Customer> updateProfile(Map<String, dynamic> updates) async {
    final response = await _client.dio.post('/customers/me', data: updates);
    final data = response.data as Map<String, dynamic>;
    return Customer.fromJson(data['customer'] as Map<String, dynamic>);
  }
}
