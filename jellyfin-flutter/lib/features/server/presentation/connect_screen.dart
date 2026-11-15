import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/config.dart';
import '../../../core/failure.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/auth_form.dart';

/// What the connect screen starts with in its address field.
final defaultServerAddressProvider = Provider<String>(
  (ref) => defaultServerAddress,
);

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  static const urlField = Key('connect.url');
  static const submitButton = Key('connect.submit');

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  late final _url = TextEditingController(
    text: ref.read(defaultServerAddressProvider),
  );
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (_url.text.trim().isEmpty) {
      setState(() => _error = 'Enter the server address.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // On success the router moves on to the login screen.
      await ref.read(authControllerProvider.notifier).connect(_url.text);
    } on Failure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: 'Connect to a server',
      subtitle: 'Enter the address of your Jellyfin server.',
      children: [
        TextField(
          key: ConnectScreen.urlField,
          controller: _url,
          autofocus: true,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.go,
          decoration: const InputDecoration(
            labelText: 'Server address',
            hintText: 'http://192.168.1.10:8096',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 16),
        SubmitButton(
          key: ConnectScreen.submitButton,
          label: 'Connect',
          busy: _busy,
          onPressed: _submit,
        ),
        FormError(_error),
      ],
    );
  }
}
