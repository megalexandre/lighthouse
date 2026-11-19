/// Image kinds the app shows.
enum ImageType {
  primary('Primary'),
  backdrop('Backdrop'),
  thumb('Thumb');

  const ImageType(this.jsonValue);
  final String jsonValue;
}

/// URL of an item's image, scaled by the server to at most [maxWidth]
/// pixels. The server serves images without a token, so the URL works in a
/// plain `Image.network`. [tag] (from the item's ImageTags) changes when the
/// image does, which keeps HTTP caches correct.
Uri itemImageUrl(
  String baseUrl,
  String itemId,
  ImageType type, {
  String? tag,
  int? maxWidth,
}) {
  final base = Uri.parse(baseUrl);
  return base.replace(
    path: '${base.path}/Items/$itemId/Images/${type.jsonValue}',
    queryParameters: {
      'tag': ?tag,
      if (maxWidth != null) 'maxWidth': '$maxWidth',
      'quality': '90',
    },
  );
}
