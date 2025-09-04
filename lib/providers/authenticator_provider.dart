import 'package:flutter/foundation.dart';
import 'package:wet_go/services/auth_service.dart';

class AuthenticatorProvider with ChangeNotifier {
  final AuthService _authService;

  AuthenticatorProvider(this._authService);

  bool get isAuthenticated => _authService.isAuthenticated;

  String? get token => _authService.token;
  String? get userId => _authService.userId; // ✅ expose userId
  Map<String, dynamic>? get decodedToken => _authService.decodedToken;

  Future<bool> login(String email, String password) async {
    final success = await _authService.login(email, password);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  void logout() {
    _authService.logout();
    notifyListeners();
  }
}
