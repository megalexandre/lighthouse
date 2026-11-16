#!/usr/bin/env python3
"""Writes the test books into fixtures/media/books (called by gen_fixtures.sh).

Pure standard library and byte-for-byte reproducible (fixed zip dates, no
timestamps), like the rest of the fixtures:

  books/Test Author/Test Book/Test Book.pdf      5 pages, "Page 1".."Page 5"
  books/Test Author/Test Comic/Test Comic.cbz    5 PNG pages
  books/Test Author/Test Novel/Test Novel.epub   3 chapters (EPUB 3)

Each page of the PDF and the comic is told apart by its colour and by a
row of dots, one per page number, so a test can check which page shows.
"""

import pathlib
import struct
import sys
import zipfile
import zlib

PAGES = 5

# (r, g, b) background of page n (1-based); dots are white.
COLOURS = [
    (0xAA, 0x5C, 0xC3),
    (0x00, 0xA4, 0xDC),
    (0x33, 0x99, 0x33),
    (0xDD, 0x88, 0x00),
    (0xCC, 0x33, 0x33),
]

FIXED_DATE = (2020, 1, 1, 0, 0, 0)


def png(width, height, page):
    """An RGB PNG: the page colour with `page` white dots along the top."""
    bg = COLOURS[page - 1]
    dot, gap, top = 12, 8, 20
    rows = []
    for y in range(height):
        row = bytearray([0])  # filter: none
        for x in range(width):
            in_dot = (
                top <= y < top + dot
                and x >= gap
                and (x - gap) % (dot + gap) < dot
                and (x - gap) // (dot + gap) < page
            )
            row += bytes((255, 255, 255) if in_dot else bg)
        rows.append(bytes(row))

    def chunk(kind, data):
        body = kind + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body))

    header = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", header)
        + chunk(b"IDAT", zlib.compress(b"".join(rows), 9))
        + chunk(b"IEND", b"")
    )


def write_zip(path, files, stored=()):
    """A zip with fixed dates; names in `stored` are not compressed."""
    with zipfile.ZipFile(path, "w") as z:
        for name, data in files:
            info = zipfile.ZipInfo(name, date_time=FIXED_DATE)
            info.compress_type = (
                zipfile.ZIP_STORED if name in stored else zipfile.ZIP_DEFLATED
            )
            info.external_attr = 0o644 << 16
            z.writestr(info, data)


