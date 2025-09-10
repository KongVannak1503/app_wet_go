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
  Future<void> refreshData(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthenticatorProvider>(
        context,
        listen: false,
      );
      final token = authProvider.token;

      if (token != null) {
        final storeRepo = StoresRepository(token: token);
        final response = await storeRepo.getStore();

        if (response.containsKey('error')) {
          throw Exception(response['error']);
        }
      }

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to sync data: $e');
    }
  }
}
