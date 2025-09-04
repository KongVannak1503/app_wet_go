import 'package:dio/dio.dart';
import 'package:wet_go/services/auth_service.dart';

/// A custom Dio Interceptor to automatically add the Authorization header
/// to every outgoing API request if a token exists.
class AuthInterceptor extends Interceptor {
  final AuthService _authService;

  AuthInterceptor(this._authService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _authService.token;
    if (token != null) {
      // Add the Authorization header with the Bearer token
      options.headers['Authorization'] = 'Bearer $token';
    }
    // Continue with the request
    super.onRequest(options, handler);
  }
}
