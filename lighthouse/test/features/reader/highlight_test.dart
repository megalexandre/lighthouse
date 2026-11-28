import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/client_info.dart';
import 'package:lighthouse/core/storage.dart';
import 'package:lighthouse/features/reader/data/book_document.dart';
import 'package:lighthouse/features/reader/data/book_repository.dart';
import 'package:lighthouse/features/reader/data/epub/epub_book.dart';
import 'package:lighthouse/features/reader/data/epub/epub_document.dart';
import 'package:lighthouse/features/reader/data/epub/epub_layout.dart';
import 'package:lighthouse/features/reader/data/highlight.dart';
import 'package:lighthouse/features/reader/data/voice_note.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/epub.dart';
import '../../support/fake_http.dart';
import '../../support/fakes.dart';

void main() {
  /// "alpha beta gamma ..." in paragraphs, after a heading.
  final book = EpubBook.read(
    buildEpub([
      '<h1>Title</h1>'
          '<p>alpha beta gamma delta epsilon</p>'
          '<p>zeta eta theta</p>',
      '<p>second chapter words</p>',
    ]),
  );
  const size = Size(400, 600);

  /// Where book characters [start] to [end] are drawn on page [page].
  Rect boxOf(EpubLayout layout, int page, int start, int end) =>
      layout.rectsOf(page, start, end).reduce((a, b) => a.expandToInclude(b));

  group('selecting in a laid out EPUB', () {
    late EpubLayout layout;
    setUp(() => layout = EpubLayout(book, size));
    tearDown(() => layout.dispose());

    // "Title" is 0..5, "alpha" starts at 5.
    const alpha = 5;

    test('the word under a point, in book characters', () {
      final beta = alpha + 'alpha '.length;
      final box = boxOf(layout, 0, beta, beta + 4);
      final word = layout.wordAt(0, box.center);
      expect(word, TextRange(start: beta, end: beta + 4));
      expect(EpubBookDocument(book).textOf(word!), 'beta');
    });

    test('off the text, nothing; near, the closest character', () {
      expect(layout.offsetAt(0, const Offset(2, 2)), isNull);
      expect(layout.wordAt(0, const Offset(2, 2)), isNull);
      // Far below the last line: its end.
      final end = layout.offsetAt(0, const Offset(398, 590), near: true);
      expect(end, 'Titlealpha beta gamma delta epsilonzeta eta theta'.length);
    });

    test('a range is drawn one box per line, on its own page only', () {
      final rects = layout.rectsOf(0, alpha, alpha + 'alpha beta'.length);
      expect(rects, isNotEmpty);
      for (final r in rects) {
        expect(r.left, greaterThanOrEqualTo(layout.margins.left - 0.5));
        expect(r.top, greaterThanOrEqualTo(layout.margins.top - 0.5));
      }
      // The second chapter is on page 1.
      final second = book.chapters.first.length;
      expect(layout.rectsOf(0, second, second + 6), isEmpty);
      expect(layout.rectsOf(1, second, second + 6), isNotEmpty);
    });

    test('a point on a highlight finds the characters it covers', () {
      final box = boxOf(layout, 0, alpha, alpha + 5);
      final offset = layout.offsetAt(0, box.centerLeft + const Offset(1, 0));
      expect(offset, alpha);
    });
  });

  test('the text of a range spans paragraphs, one per line', () {
    final document = EpubBookDocument(book);
    final start = 'Titlealpha beta gamma delta '.length;
    final end = 'Titlealpha beta gamma delta epsilonzeta'.length;
    expect(document.textOf(TextRange(start: start, end: end)), 'epsilon\nzeta');
  });

  test('a page with marks draws them under the text', () async {
    final document = EpubBookDocument(book);
    document.layout(size, const EpubTypography());
    addTearDown(document.dispose);
    Future<int> yellowish(List<PageMark> marks) async {
      final image = await document.pageImage(
        0,
        size,
        PageColors.plain,
        marks: marks,
      );
      final bytes = (await image.toByteData(
        format: ui.ImageByteFormat.rawStraightRgba,
      ))!;
      image.dispose();
      var count = 0;
      for (var i = 0; i < bytes.lengthInBytes; i += 4) {
        // Red and green well over blue.
        if (bytes.getUint8(i + 3) > 0 &&
            bytes.getUint8(i) > 150 &&
            bytes.getUint8(i + 2) < bytes.getUint8(i) - 30) {
          count++;
        }
      }
      return count;
    }

    expect(await yellowish(const []), 0);
    expect(
      await yellowish([PageMark(5, 15, HighlightColor.yellow.fill)]),
      greaterThan(100),
    );
  });

  test(
    'a voice note button: drawn at the end of its range, there only',
    () async {
      final document = EpubBookDocument(book);
      document.layout(size, const EpubTypography());
      addTearDown(document.dispose);
      // "alpha beta" on page 0; the second chapter is on page 1.
      const alpha = TextRange(start: 5, end: 15);
      final badge = document.badgeOf(0, alpha)!;
      expect(document.badgeOf(1, alpha), isNull);
      // Past the end of "beta", raised over its line.
      final words = document.rectsOf(0, alpha).last;
      expect(badge.center.dx, greaterThan(words.right));
      expect(badge.center.dy, lessThan(words.center.dy));

      Future<int> whiteIn(List<PageMark> marks) async {
        final image = await document.pageImage(
          0,
          size,
          PageColors.plain,
          marks: marks,
        );
        final bytes = (await image.toByteData(
          format: ui.ImageByteFormat.rawStraightRgba,
        ))!;
        final box = Rect.fromLTRB(
          badge.left * image.width,
          badge.top * image.height,
          badge.right * image.width,
          badge.bottom * image.height,
        ).deflate(2);
        var count = 0;
        for (var y = box.top.ceil(); y < box.bottom; y++) {
          for (var x = box.left.ceil(); x < box.right; x++) {
            final i = (y * image.width + x) * 4;
            if (bytes.getUint8(i + 3) > 200 &&
                bytes.getUint8(i) > 230 &&
                bytes.getUint8(i + 1) > 230 &&
                bytes.getUint8(i + 2) > 230) {
              count++;
            }
          }
        }
        image.dispose();
        return count;
      }

      final fill = HighlightColor.blue.fill;
      expect(await whiteIn([PageMark(5, 15, fill)]), 0);
      // The white triangle on the blue disc.
      expect(
        await whiteIn([PageMark(5, 15, fill, badge: PageBadge.play)]),
        greaterThan(10),
      );
    },
  );

  test('a highlight survives JSON; a broken entry is dropped', () {
    final h = Highlight(
      start: 3,
      end: 9,
      color: HighlightColor.blue,
      text: 'words',
      note: 'a thought',
      created: DateTime.utc(2026, 11, 27, 10),
    );
    expect(Highlight.fromJson(h.toJson()), h);
    expect(Highlight.fromJson({'start': 9, 'end': 3}), isNull);
    expect(Highlight.fromJson('nonsense'), isNull);
  });

  test('a voice note survives JSON; a path instead of a name does not', () {
    final h = Highlight(
      start: 1,
      end: 4,
      color: HighlightColor.yellow,
      text: 'w',
      created: DateTime.utc(2026),
      voice: '1764000000000.wav',
      voiceLength: const Duration(milliseconds: 7250),
    );
    expect(Highlight.fromJson(h.toJson()), h);
    for (final bad in ['../secret', '/etc/passwd', '..', '.hidden', 'a/b']) {
      final json = h.toJson()..['voice'] = bad;
      expect(Highlight.fromJson(json)!.hasVoice, isFalse, reason: bad);
    }
    expect(h.copyWith(voice: '').voiceLength, Duration.zero);
  });

  test('raw sound becomes a WAV file that says how it is made', () {
    final pcm = Uint8List(32000); // One second at 16 kHz, 16-bit mono.
    final wav = wavFile(pcm, sampleRate: 16000);
    final data = ByteData.sublistView(wav);
    String ascii(int at) => String.fromCharCodes(wav.sublist(at, at + 4));
    expect(wav.length, 44 + pcm.length);
    expect(ascii(0), 'RIFF');
    expect(data.getUint32(4, Endian.little), 36 + pcm.length);
    expect(ascii(8), 'WAVE');
    expect(data.getUint16(20, Endian.little), 1); // PCM
    expect(data.getUint16(22, Endian.little), 1); // mono
    expect(data.getUint32(24, Endian.little), 16000);
    expect(data.getUint32(28, Endian.little), 32000); // bytes per second
    expect(data.getUint16(34, Endian.little), 16);
    expect(ascii(36), 'data');
    expect(data.getUint32(40, Endian.little), pcm.length);
    expect(
      pcmLength(pcm.length, sampleRate: 16000),
      const Duration(seconds: 1),
    );
  });

  test('highlights are kept per book on this device, in order', () async {
    final store = MemoryKeyValueStore();
    final books = JellyfinBookRepository(
      testSession,
      () async => const ClientInfo(deviceId: 'dev-1', device: 'pc'),
      () async => throw UnimplementedError(),
      store,
      onUnauthorized: () {},
      adapter: FakeAdapter((_) async => throw UnimplementedError()),
    );
    Highlight at(int start) => Highlight(
      start: start,
      end: start + 4,
      color: HighlightColor.red,
      text: 'text',
      created: DateTime.utc(2026),
    );
    expect(await books.highlights('book-epub'), isEmpty);
    await books.saveHighlights('book-epub', [at(40), at(2)]);
    expect(await books.highlights('book-epub'), [at(2), at(40)]);
    expect(await books.highlights('book-other'), isEmpty);
    await books.saveHighlights('book-epub', const []);
    expect(store.values, isEmpty);
  });
}
