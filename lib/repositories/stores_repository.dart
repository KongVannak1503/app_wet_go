import 'package:dio/dio.dart';
import 'package:wet_go/services/api_config.dart';

class StoresRepository {
  final Dio _dio;
  final String? token; // Token is required

  StoresRepository({Dio? dio, this.token}) : _dio = dio ?? Dio();

  /// Add Authorization header to requests
  Options _authOptions([Options? options]) {
    final headers = {'Authorization': 'Bearer $token'};

    return options?.copyWith(headers: headers) ?? Options(headers: headers);
  }

  /// Fetch all stores
  // Future<Map<String, dynamic>> getStore() async {
  //   try {
  //     final response = await _dio.get(
  //       ApiConfig.stores,
  //       options: _authOptions(),
  //     );

  //     return response.data;
  //   } on DioException catch (e) {
  //     if (e.response?.statusCode == 401) {
  //       return {"error": "Unauthorized. Please login again."};
  //     }
  //     return {"error": e.message};
  //   }
  // }

  Future<Map<String, dynamic>> getStore({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiConfig.stores,
        queryParameters: {'page': page, 'limit': limit},
        options: _authOptions(),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return {"error": "Unauthorized. Please login again."};
      }
      return {"error": e.message};
    }
  }

  Future<Map<String, dynamic>> getStoreStateApi() async {
    try {
      final response = await _dio.get(
        ApiConfig.storeState,
        options: _authOptions(),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return {"error": "Unauthorized. Please login again."};
      }
      return {"error": e.message};
    }
  }

  /// Create a new store
  Future<Map<String, dynamic>> createStoreApi(
    String stallId,
    String name,
    String owner,
    String group,
    double amount,
    bool status,
  ) async {
    try {
      final response = await _dio.post(
        ApiConfig.stores,
        data: {
          "stallId": stallId,
          "name": name,
          "owner": owner,
          "group": group,
          "amount": amount,
          "isActive": status,
        },
        options: _authOptions(),
      );
      if (response.statusCode == 201) return response.data;

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

  /// Update (edit) a store
  Future<Map<String, dynamic>> updateStoreApi(
    String id,
    String stallId,
    String name,
    String owner,
    String group,
    double amount,
    bool status,
  ) async {
    try {
      final response = await _dio.put(
        ApiConfig.getStore(id),
        data: {
          "stallId": stallId,
          "name": name,
          "owner": owner,
          "group": group,
          "amount": amount,
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

  Future<Map<String, dynamic>> deleteStore(String id) async {
    try {
      final response = await _dio.delete(
        ApiConfig.getStore(id),
        options: _authOptions(),
      );
      return response.data;
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}
