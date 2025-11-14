import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';

class LoginSignupScreen extends StatefulWidget {
  static const routeName = '/auth';
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _login = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final app = context.read<AppState>();

    try {
      bool ok;
      if (_login) {
        ok = await app.login(_email.text.trim(), _pass.text);
      } else {
        ok = await app.signup(_name.text.trim(), _email.text.trim(), _pass.text);
      }
      if (!ok) {
        setState(() => _error = 'Invalid credentials or signup failed.');
      } else {
        if (mounted) {
          if (!app.isVip) {
            Navigator.of(context).pushReplacementNamed('/');
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.pushNamed(context, '/premium');
              }
            });
          } else {
            Navigator.of(context).pushReplacementNamed('/');
          }
        }
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF58CC02);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _login ? 'Welcome back' : 'Create your account',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red.withValues(alpha: 0.08),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 12),
                Form(
                  key: _form,
                  child: Column(
                    children: [
                      if (!_login)
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                        ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pass,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (v) =>
                            (v == null || v.length < 6) ? 'Min 6 chars' : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            shape: const StadiumBorder(),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(_login ? 'Login' : 'Sign up'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => setState(() => _login = !_login),
                        child: Text(_login
                            ? "Don't have an account? Sign up"
                            : 'Already have an account? Login'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
