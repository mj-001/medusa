import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _tokenKey = 'medusa_auth_token';
const _cartIdKey = 'medusa_cart_id';

class MedusaClient {
  static const String baseUrl =
      String.fromEnvironment('MEDUSA_URL', defaultValue: 'http://localhost:9000');

  static const String publishableKey = String.fromEnvironment(
    'MEDUSA_PUBLISHABLE_KEY',
    defaultValue: 'pk_01PLACEHOLDER',
  );

  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  MedusaClient() {
    dio = Dio(BaseOptions(
      baseUrl: '$baseUrl/store',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'x-publishable-api-key': publishableKey,
      },
    ));

    dio.interceptors.addAll([
      _AuthInterceptor(_storage),
      _LogInterceptor(),
    ]);
  }

  Future<String?> getToken() => _storage.read(key: _tokenKey);
  Future<void> setToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<String?> getCartId() => _storage.read(key: _cartIdKey);
  Future<void> setCartId(String id) => _storage.write(key: _cartIdKey, value: id);
  Future<void> clearCartId() => _storage.delete(key: _cartIdKey);
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  _AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _LogInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('[Medusa] ${err.requestOptions.method} ${err.requestOptions.path} → ${err.response?.statusCode}');
    handler.next(err);
  }
}
