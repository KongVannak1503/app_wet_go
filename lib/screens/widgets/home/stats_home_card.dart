import 'package:flutter/material.dart';
import 'package:wet_go/l10n/app_localizations.dart';
import 'package:wet_go/providers/authenticator_provider.dart';
import 'package:wet_go/repositories/stores_repository.dart';
import 'package:wet_go/screens/widgets/chart/partial_circular_progress_custom.dart';
import 'package:provider/provider.dart';

class StatsHomeCard extends StatefulWidget {
  const StatsHomeCard({super.key});

  @override
  State<StatsHomeCard> createState() => _StatsHomeCardState();
}

class _StatsHomeCardState extends State<StatsHomeCard> {
  int totalActive = 0;
  int totalStore = 0;
  int totalInactive = 0;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStoreState();
  }

  Future<void> _fetchStoreState() async {
    final authProvider = Provider.of<AuthenticatorProvider>(
      context,
      listen: false,
    );
    final token = authProvider.token;

    final storeRepo = StoresRepository(token: token);

    try {
      final data = await storeRepo.getStoreStateApi();
      if (data['error'] != null) {
        setState(() {
          errorMessage = data['error'];
          isLoading = false;
        });
      } else {
        final storeData = data['data'] ?? {};
        setState(() {
          totalStore = storeData['totalStore'] ?? 0;
          totalActive = storeData['totalStoreActive'] ?? 0;
          totalInactive = storeData['totalStoreInactive'] ?? 0;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load data";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Card(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      height: 180,
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          PartialCircularProgressCustom(
                            progress: totalActive / totalStore, // fraction
                            text: '$totalActive / $totalStore',
                            size: 150,
                            progressColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                          SizedBox(width: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(loc?.totalActive ?? "Total Active"),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(loc?.totalInactive ?? "Total Inactive"),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
