import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:xml/xml.dart';

/// An EPUB's content, ready to lay out: its chapters in reading order, each
/// a list of blocks, and the images they show. Plain data, so it can be
/// built in another isolate and sent back.
///
/// Only what reads well as a paged book is kept: paragraphs, headings,
/// quotes, lists, preformatted text, images, rules, and bold / italic /
/// monospace inside text. Publisher CSS is left out (text-align: center
/// excepted): the reader sets the type.
class EpubBook {
  EpubBook({
    this.title,
    required this.chapters,
    required this.images,
    this.toc = const [],
  });

  final String? title;
  final List<EpubChapter> chapters;

  /// Encoded images (PNG, JPEG...), by their path in the zip.
  final Map<String, Uint8List> images;

  /// The table of contents, as the book gives it (its nav document, or
  /// the EPUB 2 NCX); empty when it has none.
  final List<EpubTocEntry> toc;

  /// Characters in the whole book, as [offsetOf] counts them.
  late final int length = chapters.fold(0, (sum, c) => sum + c.length);

  /// Where [target] ("path/in/zip.xhtml#fragment", the fragment optional)
  /// starts, in characters from the start of the book (see
  /// [EpubBlock.length]); null when it is not in a chapter shown. A
  /// fragment not found means the start of its chapter.
  int? offsetOf(String target) {
    final hash = target.indexOf('#');
    final path = hash < 0 ? target : target.substring(0, hash);
    final fragment = hash < 0 ? null : target.substring(hash + 1);
    var start = 0;
    for (final chapter in chapters) {
      if (chapter.path == path) {
        final block = chapter.anchors[fragment] ?? 0;
        for (var i = 0; i < block && i < chapter.blocks.length; i++) {
          start += chapter.blocks[i].length;
        }
        return start;
      }
      start += chapter.length;
    }
    return null;
  }

  /// Reads the EPUB in [zip]. Throws [FormatException] when it is not one
  /// (no container, no package, no readable chapter).
  factory EpubBook.read(Archive zip) {
    final container = _text(zip, 'META-INF/container.xml');
    if (container == null) throw const FormatException('no container.xml');
    final opfPath = XmlDocument.parse(container)
        .findAllElements('rootfile', namespaceUri: '*')
        .map((e) => e.getAttribute('full-path'))
        .nonNulls
        .firstOrNull;
    final opfText = opfPath == null ? null : _text(zip, opfPath);
    if (opfPath == null || opfText == null) {
      throw const FormatException('no package document');
    }
    final opf = XmlDocument.parse(opfText);
    final base = _directory(opfPath);

    final manifest = <String, ({String path, String type, String props})>{
      for (final item in opf.findAllElements('item', namespaceUri: '*'))
        if (item.getAttribute('id') case final id?)
          if (item.getAttribute('href') case final href?)
            id: (
              path: _resolve(base, href),
              type: item.getAttribute('media-type') ?? '',
              props: item.getAttribute('properties') ?? '',
            ),
    };
    final title = opf
        .findAllElements('title', namespaceUri: '*')
        .map((e) => e.innerText.trim())
        .where((t) => t.isNotEmpty)
        .firstOrNull;

    final images = <String, Uint8List>{};
    final chapters = <EpubChapter>[];
    for (final ref in opf.findAllElements('itemref', namespaceUri: '*')) {
      if (ref.getAttribute('linear') == 'no') continue;
      final item = manifest[ref.getAttribute('idref')];
      if (item == null || !item.type.contains('html')) continue;
      final source = _text(zip, item.path);
      if (source == null) continue;
      final read = readChapter(source, item.path);
      for (final block in read.blocks) {
        if (block is ImageBlock && !images.containsKey(block.path)) {
          final bytes = zip.findFile(block.path)?.content;
          if (bytes != null) images[block.path] = bytes;
        }
      }
      // Images missing from the zip are left out; anchors move with the
      // blocks after them.
      final shown = <EpubBlock>[];
      final newIndex = <int>[];
      for (final b in read.blocks) {
        newIndex.add(shown.length);
        if (b is! ImageBlock || images.containsKey(b.path)) shown.add(b);
      }
      newIndex.add(shown.length);
      if (shown.isNotEmpty) {
        chapters.add(
          EpubChapter(
            path: item.path,
            blocks: shown,
            anchors: {
              for (final MapEntry(:key, :value) in read.anchors.entries)
                key: newIndex[value],
            },
          ),
        );
      }
    }
    if (chapters.isEmpty) throw const FormatException('no readable chapter');

    List<EpubTocEntry> toc = const [];
    try {
      final nav = manifest.values
          .where((i) => i.props.split(' ').contains('nav'))
          .firstOrNull;
      if (nav != null) {
        if (_text(zip, nav.path) case final source?) {
          toc = navToc(source, nav.path);
        }
      }
      if (toc.isEmpty) {
        final spineToc = opf
            .findAllElements('spine', namespaceUri: '*')
            .firstOrNull
            ?.getAttribute('toc');
        final ncx =
            manifest[spineToc] ??
            manifest.values
                .where((i) => i.type == 'application/x-dtbncx+xml')
                .firstOrNull;
        if (ncx != null) {
          if (_text(zip, ncx.path) case final source?) {
            toc = ncxToc(source, ncx.path);
          }
        }
      }
    } on FormatException {
      toc = const []; // A broken table of contents: the book still reads.
    }
    return EpubBook(title: title, chapters: chapters, images: images, toc: toc);
  }
}

