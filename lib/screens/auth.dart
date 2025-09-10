import 'package:flutter/material.dart';
import 'package:wet_go/providers/authenticator_provider.dart';
import 'package:wet_go/screens/widgets/btn/btn_submit.dart';
import 'package:wet_go/screens/widgets/btn/btn_text_primary.dart';
import 'package:wet_go/screens/widgets/form/custom_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wet_go/providers/app_route.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _isLoading = false;
  String? _errorMessage;

  void _submit() async {
    final isValid = _form.currentState?.validate() ?? false;
    if (!isValid) return;

    _form.currentState!.save();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Use the provider to get the AuthenticatorProvider instance
    final authenticator = Provider.of<AuthenticatorProvider>(
      context,
      listen: false,
    );

    try {
      // Call the login method on the provider, which will handle the API call and state update
      final success = await authenticator.login(
        _enteredEmail,
        _enteredPassword,
      );

      if (success) {
        // The router will automatically handle navigation
        // You do not need to call context.go('/home')
        print("✅ Login successful. Router will handle navigation.");
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password';
        });
      }
    } catch (e) {
      // Catch network or other errors
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _register() async {
    context.go(AppRoute.register);
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
                          if (_errorMessage != null)
                            Container(
                              padding: EdgeInsets.all(12),
                              margin: EdgeInsets.only(bottom: 16),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              BtnTextPrimary(
                                text: "Forget password",
                                onPressed: () {
                                  // handle tap
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          BtnSubmit(
                            text: 'Login',
                            onPressed: _submit,
                            isLoading: _isLoading,
                          ),
                          SizedBox(height: 16),
                          BtnTextPrimary(
                            text: "Create an account",
                            onPressed: _register,
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
