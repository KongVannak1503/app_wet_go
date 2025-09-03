class ApiConfig {
  static const String baseUrl = "http://192.168.18.46:5000";

  static String get login => "$baseUrl/api/users/login";
  static String get register => "$baseUrl/api/users/register";
  static String get test => "$baseUrl/api/users/test";
}
