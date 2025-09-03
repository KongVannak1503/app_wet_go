import 'package:flutter/material.dart';
import 'package:wet_go/services/api_service.dart';

class AuthenticatorProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService(); // Use your Dio service
  bool isLoading = false;
  String? token;

  // REGISTER USER
  Future<Map<String, dynamic>> register(
    String email,
    String phone,
    String password,
  ) async {
    isLoading = true;
    notifyListeners();

    final result = await _apiService.register(
      email: email,
      phone: phone,
      password: password,
    );

    isLoading = false;
    notifyListeners();
    return result;
  }

  // LOGIN USER
  Future<Map<String, dynamic>> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    final result = await _apiService.login(email: email, password: password);

    if (result['token'] != null) {
      token = result['token']; // Save token if needed
    }

    isLoading = false;
    notifyListeners();
    return result;
  }
}
