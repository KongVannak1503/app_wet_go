import 'package:dio/dio.dart';
import 'package:wet_go/services/api_config.dart';

class UsersRepository {
  final Dio _dio;

  UsersRepository([Dio? dio]) : _dio = dio ?? Dio();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {"email": email, "password": password},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String phone,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        ApiConfig.register,
        data: {"email": email, "phone": phone, "password": password},
        options: Options(
          validateStatus: (status) => true, // Accept all status codes
        ),
      );

      if (response.statusCode == 201) {
        // Success
        return response.data;
      } else if (response.statusCode == 400) {
        // Email/phone already exists
        return {"error": response.data['message'] ?? 'Registration failed'};
      } else {
        return {"error": 'Unexpected error: ${response.statusCode}'};
      }
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  Future<Map<String, dynamic>> test() async {
    try {
      final response = await _dio.get(ApiConfig.test);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> users() async {
    try {
      final response = await _dio.get(ApiConfig.users);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> user(String id) async {
    try {
      final response = await _dio.get(ApiConfig.user(id));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteUser(String id) async {
    try {
      final response = await _dio.delete(ApiConfig.user(id));
      return response.data;
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}