class EpubChapter {
  const EpubChapter({
    required this.path,
    required this.blocks,
    this.anchors = const {},
  });

  final String path;
  final List<EpubBlock> blocks;

  /// Element ids (link targets) by the index of the block they start at.
  final Map<String, int> anchors;

  int get length => blocks.fold(0, (sum, b) => sum + b.length);
}

/// One line of the table of contents: [target] is "path/in/zip#fragment"
/// (the fragment optional), [depth] 0 for the top level.
class EpubTocEntry {
  const EpubTocEntry(this.title, this.target, {this.depth = 0});

  final String title;
  final String target;
  final int depth;

  @override
  String toString() => '${'  ' * depth}$title -> $target';
}

sealed class EpubBlock {
  const EpubBlock();

  /// The characters it counts for where a place in the book is told (see
  /// [EpubBook.offsetOf]): its text, 1 for an image, 0 for a rule.
  int get length;
}

enum TextKind { paragraph, heading, quote, listItem, preformatted }

/// A run of text laid out as one paragraph.
final class TextBlock extends EpubBlock {
  const TextBlock(
    this.runs, {
    this.kind = TextKind.paragraph,
    this.level = 0,
    this.centered = false,
    this.indent = 0,
    this.marker,
  });

  final List<TextRun> runs;
  final TextKind kind;

  /// Heading level, 1 to 6 (0 for other kinds).
  final int level;
  final bool centered;

  /// How deep in quotes and lists (each level indents the text).
  final int indent;

  /// A list item's bullet or number ("•", "3.").
  final String? marker;

  String get text => runs.map((r) => r.text).join();

  @override
  int get length => text.length;
}

/// Text in one style.
final class TextRun {
  const TextRun(
    this.text, {
    this.bold = false,
    this.italic = false,
    this.mono = false,
    this.href,
  });

  final String text;
  final bool bold;
  final bool italic;
  final bool mono;

  /// Where the text links to, inside the book ("path/in/zip#fragment");
  /// links out of it (web pages) are not kept.
  final String? href;

  @override
  String toString() => [
    if (bold) 'b',
    if (italic) 'i',
    if (mono) 'm',
    if (href != null) 'link $href',
    '"$text"',
  ].join(':');
}

/// An image on its own line ([path]: its path in the zip).
final class ImageBlock extends EpubBlock {
  const ImageBlock(this.path);

  final String path;

  @override
  int get length => 1;
}

/// A horizontal rule (a scene break).
final class RuleBlock extends EpubBlock {
  const RuleBlock();

  @override
  int get length => 0;
}

