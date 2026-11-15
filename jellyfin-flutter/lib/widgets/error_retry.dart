import 'package:material_ui/material_ui.dart';

import '../core/failure.dart';

/// An error message with a Retry button.
class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.error, required this.onRetry});

  static const retryButton = Key('error.retry');

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    final text = error is Failure ? error.message : 'Something went wrong.';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 12),
          Flexible(child: Text(text)),
          const SizedBox(width: 12),
          TextButton(
            key: retryButton,
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
