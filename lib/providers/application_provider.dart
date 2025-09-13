import 'package:flutter/material.dart';
import '../repositories/stores_repository.dart';
import 'package:provider/provider.dart';
import 'authenticator_provider.dart';

class ApplicationProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }

  // Example Quick Sync method
  // Store data
  List<Map<String, dynamic>> stores = [];
  int totalStore = 0;
  int totalActive = 0;
  int totalInactive = 0;
  bool isLoading = false;
  String? errorMessage;

  // Quick Sync method
  Future<void> refreshData(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthenticatorProvider>(
        context,
        listen: false,
      );
      final token = authProvider.token;

      if (token == null) {
        throw Exception('Unauthorized');
      }

      final storeRepo = StoresRepository(token: token);

      // Fetch stores list
      final response = await storeRepo.getStore();
      if (response.containsKey('error')) {
        throw Exception(response['error']);
      }

      // Fetch store state
      final resState = await storeRepo.getStoreStateApi();
      if (resState.containsKey('error')) {
        throw Exception(resState['error']);
      }

      // Save data to provider
      stores = response['data'] ?? [];
      totalStore = resState['data']['totalStore'] ?? 0;
      totalActive = resState['data']['totalStoreActive'] ?? 0;
      totalInactive = resState['data']['totalStoreInactive'] ?? 0;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
