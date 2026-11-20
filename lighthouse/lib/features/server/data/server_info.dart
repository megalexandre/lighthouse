import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_info.freezed.dart';
part 'server_info.g.dart';

/// A server the user connected to (stored, so the login screen knows it
/// after a restart).
@freezed
abstract class ServerInfo with _$ServerInfo {
  const factory ServerInfo({
    /// Normalized base URL in use, no trailing slash: http://jellyfin:8096
    required String url,
    required String id,
    required String name,
    required String version,

    /// The addresses the user gave for this server, as typed, preferred
    /// first: a home one (fedora.local) before one that works from
    /// anywhere. Empty for a server stored before there was a choice, and
    /// for one connected with a single address: then [url] is all there is.
    @Default(<String>[]) List<String> addresses,
  }) = _ServerInfo;

  const ServerInfo._();

  factory ServerInfo.fromJson(Map<String, dynamic> json) =>
      _$ServerInfoFromJson(json);

  /// Where to look for this server, preferred first.
  List<String> get candidates => addresses.isEmpty ? [url] : addresses;
}
