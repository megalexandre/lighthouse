/// Jellyfin's own port, for an address typed without one.
const defaultJellyfinPort = 8096;

/// Turns what the user typed into a base URL, or null when it cannot be one.
///
///   fedora.local                        → http://fedora.local:8096
///   jellyfin:8096                       → http://jellyfin:8096
///   http://fedora.local                 → http://fedora.local
///   https://media.example.com/          → https://media.example.com
///   http://host:8096/web/#/home.html    → http://host:8096
///   https://example.com/jellyfin/web/   → https://example.com/jellyfin
///
/// A bare host name is a server on the local network: http, on Jellyfin's
/// port. With a scheme written, the port is the scheme's (a server behind
/// a reverse proxy, on 80 or 443). The last two are what people copy from
/// the browser's address bar while using jellyfin-web; the base URL is
/// everything before `/web`.
String? normalizeServerUrl(String input) {
  var text = input.trim();
  if (text.isEmpty || text.contains(RegExp(r'\s'))) return null;
  final bare = !text.contains('://');
  if (bare) text = 'http://$text';

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
    port: uri.hasPort
        ? uri.port
        : bare
        ? defaultJellyfinPort
        : null,
    pathSegments: segments.isEmpty ? null : segments,
  ).toString();
}
