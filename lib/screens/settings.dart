import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wet_go/providers/authenticator_provider.dart';
import 'package:wet_go/screens/widgets/text/text_light.dart';
import 'package:wet_go/l10n/app_localizations.dart';
import 'package:wet_go/providers/application_provider.dart';
import 'package:wet_go/screens/widgets/user/card_logout.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _logout(BuildContext context) {
    final authenticator = Provider.of<AuthenticatorProvider>(
      context,
      listen: false,
    );
    authenticator.logout();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final appProvider = Provider.of<ApplicationProvider>(context);

    void quickSync() async {
      final appProvider = Provider.of<ApplicationProvider>(
        context,
        listen: false,
      );

      try {
        await appProvider.refreshData(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data synced successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to sync: $e')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: TextLight(text: loc?.settings ?? 'Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc?.language ?? 'Language',
                        style: const TextStyle(fontSize: 16),
                      ),
                      DropdownButton<String>(
                        value: appProvider.locale.languageCode,
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'km', child: Text('Khmer')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            appProvider.setLocale(Locale(value));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 5),
              CardLogout(
                text: 'Quick Sync',
                icon: Icons.sync,
                onTap: quickSync,
              ),

              SizedBox(height: 5),
              CardLogout(
                text: 'Logout',
                icon: Icons.logout,
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
