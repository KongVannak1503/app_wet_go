import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wet_go/l10n/app_localizations.dart';
import 'package:wet_go/providers/authenticator_provider.dart';
import 'package:wet_go/repositories/users_repository.dart';
import 'package:wet_go/screens/widgets/layouts/bottom_nav_bar.dart';
import 'package:wet_go/screens/widgets/text/text_light.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wet_go/screens/widgets/user/card_logout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final authProvider = Provider.of<AuthenticatorProvider>(
      context,
      listen: false,
    );
    final token = authProvider.token;

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    final usersRepo = UsersRepository(token: token);

    final userId = authProvider.userId;
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await usersRepo.user(userId);
      setState(() {
        _user = response['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changePassword() async {
    context.push('/change-password');
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'N/A';
    final dateTime = DateTime.parse(isoDate);
    return DateFormat('MMMM, yyyy').format(dateTime);
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
    final foc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextLight(text: foc?.profile ?? 'Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text('Kong Vannak'),
                          Text(
                            '${foc?.customerSince} ${_formatDate(_user?['createdAt'])}',
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.phone),
                              SizedBox(width: 10),
                              Text(_user?['phone'] ?? 'N/A'),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.email),
                              SizedBox(width: 10),
                              Text(_user?['email'] ?? 'N/A'),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Image.asset('assets/images/wet_go_logo.png'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 5),
              CardLogout(
                text: '${foc?.changePassword}',
                icon: Icons.lock,
                onTap: _changePassword,
              ),
              SizedBox(height: 5),
              CardLogout(
                text: '${foc?.logout}',
                icon: Icons.logout,
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }
}
