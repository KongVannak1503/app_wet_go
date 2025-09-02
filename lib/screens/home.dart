import 'package:flutter/material.dart';
import 'package:wet_go/screens/widgets/home/stats_home_card.dart';
import 'package:wet_go/screens/widgets/layouts/bottom_nav_bar.dart';
import 'package:wet_go/screens/widgets/text/text_light.dart';
import 'package:wet_go/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextLight(text: loc?.home ?? 'Home'),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
                  SizedBox(height: 140),
                  Text('Your page content here'),
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
