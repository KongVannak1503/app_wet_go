import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../repositories/stores_repository.dart';
import '../screens/widgets/form/custom_text_field.dart';
import '../screens/widgets/btn/btn_submit.dart';
import '../screens/widgets/text/text_light.dart';
import '../l10n/app_localizations.dart';
import 'package:wet_go/screens/widgets/store/wet_go_logo.dart';

class StoreCreateScreen extends StatefulWidget {
  const StoreCreateScreen({super.key});

  @override
  State<StoreCreateScreen> createState() => _StoreCreateScreenState();
}

class _StoreCreateScreenState extends State<StoreCreateScreen> {
  final _form = GlobalKey<FormState>();
  bool _isLoading = false;

  String _enteredStallID = '';
  String _enteredName = '';
  String _enteredOwner = '';
  String _enteredGroup = '';
  double _enteredAmount = 1000;
  bool _status = false;

  final TextEditingController _amountController = TextEditingController(
    text: '1000',
  );

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _form.currentState?.validate() ?? false;
    if (!isValid) return;

    _form.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final storeRepo = Provider.of<StoresRepository>(context, listen: false);
      final token = storeRepo.token;

      final storeRepos = StoresRepository(token: token);
      final result = await storeRepos.createStoreApi(
        _enteredStallID,
        _enteredName,
        _enteredOwner,
        _enteredGroup,
        _enteredAmount,
        _status,
      );

      setState(() => _isLoading = false);

      if (result.containsKey('error')) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['error']!)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Create successful')),
        );

        // Return new store data to previous screen
        Navigator.of(context).pop({
          "_id": result['data']['_id'], // adjust if API returns differently
          "stallId": _enteredStallID,
          "name": _enteredName,
          "owner": _enteredOwner,
          "group": _enteredGroup,
          "amount": _enteredAmount,
          "isActive": _status,
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
        title: TextLight(text: '${loc?.create} ${loc?.store}'),
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
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: '${loc?.stallId}',
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Please enter Stall ID'
                        : null,
                    onSaved: (v) => _enteredStallID = v!,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: '${loc?.name}',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Please enter Name' : null,
                    onSaved: (v) => _enteredName = v!,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: '${loc?.owner}',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Please enter Owner' : null,
                    onSaved: (v) => _enteredOwner = v!,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: '${loc?.group}',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Please enter Group' : null,
                    onSaved: (v) => _enteredGroup = v!,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: '${loc?.amount}',
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Please enter Amount' : null,
                    onSaved: (v) =>
                        _enteredAmount = double.tryParse(v ?? '0') ?? 0,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('${loc?.status ?? 'Status'}'),
                    value: _status,
                    onChanged: (v) => setState(() => _status = v),
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  BtnSubmit(
                    text: '${loc?.save ?? 'Save'}',
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
