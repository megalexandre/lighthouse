import '../../../api/models/device_profile.dart';

/// What the app can play, as told to the server. mpv plays nearly every
/// container and codec, so everything is direct play; the server only
/// transcodes when it has to (e.g. a bitrate limit), to HLS. Ported from
/// getDeviceProfile() in jellyfin-desktop/native/nativeshell.js, without
/// its optional "force transcode" settings (they come with F4 settings).
/// [maxStreamingBitrate] (bits/s) is the quality setting; above it the
/// server transcodes down.
DeviceProfile appDeviceProfile({int? maxStreamingBitrate}) => DeviceProfile(
  name: 'Jellyfin Flutter',
  maxStaticBitrate: 1000000000,
  maxStreamingBitrate: maxStreamingBitrate ?? 1000000000,
  musicStreamingTranscodingBitrate: 1280000,
  directPlayProfiles: const [
    DirectPlayProfile(type: 'Video'),
    DirectPlayProfile(type: 'Audio'),
  ],
  transcodingProfiles: const [
    TranscodingProfile(
      type: 'Audio',
      container: 'mp3',
      protocol: 'http',
      audioCodec: 'mp3',
    ),
    TranscodingProfile(
      type: 'Video',
      container: 'ts',
      protocol: 'hls',
      videoCodec: 'h264,h265,hevc,mpeg4,mpeg2video',
      audioCodec: 'aac,mp3,ac3,opus,vorbis',
      maxAudioChannels: '6',
    ),
  ],
  subtitleProfiles: [
    for (final format in [
      'srt',
      'subrip',
      'ass',
      'ssa',
      'sub',
      'smi',
      'vtt',
      'webvtt',
    ]) ...[
      SubtitleProfile(format: format, method: 'External'),
      SubtitleProfile(format: format, method: 'Embed'),
    ],
    for (final format in ['pgssub', 'pgs', 'dvdsub', 'dvbsub'])
      SubtitleProfile(format: format, method: 'Embed'),
  ],
);
