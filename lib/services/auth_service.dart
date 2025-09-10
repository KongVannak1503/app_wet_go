import 'package:wet_go/repositories/users_repository.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final UsersRepository _usersRepository;

  String? _token;
  Map<String, dynamic>? _decodedToken;

  AuthService(this._usersRepository);

  String? get token => _token;
  bool get isAuthenticated => _token != null;
  Map<String, dynamic>? get decodedToken => _decodedToken;
  String? get userId => _decodedToken?['id'];

  Future<bool> login(String email, String password) async {
    try {
      final response = await _usersRepository.login(email, password);

      if (response.containsKey('token')) {
        _token = response['token'];

        // Decode JWT for claims
        _decodedToken = JwtDecoder.decode(_token!);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _token = null;
    _decodedToken = null;
  }
}
