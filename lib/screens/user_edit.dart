import 'package:flutter/material.dart';
import 'package:wet_go/l10n/app_localizations.dart';
import 'package:wet_go/providers/authenticator_provider.dart';
import 'package:wet_go/repositories/users_repository.dart';
import 'package:wet_go/screens/widgets/btn/btn_submit.dart';
import 'package:wet_go/screens/widgets/form/custom_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:wet_go/screens/widgets/text/text_light.dart';
import 'package:wet_go/screens/widgets/user/user_role.dart';
import 'package:provider/provider.dart';

class UserEditScreen extends StatefulWidget {
  final String dataId;
  const UserEditScreen({super.key, required this.dataId});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _form = GlobalKey<FormState>();
  var _isLoading = false;
  var _enteredEmail = '';
  var _enteredPhone = '';
  var _enteredPassword = '';
  String _selectedRole = UserRole.user;

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _status = false;

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
    final userRepo = UsersRepository(token: token);
    try {
      final response = await userRepo.user(widget.dataId);
      final user = response['data'];
      setState(() {
        _emailController.text = user['email'];
        _phoneController.text = user['phone'];
        _selectedRole = user['role'] ?? UserRole.user;
        _status = user['isActive'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _submit() async {
    final isValid = _form.currentState?.validate() ?? false;
    if (!isValid) return;

    _form.currentState!.save();

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthenticatorProvider>(
      context,
      listen: false,
    );
    final token = authProvider.token;

    final usersRepo = UsersRepository(token: token);
    final passwordToSend = _enteredPassword.trim().isEmpty
        ? null
        : _enteredPassword;
    final result = await usersRepo.editUserApi(
      widget.dataId,
      _enteredEmail,
      _enteredPhone,
      passwordToSend,
      _selectedRole,
      _status,
    );

    setState(() => _isLoading = false);

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['error']!)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Registration successful')),
      );

      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextLight(text: '${loc?.edit} ${loc?.user}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  top: 30,
                ),
                width: 200,
                child: Image.asset('assets/images/wet_go_logo.png'),
              ),
              Card(
                color: Colors.transparent,
                elevation: 0,
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          CustomTextField(
                            controller: _phoneController,
                            label: 'Phone',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Phone must be at least 9 characters long.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPhone = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          CustomTextField(
                            label: 'Password',
                            keyboardType: TextInputType.emailAddress,
                            obscureText: true,
                            // validator: (value) {
                            //   if (value == null || value.trim().length < 6) {
                            //     return 'Password must be at least 6 characters long.';
                            //   }
                            //   return null;
                            // },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            items: UserRole.values.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(
                                  role.toUpperCase(),
                                ), // Show role nicely
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: "Select Role",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: Text('${loc?.status}'),
                            value: _status,
                            onChanged: (v) => setState(() => _status = v),
                            activeThumbColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),

                          SizedBox(height: 16),
                          BtnSubmit(
                            text: '${loc?.save}',
                            onPressed: _submit,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