/// The blocks of a chapter's (X)HTML [source], at [path] in the zip (image
/// paths and links are relative to its folder). Parsed as a browser
/// would: unclosed tags and stray markup do not stop it.
List<EpubBlock> chapterBlocks(String source, String path) =>
    readChapter(source, path).blocks;

/// The chapter at [path], [source] its (X)HTML: its blocks, and where its
/// ids are.
EpubChapter readChapter(String source, String path) {
  final body = html.parse(source).body;
  if (body == null) return EpubChapter(path: path, blocks: const []);
  final builder = _BlockBuilder(path);
  builder.walk(body, const _Style());
  builder.flush(const _Style());
  return EpubChapter(
    path: path,
    blocks: builder.blocks,
    anchors: builder.anchors,
  );
}

/// The table of contents in an EPUB 3 nav document ([source], at [path]):
/// its `<nav epub:type="toc">` (or its first nav), list in list.
List<EpubTocEntry> navToc(String source, String path) {
  final document = html.parse(source);
  final navs = document.getElementsByTagName('nav');
  final nav =
      navs
          .where((n) => (n.attributes['epub:type'] ?? '').contains('toc'))
          .firstOrNull ??
      navs.firstOrNull;
  final list = nav?.children.where((e) => e.localName == 'ol').firstOrNull;
  if (list == null) return const [];
  final base = _directory(path);
  final entries = <EpubTocEntry>[];
  void walk(dom.Element ol, int depth) {
    for (final li in ol.children.where((e) => e.localName == 'li')) {
      final label = li.children
          .where((e) => e.localName == 'a' || e.localName == 'span')
          .firstOrNull;
      final title = _collapse(label?.text ?? '');
      final href = label?.attributes['href'];
      if (title.isNotEmpty && href != null && !_external(href)) {
        entries.add(
          EpubTocEntry(title, _target(base, path, href), depth: depth),
        );
      }
      for (final inner in li.children.where((e) => e.localName == 'ol')) {
        walk(inner, depth + 1);
      }
    }
  }

  walk(list, 0);
  return entries;
}

/// The table of contents in an EPUB 2 NCX ([source], at [path]).
List<EpubTocEntry> ncxToc(String source, String path) {
  final XmlDocument document;
  try {
    document = XmlDocument.parse(source);
  } on XmlException catch (e) {
    throw FormatException('NCX: ${e.message}');
  }
  final map = document.findAllElements('navMap', namespaceUri: '*').firstOrNull;
  if (map == null) return const [];
  final base = _directory(path);
  final entries = <EpubTocEntry>[];
  void walk(XmlElement parent, int depth) {
    for (final point in parent.childElements.where(
      (e) => e.localName == 'navPoint',
    )) {
      final title = _collapse(
        point
                .findElements('navLabel', namespaceUri: '*')
                .firstOrNull
                ?.innerText ??
            '',
      );
      final src = point
          .findElements('content', namespaceUri: '*')
          .firstOrNull
          ?.getAttribute('src');
      if (title.isNotEmpty && src != null && !_external(src)) {
        entries.add(
          EpubTocEntry(title, _target(base, path, src), depth: depth),
        );
      }
      walk(point, depth + 1);
    }
  }

  walk(map, 0);
  return entries;
}

