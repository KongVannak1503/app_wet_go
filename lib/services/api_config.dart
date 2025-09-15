class ApiConfig {
  // 192.168.18.46 at office
  static const String baseUrl = "http://192.168.211.165:5000";

  // Users
  static String get login => "$baseUrl/api/users/login";
  static String get register => "$baseUrl/api/users/register";
  static String get test => "$baseUrl/api/users/test";
  static String get users => "$baseUrl/api/users/";
  static String user(String id) => "$baseUrl/api/users/$id";

  // Store
  static String get stores => "$baseUrl/api/stores/";
  static String get storeState => "$baseUrl/api/stores/state";
  static String getStore(String id) => "$baseUrl/api/stores/$id";

  // Store
  static String get transactions => "$baseUrl/api/transactions/";
  static String get dashboardCard => "$baseUrl/api/transactions/dashboard/";
  static String getTransaction(String id) => "$baseUrl/api/transactions/$id";
  static String getTransactionActive(String id) =>
      "$baseUrl/api/transactions/active/$id";
  static String getTransactionPayment(String id) =>
      "$baseUrl/api/transactions/payment/$id";
}
