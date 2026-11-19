import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';

part 'public_system_info.freezed.dart';
part 'public_system_info.g.dart';

/// `GET /System/Info/Public`: answers without a login, so it is how the app
/// checks that an address is a Jellyfin server.
@freezed
abstract class PublicSystemInfo with _$PublicSystemInfo {
  const factory PublicSystemInfo({
    required String id,
    required String serverName,
    required String version,
    String? productName,
    bool? startupWizardCompleted,
  }) = _PublicSystemInfo;

  factory PublicSystemInfo.fromJson(Map<String, dynamic> json) =>
      _$PublicSystemInfoFromJson(json);

  static const jsonShape = JsonShape(_$PublicSystemInfoFieldMap);
}
