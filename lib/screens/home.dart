import 'package:flutter/material.dart';
import 'package:wet_go/providers/authenticator_provider.dart';
import 'package:wet_go/repositories/users_repository.dart';
import 'package:wet_go/screens/widgets/home/home_grid_card_item.dart';
import 'package:wet_go/screens/widgets/home/stats_home_card.dart';
import 'package:wet_go/screens/widgets/layouts/bottom_nav_bar.dart';
import 'package:wet_go/screens/widgets/text/text_light.dart';
import 'package:wet_go/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UsersRepository _usersRepo = UsersRepository();

  @override
  void initState() {
    super.initState();
  }

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
    final authProvider = Provider.of<AuthenticatorProvider>(context);
    final token = authProvider.token;
    final userId = authProvider.userId;

    Map<String, dynamic>? decoded;

    if (token != null) {
      decoded = JwtDecoder.decode(token);
    }
    final List<Map<String, dynamic>> gridItems = [
      {"icon": Icons.store, "title": loc?.stores, "route": "/stores"},
      {"icon": Icons.qr_code, "title": loc?.scanQr, "route": "/scan-qr"},
      {
        "icon": Icons.transform_outlined,
        "title": loc?.transaction,
        "route": "/transactions",
      },
      {"icon": Icons.people, "title": loc?.users, "route": "/users"},
      {"icon": Icons.settings, "title": loc?.settings, "route": "/settings"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: TextLight(text: loc?.home ?? 'Home'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            color: Theme.of(context).colorScheme.onPrimary,
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 140),

                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: gridItems.map((item) {
                            return SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 48) / 2,
                              child: HomeGridCardItem(
                                icon: item['icon'],
                                title: item['title'],
                                navigateTo: item['route'],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Token: ${userId ?? "No token"}',
                    style: const TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                ],
              ),
            ),
            const StatsHomeCard(),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}
