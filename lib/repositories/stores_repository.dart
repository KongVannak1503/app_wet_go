import 'package:dio/dio.dart';
import 'package:wet_go/services/api_config.dart';

class StoresRepository {
  final Dio _dio;

  StoresRepository([Dio? dio]) : _dio = dio ?? Dio();

  Future<Map<String, dynamic>> getStore() async {
    try {
      final response = await _dio.get(ApiConfig.stores);
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
