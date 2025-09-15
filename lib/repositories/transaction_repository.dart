import 'package:dio/dio.dart';
import 'package:wet_go/services/api_config.dart';

class TransactionRepository {
  final Dio _dio;
  final String? token;

  TransactionRepository({Dio? dio, this.token}) : _dio = dio ?? Dio();

  Options _authOptions([Options? options]) {
    return options?.copyWith(headers: {'Authorization': 'Bearer $token'}) ??
        Options(headers: {'Authorization': 'Bearer $token'});
  }

  // Future<List<dynamic>> getTransactions() async {
  //   try {
  //     final response = await _dio.get(
  //       ApiConfig.transactions,
  //       options: _authOptions(),
  //     );

  //     final List<dynamic> data = response.data['data'] ?? [];

  //     return data;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<List<dynamic>> getTransactions({
    bool todayOnly = false,
    int? page,
    int? limit,
    String? name,
    String? date,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (todayOnly) {
        final todayDate = DateTime.now().toIso8601String().split('T')[0];
        queryParams['date'] = todayDate;
      }

      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (date != null && date.isNotEmpty) queryParams['date'] = date;

      final response = await _dio.get(
        ApiConfig.transactions,
        options: _authOptions(),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return response.data['data'] ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTransactionApi(String id) async {
    try {
      final response = await _dio.get(
        ApiConfig.getStore(id),
        options: _authOptions(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createTodayTransactions() async {
    final response = await _dio.post(
      ApiConfig.transactions,
      options: _authOptions(),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getActivePaid(id) async {
    try {
      final response = await _dio.get(
        ApiConfig.getTransactionActive(id),
        options: _authOptions(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPayment(id) async {
    try {
      final response = await _dio.post(
        ApiConfig.getTransactionPayment(id),
        options: _authOptions(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> markPaid(
    String stallId, {
    double? amount,
  }) async {
    final response = await _dio.post(
      '${ApiConfig.transactions}/mark-paid',
      options: _authOptions(),
      data: {'stallId': stallId, 'amount': amount},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getDashboardApi() async {
    try {
      final response = await _dio.get(
        ApiConfig.dashboardCard,
        options: _authOptions(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
