
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl  = TextEditingController();
  final _newCtrl  = TextEditingController();
  final _new2Ctrl = TextEditingController();

  bool   _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              TextFormField(
                controller: _oldCtrl,
                decoration: const InputDecoration(labelText: 'Current password'),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Enter current password' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newCtrl,
                decoration: const InputDecoration(labelText: 'New password'),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.length < 8) ? 'Minimum 8 characters' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _new2Ctrl,
                decoration: const InputDecoration(labelText: 'Confirm new password'),
                obscureText: true,
                validator: (v) =>
                    v != _newCtrl.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 32),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() { _loading = true; _error = null; });

                        final ok = await auth.changePassword(
                            _oldCtrl.text.trim(), _newCtrl.text.trim());

                        setState(() { _loading = false; });
                        if (ok) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password changed — please log in again'),
                            ),
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (_) => false,
                          );
                        } else {
                          setState(() => _error =
                              auth.errorMessage ?? 'Change-password failed');
                        }
                      },
                      child: const Text('Change password'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _new2Ctrl.dispose();
    super.dispose();
  }
}





/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl  = TextEditingController();
  final _newCtrl  = TextEditingController();
  final _new2Ctrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              TextFormField(
                controller: _oldCtrl,
                decoration:
                    const InputDecoration(labelText: 'Current password'),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter current password' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newCtrl,
                decoration: const InputDecoration(labelText: 'New password'),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.length < 8) ? 'Minimum 8 characters' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _new2Ctrl,
                decoration:
                    const InputDecoration(labelText: 'Confirm new password'),
                obscureText: true,
                validator: (v) =>
                    v != _newCtrl.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 32),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        final ok = await auth.changePassword(
                            _oldCtrl.text.trim(), _newCtrl.text.trim());
                        setState(() => _loading = false);
                        if (ok) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password changed')));
                          Navigator.pop(context);
                        } else {
                          setState(() => _error =
                              auth.errorMessage ?? 'Change-password failed');
                        }
                      },
                      child: const Text('Change password'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _new2Ctrl.dispose();
    super.dispose();
  }
}
*/