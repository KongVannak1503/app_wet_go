import 'package:flutter/material.dart';
import 'package:wet_go/providers/authenticator_provider.dart';
import 'package:provider/provider.dart';
import 'package:wet_go/repositories/transaction_repository.dart';
import 'package:wet_go/screens/widgets/text/head_line_1.dart';

class UnpaidTransactionDialog extends StatefulWidget {
  final String id;
  const UnpaidTransactionDialog({super.key, required this.id});

  @override
  State<UnpaidTransactionDialog> createState() =>
      _UnpaidTransactionDialogState();
}

class _UnpaidTransactionDialogState extends State<UnpaidTransactionDialog> {
  var _isLoading = false;
  String _name = '';
  String _owner = '';
  bool _notFound = false;
  bool _isPiad = false;

  List<dynamic> _transactionsActive = [];

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
    setState(() => _isLoading = true);

    final storeRepo = TransactionRepository(token: token);
    try {
      final response = await storeRepo.getTransactionApi(widget.id);
      final store = response['data'];
      final resActive = await storeRepo.getActivePaid(widget.id);
      final transactionsActive = resActive['data'];

      if (store == null) {
        setState(() {
          _notFound = true;
          _isLoading = false;
        });
        return;
      }

      if (transactionsActive == null) {
        setState(() {
          _isPiad = true;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _name = store['name'] ?? '';
        _owner = store['owner'];
        _transactionsActive = transactionsActive;
        _isLoading = false;
        _notFound = true;
        _isPiad = true;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _transactionsActive.fold<num>(
      0,
      (sum, item) => sum + (item['storeId']?['amount'] ?? 0),
    );

    void _markPaid() async {
      if (!mounted) return; // ensure widget is still mounted

      setState(() => _isLoading = true); // show loading

      final authProvider = Provider.of<AuthenticatorProvider>(
        context,
        listen: false,
      );
      final token = authProvider.token;
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final repo = TransactionRepository(token: token);

      try {
        // Call your API to mark transactions as paid
        final res = await repo.getPayment(widget.id);

        if (!mounted) return;

        setState(() => _isLoading = false);

        // Close current dialog
        Navigator.of(context).pop();

        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;

          showDialog(
            context: context,
            useRootNavigator: true, // ensures it's shown on root navigator
            builder: (ctx) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min, // avoid full-height
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(height: 20),
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 70, // big icon
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Payment Successfully",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        });

        // Refresh transactions list to reflect changes
        await _fetchUser();
      } catch (e) {
        if (!mounted) return;

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to mark paid: $e')));
      }
    }

    return AlertDialog(
      title: const Text("Store Info"),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : !_notFound
            ? const Text("Not found")
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeadLine1(text: "Name: $_name"),
                  Text("Owner: $_owner"),
                  const SizedBox(height: 10),
                  _transactionsActive.isEmpty
                      ? const Text("All transactions are already paid ✅")
                      : Column(
                          children: [
                            // Header row
                            Row(
                              children: const [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Date",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Amount",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            ..._transactionsActive.map((item) {
                              return Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(item['date'] ?? ''),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "${item['storeId']?['amount'] ?? 0}",
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                            const Divider(thickness: 2),
                            Row(
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Total',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "$totalAmount",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ],
              ),
      ),
      actions: [
        if (_isPiad && _transactionsActive.isNotEmpty)
          TextButton(
            onPressed: _markPaid,
            child: Text(
              "Mark Paid",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
