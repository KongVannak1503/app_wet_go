import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wet_go/providers/authenticator_provider.dart';
import 'package:wet_go/repositories/transaction_repository.dart';
import 'package:wet_go/screens/widgets/text/text_light.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<dynamic> todayTransactions = [];
  List<dynamic> allTransactions = [];
  bool _loading = false;
  bool _loadingMore = false;
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasMore = true;

  TransactionRepository? _transactionRepo;

  // Filters
  TextEditingController _nameController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTodayTransactions();
    _fetchAllTransactions(reset: true);
  }

  Future<void> _fetchTodayTransactions() async {
    setState(() => _loading = true);

    final authProvider = Provider.of<AuthenticatorProvider>(
      context,
      listen: false,
    );
    final token = authProvider.token;
    if (token == null) {
      setState(() => _loading = false);
      return;
    }

    _transactionRepo ??= TransactionRepository(token: token);

    try {
      final data = await _transactionRepo!.getTransactions(todayOnly: true);
      setState(() {
        todayTransactions = List.from(data);
      });
    } catch (e) {
      _showError('Error fetching today’s transactions: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchAllTransactions({bool reset = false}) async {
    if (_loadingMore || (!_hasMore && !reset)) return;

    if (reset) {
      setState(() {
        _currentPage = 1;
        allTransactions.clear();
        _hasMore = true;
      });
    }

    setState(() => _loadingMore = true);

    final authProvider = Provider.of<AuthenticatorProvider>(
      context,
      listen: false,
    );
    final token = authProvider.token;
    if (token == null) {
      setState(() => _loadingMore = false);
      return;
    }

    _transactionRepo ??= TransactionRepository(token: token);

    try {
      final data = await _transactionRepo!.getTransactions(
        page: _currentPage,
        limit: _limit,
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
        date: _dateController.text.isNotEmpty ? _dateController.text : null,
      );

      setState(() {
        allTransactions.addAll(data);
        _hasMore = data.length == _limit;
        _currentPage++;
      });
    } catch (e) {
      _showError('Error fetching all transactions: $e');
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  Future<void> _createTodayTransactions() async {
    setState(() => _loading = true);

    final authProvider = Provider.of<AuthenticatorProvider>(
      context,
      listen: false,
    );
    final token = authProvider.token;
    if (token == null) {
      setState(() => _loading = false);
      return;
    }

    _transactionRepo ??= TransactionRepository(token: token);

    try {
      final response = await _transactionRepo!.createTodayTransactions();
      final createdCount = response['created'] ?? 0;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$createdCount transactions created!')),
      );

      await _fetchTodayTransactions();
      await _fetchAllTransactions(reset: true);
    } catch (e) {
      _showError('Error creating transactions: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildTransactionList(
    List<dynamic> transactions, {
    bool isAllTab = false,
  }) {
    if (_loading && !isAllTab) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions found.'));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (isAllTab &&
            !_loadingMore &&
            _hasMore &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _fetchAllTransactions();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: transactions.length + (isAllTab && _hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (isAllTab && index == transactions.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final tx = transactions[index];
          final store = tx['storeId'] ?? {};
          final name = store['name'] ?? 'Unknown Store';
          final amount = tx['finalAmount'] ?? store['amount'] ?? 0;
          final status = tx['status'] ?? 'Unknown';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(name),
              subtitle: Text('Amount: $amount | Status: $status'),
              trailing: status == 'Paid'
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.pending, color: Colors.orange),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Filter by store name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Filter by date',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2023),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  _dateController.text = picked.toIso8601String().split('T')[0];
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _fetchAllTransactions(reset: true),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _nameController.clear();
              _dateController.clear();
              _fetchAllTransactions(reset: true);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const TextLight(text: "Transactions"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Create Today’s Transactions',
              onPressed: _loading ? null : _createTodayTransactions,
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: Colors.grey[200],
              child: const TabBar(
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(text: "Today"),
                  Tab(text: "All"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTransactionList(todayTransactions),
                  Column(
                    children: [
                      _buildFilters(),
                      Expanded(
                        child: _buildTransactionList(
                          allTransactions,
                          isAllTab: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
