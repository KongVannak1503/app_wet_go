import 'package:flutter/material.dart';
import 'package:wet_go/l10n/app_localizations.dart';
import 'package:wet_go/providers/authenticator_provider.dart';
import 'package:wet_go/screens/widgets/text/text_light.dart';
import 'package:wet_go/repositories/users_repository.dart';
import 'package:wet_go/screens/widgets/user/user_card_list_item.dart';
import 'package:provider/provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
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

    try {
      final response = await usersRepo.users();
      setState(() {
        _users = response['data'];
        _filteredUsers = _users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    final filtered = _users.where((user) {
      final email = user['email'].toString().toLowerCase();
      final phone = user['phone'].toString().toLowerCase();
      final q = query.toLowerCase();
      return email.contains(q) || phone.contains(q);
    }).toList();

    setState(() {
      _filteredUsers = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextLight(text: loc?.users ?? 'Users'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                    ),
                    onChanged: _filterUsers, // 👈 call filter on each change
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return UserCardListItem(
                          email: user['email'],
                          phone: user['phone'],
                          id: user['_id'],
                          onDelete: () {
                            setState(() {
                              _users.removeWhere(
                                (u) => u['_id'] == user['_id'],
                              );
                              _filteredUsers.removeAt(index);
                            });
                          },
                          onEdit: _fetchUsers,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