def pdf(path):
    """A 5-page PDF, A5 portrait, each page coloured with its number."""
    objects = []

    def add(body):
        objects.append(body)
        return len(objects)

    catalog = add(None)
    pages = add(None)
    font = add(b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>")
    kids = []
    for n in range(1, PAGES + 1):
        r, g, b = (c / 255 for c in COLOURS[n - 1])
        dots = "".join(
            f"1 1 1 rg {20 + i * 20} 560 12 12 re f\n" for i in range(n)
        )
        content = (
            f"{r:.3f} {g:.3f} {b:.3f} rg 0 0 420 595 re f\n{dots}"
            f"BT /F1 36 Tf 1 1 1 rg 140 300 Td (Page {n}) Tj ET\n"
        ).encode()
        stream = add(
            b"<< /Length %d >>\nstream\n" % len(content) + content + b"endstream"
        )
        kids.append(
            add(
                b"<< /Type /Page /Parent %d 0 R /MediaBox [0 0 420 595] "
                b"/Resources << /Font << /F1 %d 0 R >> >> /Contents %d 0 R >>"
                % (pages, font, stream)
            )
        )
    objects[catalog - 1] = b"<< /Type /Catalog /Pages %d 0 R >>" % pages
    objects[pages - 1] = b"<< /Type /Pages /Kids [%s] /Count %d >>" % (
        b" ".join(b"%d 0 R" % k for k in kids),
        len(kids),
    )

    out = bytearray(b"%PDF-1.4\n")
    offsets = []
    for i, body in enumerate(objects, 1):
        offsets.append(len(out))
        out += b"%d 0 obj\n" % i + body + b"\nendobj\n"
    xref = len(out)
    out += b"xref\n0 %d\n0000000000 65535 f \n" % (len(objects) + 1)
    for offset in offsets:
        out += b"%010d 00000 n \n" % offset
    out += (
        b"trailer\n<< /Size %d /Root %d 0 R /Info << /Title (Test Book) "
        b"/Author (Test Author) >> >>\nstartxref\n%d\n%%%%EOF\n"
        % (len(objects) + 1, catalog, xref)
    )
    path.write_bytes(bytes(out))


def comic(path):
    write_zip(
        path,
        [(f"{n:02d}.png", png(300, 450, n)) for n in range(1, PAGES + 1)],
    )


def epub(path):
    chapters = [
        ("Chapter One", "The first chapter of the test novel."),
        ("Chapter Two", "The second chapter, with a little more text."),
        ("Chapter Three", "The last chapter. The end."),
    ]
    xhtml = [
        (
            f"chapter{i}.xhtml",
            (
                '<?xml version="1.0" encoding="utf-8"?>\n'
                '<html xmlns="http://www.w3.org/1999/xhtml"><head>'
                f"<title>{title}</title></head><body>"
                f"<h1>{title}</h1><p>{text}</p></body></html>\n"
            ).encode(),
        )
        for i, (title, text) in enumerate(chapters, 1)
    ]
    manifest = "".join(
        f'<item id="c{i}" href="{name}" media-type="application/xhtml+xml"/>'
        for i, (name, _) in enumerate(xhtml, 1)
    )
    spine = "".join(f'<itemref idref="c{i}"/>' for i in range(1, len(xhtml) + 1))
    nav_items = "".join(
        f'<li><a href="chapter{i}.xhtml">{title}</a></li>'
        for i, (title, _) in enumerate(chapters, 1)
    )
    opf = (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<package xmlns="http://www.idpf.org/2007/opf" version="3.0" '
        'unique-identifier="id"><metadata '
        'xmlns:dc="http://purl.org/dc/elements/1.1/">'
        '<dc:identifier id="id">urn:uuid:00000000-0000-4000-8000-000000000001'
        "</dc:identifier><dc:title>Test Novel</dc:title>"
        "<dc:creator>Test Author</dc:creator><dc:language>en</dc:language>"
        '<meta property="dcterms:modified">2020-01-01T00:00:00Z</meta>'
        '<meta name="cover" content="cover"/>'
        "</metadata><manifest>"
        '<item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" '
        'properties="nav"/>'
        '<item id="cover" href="cover.png" media-type="image/png" '
        'properties="cover-image"/>'
        f"{manifest}</manifest><spine>{spine}</spine></package>\n"
    )
    nav = (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<html xmlns="http://www.w3.org/1999/xhtml" '
        'xmlns:epub="http://www.idpf.org/2007/ops"><head><title>Contents'
        '</title></head><body><nav epub:type="toc"><ol>'
        f"{nav_items}</ol></nav></body></html>\n"
    )
    container = (
        '<?xml version="1.0"?>\n'
        '<container version="1.0" '
        'xmlns="urn:oasis:names:tc:opendocument:xmlns:container">'
        '<rootfiles><rootfile full-path="OEBPS/content.opf" '
        'media-type="application/oebps-package+xml"/></rootfiles>'
        "</container>\n"
    )
    write_zip(
        path,
        [
            ("mimetype", b"application/epub+zip"),
            ("META-INF/container.xml", container.encode()),
            ("OEBPS/content.opf", opf.encode()),
            ("OEBPS/nav.xhtml", nav.encode()),
            ("OEBPS/cover.png", png(200, 300, 1)),
            *[(f"OEBPS/{name}", data) for name, data in xhtml],
        ],
        stored={"mimetype"},
    )


def main(root):
    author = pathlib.Path(root) / "Test Author"
    for title, write, ext in [
        ("Test Book", pdf, "pdf"),
        ("Test Comic", comic, "cbz"),
        ("Test Novel", epub, "epub"),
    ]:
        folder = author / title
        folder.mkdir(parents=True, exist_ok=True)
        write(folder / f"{title}.{ext}")


if __name__ == "__main__":
    main(sys.argv[1])
