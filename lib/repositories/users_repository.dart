import 'package:dio/dio.dart';
import 'package:wet_go/services/api_config.dart';

class UsersRepository {
  final Dio _dio;
  final String? token;

  UsersRepository({Dio? dio, this.token}) : _dio = dio ?? Dio();

  Options _authOptions([Options? options]) {
    final headers = {
      'Authorization': 'Bearer $token', // Always prefix with 'Bearer '
    };

    return options?.copyWith(headers: headers) ?? Options(headers: headers);
  }

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
      final response = await _dio.get(ApiConfig.users, options: _authOptions());
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> user(String id) async {
    try {
      final response = await _dio.get(
        ApiConfig.user(id),
        options: _authOptions(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> editUserApi(
    String dataId,
    String email,
    String phone,
    String? password,
    String role,
    bool status,
  ) async {
    try {
      final response = await _dio.put(
        ApiConfig.user(dataId),
        data: {
          "email": email,
          "phone": phone,
          "password": password,
          "role": role,
          "isActive": status,
        },
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        return response.data; // success
      }

      final errorMsg =
          response.data['error'] ??
          response.data['message'] ??
          'Unexpected error';
      return {"error": errorMsg};
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return {"error": "Unauthorized. Please login again."};
      }
      return {"error": e.message};
    }
  }

  Future<Map<String, dynamic>> deleteUser(String id) async {
    try {
      final response = await _dio.delete(
        ApiConfig.user(id),
        options: _authOptions(),
      );
      return response.data;
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}
