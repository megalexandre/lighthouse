import '../core/failure.dart';
import 'generated/app_localizations.dart';

extension FailureText on Failure {
  /// The failure in plain words, in the app's language. Never an
  /// exception's own text: that goes to the log ([Failure.detail]).
  String describe(AppLocalizations l10n) => switch (this) {
    ServerUnreachable(:final url) => l10n.failureUnreachable(url),
    NotJellyfinServer(:final url) => l10n.failureNotJellyfin(url),
    ServerNotSetUp(:final url) => l10n.failureNotSetUp(url),
    Unauthorized() => l10n.failureUnauthorized,
    ServerError(badCertificate: true) => l10n.failureServerBadCertificate,
    ServerError(:final int statusCode) => l10n.failureServerStatus(statusCode),
    ServerError() => l10n.failureServerUnexpected,
    StorageFailure(target: StorageTarget.keyring) => l10n.failureStorageKeyring,
    StorageFailure(target: StorageTarget.disk) => l10n.failureStorageDisk,
    NotPlayable(:final reason) => l10n.failureNotPlayable(reason),
    PlayerError() => l10n.failurePlayer,
    NotReadable() => l10n.failureNotReadable,
  };
}

/// Any error in plain words: a [Failure] as above, anything else as "Something
/// went wrong".
String describeError(Object error, AppLocalizations l10n) =>
    error is Failure ? error.describe(l10n) : l10n.errorUnknown;
