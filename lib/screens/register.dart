import 'package:flutter/material.dart';
import 'package:wet_go/repositories/users_repository.dart';
import 'package:wet_go/screens/widgets/btn/btn_submit.dart';
import 'package:wet_go/screens/widgets/btn/btn_text_primary.dart';
import 'package:wet_go/screens/widgets/form/custom_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:wet_go/providers/app_route.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  var _isLoading = false;
  var _enteredEmail = '';
  var _enteredPhone = '';
  var _enteredPassword = '';

  void _submit() async {
    final isValid = _form.currentState?.validate() ?? false;
    if (!isValid) return;

    _form.currentState!.save();

    setState(() => _isLoading = true);

    final usersRepo = UsersRepository();
    final result = await usersRepo.register(
      _enteredEmail,
      _enteredPhone,
      _enteredPassword,
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

      context.go(AppRoute.auth); // Navigate to login
    }
  }

  void _cancel() async {
    context.go(AppRoute.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          BtnSubmit(
                            text: 'Signup',
                            onPressed: _submit,
                            isLoading: _isLoading,
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('I already have an account?'),
                              BtnTextPrimary(text: "Login", onPressed: _cancel),
                            ],
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
