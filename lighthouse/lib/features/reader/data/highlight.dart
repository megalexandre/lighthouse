import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color, TextRange;

/// The colours a passage can be highlighted in.
enum HighlightColor {
  yellow(Color(0xFFFBC02D)),
  red(Color(0xFFE53935)),
  blue(Color(0xFF1E88E5));

  const HighlightColor(this.color);

  /// The swatch, at full strength (the menu's dots, the list).
  final Color color;

  /// What is drawn under the text: light enough to read the ink through,
  /// on any paper.
  Color get fill => color.withValues(alpha: 0.38);
}

/// A passage the user highlighted, with an optional [note]. [start] and
/// [end] count characters of the book as [EpubBook.offsetOf] does, which do
/// not change with the window or the type, so a highlight stays on its
/// words whatever the pages. Kept on this device: the server has no place
/// for it.
@immutable
class Highlight {
  const Highlight({
    required this.start,
    required this.end,
    required this.color,
    required this.text,
    required this.created,
    this.note = '',
    this.voice = '',
    this.voiceLength = Duration.zero,
  });

  final int start;
  final int end;
  final HighlightColor color;

  /// The words highlighted, kept to list them without the book laid out.
  final String text;
  final String note;
  final DateTime created;

  /// The voice note's file, in the voice notes' folder
  /// (voiceNotesDirectoryProvider); empty when there is none.
  final String voice;
  final Duration voiceLength;

  bool get hasVoice => voice.isNotEmpty;

  TextRange get range => TextRange(start: start, end: end);

  /// Whether it covers the character at [offset].
  bool covers(int offset) => offset >= start && offset < end;

  /// [voice] '' takes the voice note off.
  Highlight copyWith({
    HighlightColor? color,
    String? note,
    String? voice,
    Duration? voiceLength,
  }) => Highlight(
    start: start,
    end: end,
    color: color ?? this.color,
    text: text,
    created: created,
    note: note ?? this.note,
    voice: voice ?? this.voice,
    voiceLength: voice == '' ? Duration.zero : voiceLength ?? this.voiceLength,
  );

  Map<String, Object> toJson() => {
    'start': start,
    'end': end,
    'color': color.name,
    'text': text,
    if (note.isNotEmpty) 'note': note,
    if (hasVoice) 'voice': voice,
    if (hasVoice) 'voiceMs': voiceLength.inMilliseconds,
    'created': created.toUtc().toIso8601String(),
  };

  /// Null for an entry that makes no sense (an edited file, an older app).
  static Highlight? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final start = json['start'];
    final end = json['end'];
    final color = HighlightColor.values.asNameMap()[json['color']];
    final voice = json['voice'];
    final voiceMs = json['voiceMs'];
    if (start is! int || end is! int || start < 0 || end <= start) {
      return null;
    }
    return Highlight(
      start: start,
      end: end,
      color: color ?? HighlightColor.yellow,
      text: json['text'] is String ? json['text'] as String : '',
      note: json['note'] is String ? json['note'] as String : '',
      // Only a bare file name: never a path out of the notes' folder.
      voice: voice is String && RegExp(r'^\w[\w.-]*$').hasMatch(voice)
          ? voice
          : '',
      voiceLength: Duration(milliseconds: voiceMs is int ? voiceMs : 0),
      created:
          DateTime.tryParse(json['created'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Highlight &&
      other.start == start &&
      other.end == end &&
      other.color == color &&
      other.text == text &&
      other.note == note &&
      other.created == created &&
      other.voice == voice &&
      other.voiceLength == voiceLength;

  @override
  int get hashCode =>
      Object.hash(start, end, color, text, note, created, voice, voiceLength);
}
