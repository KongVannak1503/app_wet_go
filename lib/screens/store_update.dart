import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../repositories/stores_repository.dart';
import '../screens/widgets/form/custom_text_field.dart';
import '../screens/widgets/btn/btn_submit.dart';
import '../screens/widgets/text/text_light.dart';
import '../l10n/app_localizations.dart';
import 'package:wet_go/screens/widgets/store/wet_go_logo.dart';

class StoreUpdateScreen extends StatefulWidget {
  final Map<String, dynamic> store;

  const StoreUpdateScreen({super.key, required this.store});

  @override
  State<StoreUpdateScreen> createState() => _StoreUpdateScreenState();
}

class _StoreUpdateScreenState extends State<StoreUpdateScreen> {
  final _form = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _stallIdController;
  late TextEditingController _nameController;
  late TextEditingController _ownerController;
  late TextEditingController _groupController;
  late TextEditingController _amountController;

  bool _status = false;

  @override
  void initState() {
    super.initState();
    // fill fields with old values
    _stallIdController = TextEditingController(
      text: widget.store['stallId'] ?? '',
    );
    _nameController = TextEditingController(text: widget.store['name'] ?? '');
    _ownerController = TextEditingController(text: widget.store['owner'] ?? '');
    _groupController = TextEditingController(text: widget.store['group'] ?? '');
    _amountController = TextEditingController(
      text: (widget.store['amount'] ?? 0).toString(),
    );
    _status = widget.store['isActive'] ?? false;
  }

  @override
  void dispose() {
    _stallIdController.dispose();
    _nameController.dispose();
    _ownerController.dispose();
    _groupController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _form.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      final storeRepo = Provider.of<StoresRepository>(context, listen: false);
      final token = storeRepo.token;

      final storeRepos = StoresRepository(token: token);
      final result = await storeRepos.updateStoreApi(
        widget.store['_id'] ?? widget.store['id'],
        _stallIdController.text,
        _nameController.text,
        _ownerController.text,
        _groupController.text,
        double.tryParse(_amountController.text) ?? 0,
        _status,
      );

      setState(() => _isLoading = false);

      if (result.containsKey('error')) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['error']!)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Update successful')),
        );
        context.pop({
          ...widget.store,
          'stallId': _stallIdController.text,
          'name': _nameController.text,
          'owner': _ownerController.text,
          'group': _groupController.text,
          'amount': double.tryParse(_amountController.text) ?? 0,
          'isActive': _status,
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextLight(text: '${loc?.edit} ${loc?.store}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: Column(
                children: [
                  WetGoLogoWidget(),
                  CustomTextField(
                    label: '${loc?.stallId}',
                    controller: _stallIdController,
                    validator: (v) => (v == null || v.isEmpty)
                        ? '${loc?.pleaseEnter}${loc?.khSpace}${loc?.stallId}'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: '${loc?.name}',
                    controller: _nameController,
                    validator: (v) => (v == null || v.isEmpty)
                        ? '${loc?.pleaseEnter}${loc?.khSpace}${loc?.name}'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: '${loc?.owner}',
                    controller: _ownerController,
                    validator: (v) => (v == null || v.isEmpty)
                        ? '${loc?.pleaseEnter}${loc?.khSpace}${loc?.owner}'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: '${loc?.group}',
                    controller: _groupController,
                    validator: (v) => (v == null || v.isEmpty)
                        ? '${loc?.pleaseEnter}${loc?.khSpace}${loc?.group}'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: '${loc?.amount}',
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => (v == null || v.isEmpty)
                        ? '${loc?.pleaseEnter}${loc?.khSpace}${loc?.amount}'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('${loc?.status}'),
                    value: _status,
                    onChanged: (v) => setState(() => _status = v),
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  BtnSubmit(
                    text: '${loc?.edit}',
                    onPressed: _submit,
                    isLoading: _isLoading,
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
