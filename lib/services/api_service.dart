import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:5000/api', // for Android emulator
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// REGISTER USER
  Future<Map<String, dynamic>> register({
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/users/register',
        data: {"email": email, "phone": phone, "password": password},
      );
      return response.data;
    } on DioError catch (e) {
      return {"error": e.response?.data ?? e.message};
    }
  }

  /// LOGIN USER
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/users/login',
        data: {"email": email, "password": password},
      );
      return response.data;
    } on DioError catch (e) {
      return {"error": e.response?.data ?? e.message};
    }
  }

  /// SIMPLE TEST CALL
  Future<void> testLogin() async {
    try {
      final response = await _dio.post(
        '/users/login',
        data: {"email": "test@test.com", "password": "123456"},
      );
      print("✅ Response: ${response.data}");
    } catch (e) {
      print("❌ Error: $e");
    }
  }
}
