/// Turns what the user typed into a base URL, or null when it cannot be one.
///
///   jellyfin:8096                       → http://jellyfin:8096
///   https://media.example.com/          → https://media.example.com
///   http://host:8096/web/#/home.html    → http://host:8096
///   https://example.com/jellyfin/web/   → https://example.com/jellyfin
///
/// The last two are what people copy from the browser's address bar while
/// using jellyfin-web; the base URL is everything before `/web`.
String? normalizeServerUrl(String input) {
  var text = input.trim();
  if (text.isEmpty || text.contains(RegExp(r'\s'))) return null;
  if (!text.contains('://')) text = 'http://$text';

  final uri = Uri.tryParse(text);
  if (uri == null ||
      !(uri.isScheme('http') || uri.isScheme('https')) ||
      uri.host.isEmpty) {
    return null;
  }

  final segments = [...uri.pathSegments.where((s) => s.isNotEmpty)];
  final web = segments.indexOf('web');
  if (web >= 0) segments.removeRange(web, segments.length);

  return Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    pathSegments: segments.isEmpty ? null : segments,
  ).toString();
}
