/// Jellyfin's own ports, for an address typed without one.
const defaultJellyfinHttpPort = 8096;
const defaultJellyfinHttpsPort = 8920;

/// The base URLs to try, best first, for what the user typed; empty when it
/// cannot be an address.
///
///   fedora.local              → https://fedora.local, http://fedora.local,
///                               https://fedora.local:8920,
///                               http://fedora.local:8096
///   fedora.local:8096         → https://fedora.local:8096,
///                               http://fedora.local:8096
///   http://fedora.local       → http://fedora.local, http://fedora.local:8096
///   http://fedora.local:8096  → http://fedora.local:8096
///   https://example.com/jellyfin/web/
///                             → https://example.com/jellyfin,
///                               https://example.com:8920/jellyfin
///
/// Without a scheme, https comes before http so a server that offers both is
/// reached securely. Without a port, the scheme's own (a reverse proxy on 443
/// or 80) comes before Jellyfin's. What the user wrote is kept: a scheme
/// written is the only one tried, and so is a port.
/// The base URL is everything before the last `/web`, so what people copy
/// from the browser's address bar while using jellyfin-web works too, even
/// behind a proxy whose own path has a `web` in it.
List<String> serverUrlCandidates(String input) {
  var text = input.trim();
  if (text.isEmpty || text.contains(RegExp(r'\s'))) return const [];
  final bare = !text.contains('://');
  if (bare) text = 'http://$text';

  final uri = Uri.tryParse(text);
  if (uri == null ||
      !(uri.isScheme('http') || uri.isScheme('https')) ||
      uri.host.isEmpty) {
    return const [];
  }

  final segments = [...uri.pathSegments.where((s) => s.isNotEmpty)];
  final web = segments.lastIndexOf('web');
  if (web >= 0) segments.removeRange(web, segments.length);

  String url(String scheme, int? port) => Uri(
    scheme: scheme,
    host: uri.host,
    port: port,
    pathSegments: segments.isEmpty ? null : segments,
  ).toString();

  final schemes = bare ? ['https', 'http'] : [uri.scheme];
  if (uri.hasPort) return [for (final s in schemes) url(s, uri.port)];
  return [
    for (final s in schemes) url(s, null),
    for (final s in schemes)
      url(s, s == 'https' ? defaultJellyfinHttpsPort : defaultJellyfinHttpPort),
  ];
}
