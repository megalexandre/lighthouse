/// Everything that can go wrong talking to a server or storing a session,
/// as the UI needs to tell it apart. The API layer turns transport errors
/// into one of these; nothing above it sees a DioException.
sealed class Failure implements Exception {
  const Failure();

  /// Text for the user: plain words, never an exception's own text.
  String get message;

  /// What went wrong technically, for the log; never shown to the user.
  String? get detail => null;

  @override
  String toString() => detail == null
      ? '$runtimeType: $message'
      : '$runtimeType: $message ($detail)';
}

/// No answer: wrong address, server down, no network, timeout.
final class ServerUnreachable extends Failure {
  const ServerUnreachable(this.url);
  final String url;
  @override
  String get message =>
      'Cannot reach $url. Check the address and that the '
      'server is running.';
}

/// Something answered, but it is not a Jellyfin server.
final class NotJellyfinServer extends Failure {
  const NotJellyfinServer(this.url);
  final String url;
  @override
  String get message => '$url does not look like a Jellyfin server.';
}

/// The server's setup wizard has not been finished yet.
final class ServerNotSetUp extends Failure {
  const ServerNotSetUp(this.url);
  final String url;
  @override
  String get message =>
      'The server at $url is not set up yet. Open it in a '
      'browser and finish the setup wizard first.';
}

/// 401. On login it means wrong credentials; on any other call, the session
/// is no longer valid (logged out elsewhere, token revoked).
final class Unauthorized extends Failure {
  const Unauthorized();
  @override
  String get message => 'Wrong username or password.';
}

/// Any other error status, or a response the app cannot read. [hint], when
/// the cause means something to the user (a bad certificate), replaces the
/// generic message.
final class ServerError extends Failure {
  const ServerError(this.detail, {this.statusCode, this.hint});
  @override
  final String detail;
  final int? statusCode;
  final String? hint;
  @override
  String get message =>
      hint ??
      (statusCode == null
          ? 'Unexpected response from the server.'
          : 'The server answered with error $statusCode.');
}

/// The system keyring refused to store or read the session (or, [what]
/// says, another store refused something else).
final class StorageFailure extends Failure {
  const StorageFailure(
    this.detail, {
    this.what = 'the login in the system keyring',
  });
  @override
  final String detail;
  final String what;
  @override
  String get message => 'Could not save $what.';
}

/// The server offers no way for this client to play the item.
final class NotPlayable extends Failure {
  const NotPlayable(this.reason);
  final String reason;
  @override
  String get message => 'This item cannot be played ($reason).';
}

/// The player could not open or decode the stream.
final class PlayerError extends Failure {
  const PlayerError(this.detail);
  @override
  final String detail;
  @override
  String get message => 'Playback failed: the stream could not be opened.';
}

/// The book is in a format the reader cannot open.
final class NotReadable extends Failure {
  const NotReadable(this.format);
  final String format;
  @override
  String get message => 'Reading $format is not supported yet.';
}
