import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wet_go/screens/widgets/layouts/bottom_nav_bar.dart';
import 'package:wet_go/screens/widgets/text/text_light.dart';
import 'package:wet_go/l10n/app_localizations.dart';
import 'package:wet_go/providers/application_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final appProvider = Provider.of<ApplicationProvider>(context);

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
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}