String _collapse(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();

/// A link out of the book (a web page, an e-mail address).
bool _external(String href) =>
    RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:').hasMatch(href);

/// [href], found in the file at [path] (folder [base]), as a target in the
/// zip: "path#fragment" (fragment only when there is one).
String _target(String base, String path, String href) {
  final hash = href.indexOf('#');
  final file = hash < 0 ? href : href.substring(0, hash);
  final fragment = hash < 0 ? '' : href.substring(hash + 1);
  final resolved = file.isEmpty ? path : _resolve(base, file);
  return fragment.isEmpty ? resolved : '$resolved#$fragment';
}

/// The inherited style while walking the tree.
class _Style {
  const _Style({
    this.bold = false,
    this.italic = false,
    this.mono = false,
    this.pre = false,
    this.centered = false,
    this.kind = TextKind.paragraph,
    this.level = 0,
    this.indent = 0,
    this.marker,
    this.href,
  });

  final bool bold;
  final bool italic;
  final bool mono;
  final bool pre;
  final bool centered;
  final TextKind kind;
  final int level;
  final int indent;
  final String? marker;
  final String? href;

  _Style copyWith({
    bool? bold,
    bool? italic,
    bool? mono,
    bool? pre,
    bool? centered,
    TextKind? kind,
    int? level,
    int? indent,
    String? Function()? marker,
    String? href,
  }) => _Style(
    bold: bold ?? this.bold,
    italic: italic ?? this.italic,
    mono: mono ?? this.mono,
    pre: pre ?? this.pre,
    centered: centered ?? this.centered,
    kind: kind ?? this.kind,
    level: level ?? this.level,
    indent: indent ?? this.indent,
    marker: marker == null ? this.marker : marker(),
    href: href ?? this.href,
  );
}

const _skipped = {'head', 'script', 'style', 'title', 'template', 'noscript'};

const _blockTags = {
  'p', 'div', 'section', 'article', 'header', 'footer', 'main', 'aside', //
  'nav', 'figure', 'figcaption', 'address', 'dl', 'dt', 'dd', 'table',
  'thead', 'tbody', 'tfoot', 'tr', 'td', 'th', 'caption', 'center', 'body',
  'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'blockquote', 'pre', 'ul', 'ol', 'li',
};

class _BlockBuilder {
  _BlockBuilder(this.path) : base = _directory(path);

  /// The chapter's path, and its folder.
  final String path;
  final String base;
  final blocks = <EpubBlock>[];
  final anchors = <String, int>{};
  final _runs = <TextRun>[];

  /// The block style of the text gathered in [_runs].
  _Style? _blockStyle;

  void walk(dom.Node node, _Style style) {
    for (final child in node.nodes) {
      switch (child) {
        case dom.Text(:final data):
          _addText(data, style);
        case dom.Element():
          _element(child, style);
      }
    }
  }

  void _element(dom.Element e, _Style style) {
    final tag = e.localName?.toLowerCase() ?? '';
    if (_skipped.contains(tag) || e.attributes['hidden'] != null) return;
    switch (tag) {
      case 'br':
        _addText('\n', style.copyWith(pre: true));
        return;
      case 'hr':
        flush(style);
        blocks.add(const RuleBlock());
        return;
      case 'img' || 'image':
        final src =
            e.attributes['src'] ??
            e.attributes['xlink:href'] ??
            e.attributes['href'];
        if (src != null && !src.startsWith('data:')) {
          flush(style);
          blocks.add(ImageBlock(_resolve(base, src)));
        }
        return;
    }

    final id = e.attributes['id'] ?? (tag == 'a' ? e.attributes['name'] : null);

    var inner = style;
    if (tag == 'a') {
      if (e.attributes['href'] case final href? when !_external(href)) {
        inner = inner.copyWith(href: _target(base, path, href));
      }
    }
    final css = (e.attributes['style'] ?? '').replaceAll(' ', '').toLowerCase();
    final classes = (e.attributes['class'] ?? '').toLowerCase();
    if (tag == 'center' ||
        css.contains('text-align:center') ||
        RegExp(r'\b(center|centered|centre)\b').hasMatch(classes)) {
      inner = inner.copyWith(centered: true);
    }
    if (css.contains('font-style:italic')) inner = inner.copyWith(italic: true);
    if (css.contains('font-weight:bold')) inner = inner.copyWith(bold: true);

    switch (tag) {
      case 'b' || 'strong':
        inner = inner.copyWith(bold: true);
      case 'i' || 'em' || 'cite' || 'dfn' || 'var':
        inner = inner.copyWith(italic: true);
      case 'code' || 'kbd' || 'samp' || 'tt':
        inner = inner.copyWith(mono: true);
      case 'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6':
        inner = inner.copyWith(
          kind: TextKind.heading,
          level: int.parse(tag.substring(1)),
          bold: true,
        );
      case 'blockquote':
        inner = inner.copyWith(kind: TextKind.quote, indent: style.indent + 1);
      case 'pre':
        inner = inner.copyWith(
          kind: TextKind.preformatted,
          pre: true,
          mono: true,
        );
      case 'ul' || 'ol':
        inner = inner.copyWith(indent: style.indent + 1);
    }

    if (!_blockTags.contains(tag)) {
      // Inside a paragraph: it starts with the paragraph (the next block).
      if (id != null) anchors.putIfAbsent(id, () => blocks.length);
      walk(e, inner);
      return;
    }
    flush(style);
    if (id != null) anchors.putIfAbsent(id, () => blocks.length);
    if (tag == 'ul' || tag == 'ol') {
      var number = int.tryParse(e.attributes['start'] ?? '') ?? 1;
      for (final child in e.nodes) {
        if (child is dom.Element && child.localName == 'li') {
          final marker = tag == 'ol' ? '${number++}.' : '•';
          _element(
            child,
            inner.copyWith(kind: TextKind.listItem, marker: () => marker),
          );
        } else {
          walk(dom.DocumentFragment()..append(child.clone(true)), inner);
        }
      }
    } else {
      walk(e, inner);
    }
    flush(inner);
  }

  void _addText(String data, _Style style) {
    var text = data;
    if (!style.pre) {
      text = text.replaceAll(RegExp(r'\s+'), ' ');
      // One space between words, whatever the markup between them.
      final last = _runs.lastOrNull?.text;
      if (text.startsWith(' ') &&
          (last == null || last.endsWith(' ') || last.endsWith('\n'))) {
        text = text.substring(1);
      }
    }
    if (text.isEmpty) return;
    _blockStyle ??= style;
    _runs.add(
      TextRun(
        text,
        bold: style.bold,
        italic: style.italic,
        mono: style.mono,
        href: style.href,
      ),
    );
  }

  /// Ends the paragraph gathered so far.
  void flush(_Style style) {
    if (_runs.isEmpty) return;
    final block = _blockStyle ?? style;
    final runs = [..._runs];
    _runs.clear();
    _blockStyle = null;
    // No space or line break at either end of a paragraph.
    while (runs.isNotEmpty) {
      final trimmed = runs.first.text.trimLeft();
      if (trimmed.isNotEmpty) {
        runs.first = _withText(runs.first, trimmed);
        break;
      }
      runs.removeAt(0);
    }
    while (runs.isNotEmpty) {
      final trimmed = runs.last.text.trimRight();
      if (trimmed.isNotEmpty) {
        runs.last = _withText(runs.last, trimmed);
        break;
      }
      runs.removeLast();
    }
    if (runs.isEmpty) return;
    blocks.add(
      TextBlock(
        runs,
        kind: block.kind,
        level: block.level,
        centered: block.centered,
        indent: block.indent,
        marker: block.marker,
      ),
    );
  }

  TextRun _withText(TextRun r, String text) =>
      TextRun(text, bold: r.bold, italic: r.italic, mono: r.mono, href: r.href);
}

String? _text(Archive zip, String path) {
  final file = zip.findFile(path);
  if (file == null) return null;
  return utf8.decode(file.content, allowMalformed: true);
}

String _directory(String path) {
  final slash = path.lastIndexOf('/');
  return slash < 0 ? '' : path.substring(0, slash + 1);
}

/// [href] (relative, maybe %-encoded, maybe with a #fragment) as a path in
/// the zip, from the folder [base].
String _resolve(String base, String href) {
  var path = href.split('#').first.split('?').first;
  try {
    path = Uri.decodeFull(path);
  } on ArgumentError {
    // Not %-encoded after all.
  }
  final parts = <String>[];
  for (final part in (path.startsWith('/') ? path : '$base$path').split('/')) {
    if (part.isEmpty || part == '.') continue;
    if (part == '..') {
      if (parts.isNotEmpty) parts.removeLast();
    } else {
      parts.add(part);
    }
  }
  return parts.join('/');
}
