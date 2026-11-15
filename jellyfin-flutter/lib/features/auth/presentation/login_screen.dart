import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/failure.dart';
import '../application/auth_controller.dart';
import 'auth_form.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const usernameField = Key('login.username');
  static const passwordField = Key('login.password');
  static const submitButton = Key('login.submit');
  static const changeServerButton = Key('login.changeServer');

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (_username.text.trim().isEmpty) {
      setState(() => _error = 'Enter your username.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // On success the router moves on to the home screen.
      await ref
          .read(authControllerProvider.notifier)
          .login(_username.text.trim(), _password.text);
    } on Failure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final server = ref.watch(authControllerProvider).value?.server;
    return AuthForm(
      title: 'Sign in',
      subtitle: server == null ? null : '${server.name} · ${server.url}',
      children: [
        TextField(
          key: LoginScreen.usernameField,
          controller: _username,
          autofocus: true,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _passwordFocus.requestFocus(),
        ),
        const SizedBox(height: 16),
        TextField(
          key: LoginScreen.passwordField,
          controller: _password,
          focusNode: _passwordFocus,
          obscureText: true,
          textInputAction: TextInputAction.go,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 16),
        SubmitButton(
          key: LoginScreen.submitButton,
          label: 'Sign in',
          busy: _busy,
          onPressed: _submit,
        ),
        FormError(_error),
        const SizedBox(height: 8),
        TextButton(
          key: LoginScreen.changeServerButton,
          onPressed: _busy
              ? null
              : () => ref.read(authControllerProvider.notifier).changeServer(),
          child: const Text('Change server'),
        ),
      ],
    );
  }
}
