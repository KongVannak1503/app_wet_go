import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';
import 'package:wet_go/providers/authenticator_provider.dart';
import 'package:wet_go/repositories/transaction_repository.dart';
import 'package:wet_go/screens/widgets/text/head_line_1.dart';

class TransactionTableCard extends StatefulWidget {
  const TransactionTableCard({super.key});

  @override
  State<TransactionTableCard> createState() => _TransactionTableCardState();
}

class _TransactionTableCardState extends State<TransactionTableCard> {
  final TextEditingController _dateController = TextEditingController();
  List<Map<String, dynamic>> _transactions = [];
  bool _loading = false;
  TransactionRepository? _transactionRepo;

  @override
  void initState() {
    super.initState();
    _fetchTransactions(todayOnly: true);
  }

  Future<void> _fetchTransactions({bool todayOnly = false}) async {
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
      String? date;
      if (todayOnly) {
        // Set the text field with today's date
        final todayDate = DateTime.now().toIso8601String().split('T')[0];
        _dateController.text = todayDate;
        date = todayDate;
      } else if (_dateController.text.isNotEmpty) {
        date = _dateController.text;
      }

      final data = await _transactionRepo!.getTransactions(date: date);

      if (!mounted) return;
      setState(() {
        _transactions = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching transactions: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _exportToExcel() async {
    if (_transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No transactions to export")),
      );
      return;
    }

    final excel = Excel.createExcel();
    final sheet = excel['Transactions'];

    // Header row
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Store Name'),
      TextCellValue('Store Owner'),
      TextCellValue('Amount'),
      TextCellValue('Paid Amount'),
      TextCellValue('Status'),
    ]);

    // Data rows
    for (final tx in _transactions) {
      final store = (tx['storeId'] as Map<String, dynamic>?) ?? {};
      final amount = store['amount'] ?? 0;
      final paidAmount = tx['finalAmount'] ?? 0;
      sheet.appendRow([
        TextCellValue(store['stallId'] ?? 'Unknown Store'),
        TextCellValue(store['name'] ?? 'Unknown Store'),
        TextCellValue(store['owner'] ?? 'Unknown Store'),
        DoubleCellValue(amount.toDouble()),
        DoubleCellValue(paidAmount.toDouble()),
        TextCellValue(tx['status'] ?? 'Pending'),
      ]);
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final bytes = excel.encode();
    if (bytes == null) return;

    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    OpenFile.open(filePath);
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Date filter
          Expanded(
            child: TextField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Filter by date',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final picked = await showDatePicker(
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
            tooltip: 'Search transactions',
            onPressed: () => _fetchTransactions(todayOnly: false),
          ),
          TextButton.icon(
            icon: const Icon(Icons.file_download),
            label: const Text(''),
            onPressed: _exportToExcel,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionGrid() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_transactions.isEmpty) {
      return const Center(child: Text("No transactions found."));
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: _transactions.map((tx) {
        final store = (tx['storeId'] as Map<String, dynamic>?) ?? {};
        final name = store['name'] ?? 'Unknown Store';
        final status = tx['status'] ?? 'Pending';
        final amount = store['amount'] ?? 0;

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
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeadLine1(text: "Transactions Recently"),
                const SizedBox(height: 16),
                _buildFilters(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildTransactionGrid(),
      ],
    );
  }
}
