class ApiConfig {
  static const String baseUrl = "http://192.168.18.46:5000";

  // Users
  static String get login => "$baseUrl/api/users/login";
  static String get register => "$baseUrl/api/users/register";
  static String get test => "$baseUrl/api/users/test";
  static String get users => "$baseUrl/api/users/";
  static String user(String id) => "$baseUrl/api/users/$id";

  // Store
  static String get stores => "$baseUrl/api/stores/";
}
