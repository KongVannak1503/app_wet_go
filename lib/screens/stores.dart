import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wet_go/l10n/app_localizations.dart';
import 'package:wet_go/providers/authenticator_provider.dart';
import 'package:wet_go/repositories/stores_repository.dart';
import 'package:wet_go/screens/widgets/store/store_cart_list_item.dart';
import 'package:wet_go/screens/widgets/text/text_light.dart';
import 'package:wet_go/providers/app_route.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  final List<dynamic> _stores = [];
  final List<dynamic> _filteredStores = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _fetchStores();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore &&
        !_isLoading) {
      _fetchMoreStores();
    }
  }

  Future<void> _fetchStores() async {
    setState(() => _isLoading = true);
    final token = Provider.of<AuthenticatorProvider>(
      context,
      listen: false,
    ).token;
    if (token == null) return setState(() => _isLoading = false);

    final repo = StoresRepository(token: token);
    final response = await repo.getStore(page: 1, limit: _limit);

    if (response.containsKey('error')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response['error']!)));
    } else {
      final data = response['data'] ?? [];
      setState(() {
        _stores.clear();
        _stores.addAll(data);
        _filteredStores.clear();
        _filteredStores.addAll(_stores);
        _hasMore = data.length == _limit;
        _currentPage = 1;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _fetchMoreStores() async {
    if (!_hasMore) return;
    setState(() => _isLoadingMore = true);

    final token = Provider.of<AuthenticatorProvider>(
      context,
      listen: false,
    ).token;
    if (token == null) return setState(() => _isLoadingMore = false);

    final repo = StoresRepository(token: token);
    final response = await repo.getStore(page: _currentPage + 1, limit: _limit);

    if (response.containsKey('error')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response['error']!)));
    } else {
      final data = response['data'] ?? [];
      setState(() {
        _stores.addAll(data);
        _filteredStores.clear();
        _filteredStores.addAll(_stores);
        _currentPage++;
        _hasMore = data.length == _limit;
      });
    }

    setState(() => _isLoadingMore = false);
  }

  void _filterStores(String query) {
    final q = query.toLowerCase();
    final filtered = _stores.where((store) {
      final name = store['name']?.toString().toLowerCase() ?? '';
      final stallId = store['stallId']?.toString().toLowerCase() ?? '';
      return name.contains(q) || stallId.contains(q);
    }).toList();

    setState(() {
      _filteredStores.clear();
      _filteredStores.addAll(filtered);
    });
  }

  void _createStore() async {
    final newStore = await context.push<Map<String, dynamic>>(
      AppRoute.storeCreate,
    );
    if (newStore != null) {
      setState(() {
        _stores.insert(0, newStore); // add at top
        _filteredStores.clear();
        _filteredStores.addAll(_stores);
      });

      // Optional: scroll to top
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextLight(text: loc?.stores ?? 'Stores'),
        actions: [
          IconButton(onPressed: _createStore, icon: const Icon(Icons.add)),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
              ),
              onChanged: _filterStores,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          _filteredStores.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _filteredStores.length) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final store = _filteredStores[index];
                        return StoreCartListItem(
                          id: store['_id'],
                          name: store['name'],
                          stallId: store['stallId'],
                          owner: store['owner'],
                          group: store['group'],
                          amount: (store['amount'] as num).toDouble(),
                          isActive: store['isActive'],
                          onTap: () async {
                            final updatedStore = await context
                                .push<Map<String, dynamic>>(
                                  AppRoute.storeUpdate,
                                  extra: store,
                                );
                            if (updatedStore != null) {
                              setState(() {
                                final idx = _stores.indexWhere(
                                  (s) => s['_id'] == updatedStore['_id'],
                                );
                                if (idx != -1) _stores[idx] = updatedStore;

                                _filteredStores.clear();
                                _filteredStores.addAll(_stores);
                              });
                            }
                          },
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
