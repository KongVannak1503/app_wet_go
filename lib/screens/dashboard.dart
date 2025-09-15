import 'package:flutter/material.dart';
import 'package:wet_go/l10n/app_localizations.dart';
import 'package:wet_go/providers/authenticator_provider.dart';
import 'package:wet_go/repositories/transaction_repository.dart';
import 'package:wet_go/screens/widgets/home/home_grid_card_item_no_url.dart';
import 'package:wet_go/screens/widgets/home/transaction_label_card.dart';
import 'package:wet_go/screens/widgets/text/text_light.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _dashboardData = [];
  bool _isLoading = true;
  String? _errorMessage;

  int _totalUsers = 0;
  int _totalStores = 0;
  double _totalFinalAmount = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthenticatorProvider>(
      context,
      listen: false,
    );
    final token = authProvider.token;

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No token found';
      });
      return;
    }

    final tranRepo = TransactionRepository(token: token);

    try {
      final response = await tranRepo.getDashboardApi();

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        setState(() {
          _dashboardData = data['transactions'] ?? [];
          _totalUsers = data['userCount'] ?? 0;
          _totalStores = data['storeCount'] ?? 0;
          _totalFinalAmount = (data['totalFinalAmount'] ?? 0).toDouble();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response['error'] ?? 'Failed to fetch dashboard data';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextLight(text: loc?.dashboard ?? 'Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 48) / 2,
                    child: HomeGridCardItemNoUrl(
                      icon: Icons.people,
                      title: "${loc?.users}",
                      total: _totalUsers.toString(),
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 48) / 2,
                    child: HomeGridCardItemNoUrl(
                      icon: Icons.store,
                      title: "${loc?.stores}",
                      total: _totalStores.toString(),
                    ),
                  ),
                ],
              ),

              Column(
                children: const [
                  TransactionTableCard(), // your new component
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
