import 'package:flutter/material.dart';
import 'package:wet_go/screens/widgets/btn/btn_submit.dart';
import 'package:wet_go/screens/widgets/btn/btn_text_primary.dart';
import 'package:wet_go/screens/widgets/form/custom_text_field.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLoading = true;
  var _enteredEmail = '';
  var _enteredPassword = '';

  void _submit() async {
    context.go('/home');
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
                          BtnSubmit(text: 'Login', onPressed: _submit),
                          SizedBox(height: 16),
                          BtnTextPrimary(
                            text: "Create an account",
                            onPressed: () {
                              // handle tap
                            },
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
