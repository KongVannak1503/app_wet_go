import 'package:flutter/material.dart';
import 'package:wet_go/repositories/users_repository.dart';
import 'package:wet_go/screens/widgets/btn/btn_submit.dart';
import 'package:wet_go/screens/widgets/form/custom_text_field.dart';
import 'package:wet_go/screens/widgets/text/text_light.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  var _isLoading = false;
  var _enteredOldPassword = '';
  var _enteredNewPassword = '';

  void _submit() async {
    final isValid = _form.currentState?.validate() ?? false;
    if (!isValid) return;

    _form.currentState!.save();

    setState(() => _isLoading = true);

    final usersRepo = UsersRepository();
    // final result = await usersRepo.register(
    //   _enteredOldPassword,
    //   _enteredNewPassword,
    // );

    setState(() => _isLoading = false);

    // if (result.containsKey('error')) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text(result['error']!)));
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(result['message'] ?? 'Registration successful')),
    //   );

    //   context.go('/auth'); // Navigate to login
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextLight(text: 'Change Password'),
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
                            label: 'Old Password',
                            keyboardType: TextInputType.emailAddress,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredOldPassword = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          CustomTextField(
                            label: 'New Password',
                            keyboardType: TextInputType.emailAddress,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredNewPassword = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          BtnSubmit(
                            text: 'Save',
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
