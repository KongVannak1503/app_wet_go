import 'package:flutter/material.dart';
import 'package:wet_go/repositories/users_repository.dart';
import 'package:wet_go/screens/widgets/home/home_grid_card_item.dart';
import 'package:wet_go/screens/widgets/home/stats_home_card.dart';
import 'package:wet_go/screens/widgets/layouts/bottom_nav_bar.dart';
import 'package:wet_go/screens/widgets/text/text_light.dart';
import 'package:wet_go/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UsersRepository _usersRepo = UsersRepository();
  String _result = "Waiting for API call...";

  @override
  void initState() {
    super.initState();
    _callTestApi();
  }

  Future<void> _callTestApi() async {
    try {
      final data = await _usersRepo.test();
      setState(() {
        _result = "✅ API Response: ${data['message']}";
      });
    } catch (e) {
      setState(() {
        _result = "❌ API Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final List<Map<String, dynamic>> gridItems = [
      {"icon": Icons.people, "title": "Users", "route": "/users"},
      {"icon": Icons.settings, "title": "Settings", "route": "/settings"},
      {"icon": Icons.shopping_cart, "title": "Products", "route": "/products"},
      {"icon": Icons.analytics, "title": "Reports", "route": "/reports"},
    ];

    void _logout() {
      context.go('/auth');
    }

    return Scaffold(
      appBar: AppBar(
        title: TextLight(text: loc?.home ?? 'Home'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            color: Theme.of(context).colorScheme.onPrimary,
            onPressed: _logout,
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

                  Text(_result),
                ],
              ),
            ),

            // Absolute container at top
            const StatsHomeCard(),
          ],
        ),
      ),

      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}
