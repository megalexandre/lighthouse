/// Everything that can go wrong talking to a server or storing a session,
/// as the UI needs to tell it apart. The API layer turns transport errors
/// into one of these; nothing above it sees a DioException.
///
/// A failure holds no text for the user: the screens word it in the app's
/// language (`describe` in lib/l10n/failure_text.dart, one case per kind).
sealed class Failure implements Exception {
  const Failure();

  /// What went wrong, for the log; never shown to the user.
  String? get detail => null;

  @override
  String toString() =>
      detail == null ? '$runtimeType' : '$runtimeType: $detail';
}

/// No answer: wrong address, server down, no network, timeout.
final class ServerUnreachable extends Failure {
  const ServerUnreachable(this.url);
  final String url;
  @override
  String get detail => url;
}

/// Something answered, but it is not a Jellyfin server.
final class NotJellyfinServer extends Failure {
  const NotJellyfinServer(this.url);
  final String url;
  @override
  String get detail => url;
}

/// The server's setup wizard has not been finished yet.
final class ServerNotSetUp extends Failure {
  const ServerNotSetUp(this.url);
  final String url;
  @override
  String get detail => url;
}

/// 401. On login it means wrong credentials; on any other call, the session
/// is no longer valid (logged out elsewhere, token revoked).
final class Unauthorized extends Failure {
  const Unauthorized();
}

/// Any other error status, or a response the app cannot read.
/// [badCertificate]: the HTTPS certificate was refused, which the user is
/// told (they can act on it); other causes stay in [detail].
final class ServerError extends Failure {
  const ServerError(
    this.detail, {
    this.statusCode,
    this.badCertificate = false,
  });
  @override
  final String detail;
  final int? statusCode;
  final bool badCertificate;
}

/// Where a [StorageFailure] happened.
enum StorageTarget {
  /// The system keyring, which keeps the session.
  keyring,

  /// The app's own files.
  disk,
}

/// A store refused to save something: the keyring the session, or the disk
/// one of the app's files.
final class StorageFailure extends Failure {
  const StorageFailure(this.detail, {this.target = StorageTarget.keyring});
  @override
  final String detail;
  final StorageTarget target;
}

/// The server offers no way for this client to play the item.
final class NotPlayable extends Failure {
  const NotPlayable(this.reason);
  final String reason;
  @override
  String get detail => reason;
}

/// The player could not open or decode the stream.
final class PlayerError extends Failure {
  const PlayerError(this.detail);
  @override
  final String detail;
}

/// The book is in a format the reader cannot open ([detail] says which,
/// for the log).
final class NotReadable extends Failure {
  const NotReadable(this.detail);
  @override
  final String detail;
}
