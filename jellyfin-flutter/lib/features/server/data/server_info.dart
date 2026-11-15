import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_info.freezed.dart';
part 'server_info.g.dart';

/// A server the user connected to (stored, so the login screen knows it
/// after a restart).
@freezed
abstract class ServerInfo with _$ServerInfo {
  const factory ServerInfo({
    /// Normalized base URL, no trailing slash: http://jellyfin:8096
    required String url,
    required String id,
    required String name,
    required String version,
  }) = _ServerInfo;

  factory ServerInfo.fromJson(Map<String, dynamic> json) =>
      _$ServerInfoFromJson(json);
}
