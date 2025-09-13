import 'package:flutter/material.dart';
import 'package:wet_go/providers/authenticator_provider.dart';
import 'package:wet_go/repositories/stores_repository.dart';
import 'package:wet_go/screens/widgets/text/head_line_1.dart';
import 'package:provider/provider.dart';
import 'package:wet_go/screens/widgets/layouts/confirm_delete_dialog.dart';
import 'package:wet_go/screens/widgets/store/qr_code_generation.dart';

class StoreCartListItem extends StatelessWidget {
  const StoreCartListItem({
    super.key,
    this.imagePath,
    required this.id,
    required this.stallId,
    required this.name,
    required this.group,
    required this.owner,
    required this.amount,
    required this.isActive,
    // required this.onDelete,
    required this.onTap,
  });

  final String id;
  final String stallId;
  final String name;
  final String owner;
  final String group;
  final double amount;
  final bool isActive;
  final String? imagePath;
  // final VoidCallback onDelete;
  final VoidCallback onTap;

  Future<void> _deleteUser(BuildContext context) async {
    final authProvider = Provider.of<AuthenticatorProvider>(
      context,
      listen: false,
    );
    final token = authProvider.token;
    final repo = StoresRepository(token: token);
    final response = await repo.deleteStore(id);

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Store deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user: ${response['error']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart, // swipe from right to left
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showConfirmDeleteDialog(context);
      },
      onDismissed: (_) {
        _deleteUser(context);
      },
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: (imagePath != null && imagePath!.isNotEmpty)
                        ? ClipOval(
                            child: Image.asset(
                              imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                  size: 24,
                                );
                              },
                            ),
                          )
                        : Image.asset('assets/images/wet_go_logo.png'),
                  ),
                  const SizedBox(width: 12),

                  // Text info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeadLine1(text: 'ID: $stallId, Name: $name'),
                        const SizedBox(height: 4),
                        Text('Owner: $owner, Group: $group'),
                        Row(
                          children: [
                            Text('Amount: $amount'),
                            const SizedBox(width: 7),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: Icon(
                      Icons.qr_code,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      QrCodeGeneration.show(context, id);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
