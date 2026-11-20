import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/config.dart';
import '../../../core/failure.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/auth_form.dart';

/// What the connect screen starts with in its address field.
final defaultServerAddressProvider = Provider<String>(
  (ref) => defaultServerAddress,
);

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  static const urlField = Key('connect.url');
  static const fallbackField = Key('connect.fallback');
  static const submitButton = Key('connect.submit');

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  late final _url = TextEditingController(
    text: ref.read(defaultServerAddressProvider),
  );
  final _fallback = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _url.dispose();
    _fallback.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (_url.text.trim().isEmpty) {
      setState(() => _error = context.l10n.serverAddressMissing);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // On success the router moves on to the login screen.
      await ref
          .read(authControllerProvider.notifier)
          .connect(_url.text, fallback: _fallback.text);
    } on Failure catch (e) {
      if (mounted) setState(() => _error = e.describe(context.l10n));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: context.l10n.connectTitle,
      subtitle: context.l10n.connectSubtitle,
      children: [
        TextField(
          key: ConnectScreen.urlField,
          controller: _url,
          autofocus: true,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.go,
          decoration: InputDecoration(
            labelText: context.l10n.serverAddress,
            hintText: 'https://192.168.1.10:8096',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 16),
        TextField(
          key: ConnectScreen.fallbackField,
          controller: _fallback,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.go,
          decoration: InputDecoration(
            labelText: context.l10n.fallbackAddress,
            helperText: context.l10n.fallbackAddressHint,
            helperMaxLines: 2,
            hintText: 'https://jellyfin.example.com',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 16),
        SubmitButton(
          key: ConnectScreen.submitButton,
          label: context.l10n.connect,
          busy: _busy,
          onPressed: _submit,
        ),
        FormError(_error),
      ],
    );
  }
}
