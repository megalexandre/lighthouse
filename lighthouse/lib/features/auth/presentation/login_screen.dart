import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/failure.dart';
import '../../../l10n/l10n.dart';
import '../application/auth_controller.dart';
import 'auth_form.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const usernameField = Key('login.username');
  static const passwordField = Key('login.password');
  static const submitButton = Key('login.submit');
  static const changeServerButton = Key('login.changeServer');
  static const notice = Key('login.notice');

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
      setState(() => _error = context.l10n.usernameMissing);
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
      if (mounted) setState(() => _error = e.describe(context.l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider).value;
    final server = auth?.server;
    // Why the user is here, until an error has something newer to say.
    final notice = _error != null
        ? null
        : switch (auth?.signedOut) {
            SignOutReason.user => context.l10n.signedOutNotice,
            SignOutReason.expired => context.l10n.sessionExpiredNotice,
            null => null,
          };
    return AuthForm(
      title: context.l10n.signIn,
      subtitle: server == null
          ? null
          : context.l10n.serverNameAndUrl(server.name, server.url),
      children: [
        if (notice != null) ...[_Notice(notice), const SizedBox(height: 16)],
        TextField(
          key: LoginScreen.usernameField,
          controller: _username,
          autofocus: true,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: context.l10n.username,
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
          decoration: InputDecoration(
            labelText: context.l10n.password,
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 16),
        SubmitButton(
          key: LoginScreen.submitButton,
          label: context.l10n.signIn,
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
          child: Text(context.l10n.changeServer),
        ),
      ],
    );
  }
}

/// A short line above the form, in the theme's secondary colours: news, not
/// an error.
class _Notice extends StatelessWidget {
  const _Notice(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: LoginScreen.notice,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: colors.onSecondaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
