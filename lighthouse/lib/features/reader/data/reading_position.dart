/// Where the reader is, as the server keeps it: a book's place is a
/// playback position. Jellyfin 12.4 gives a PDF or a comic a length of
/// 10000 ticks per page (an EPUB, 10^7 for the whole book), and works out
/// the "% read" from position ÷ length; positions here are on the same
/// scale, so the server's percentage and other clients agree.
const ticksPerPage = 10000;

/// The position of [page] (0-based) in a book of [pageCount] pages whose
/// length the server gives as [runTimeTicks].
int positionForPage(int page, int pageCount, int? runTimeTicks) {
  if (runTimeTicks == null || runTimeTicks <= 0 || pageCount <= 0) {
    return page * ticksPerPage;
  }
  return (page * runTimeTicks / pageCount).round();
}

/// The page (0-based) a saved [positionTicks] stands for.
int pageForPosition(int positionTicks, int pageCount, int? runTimeTicks) {
  if (pageCount <= 0) return 0;
  final page = runTimeTicks == null || runTimeTicks <= 0
      ? positionTicks ~/ ticksPerPage
      : (positionTicks * pageCount / runTimeTicks).round();
  return page.clamp(0, pageCount - 1);
}

/// The position of [fraction] of a book (see [BookDocument.fractionOf]):
/// for a PDF or a comic the same as [positionForPage] gives for its page;
/// an EPUB's length is 10^7, so its position is the fraction read.
/// Without a length, [pageCount] pages at [ticksPerPage].
int positionForFraction(double fraction, int pageCount, int? runTimeTicks) {
  if (runTimeTicks == null || runTimeTicks <= 0) {
    return (fraction * pageCount).round() * ticksPerPage;
  }
  return (fraction * runTimeTicks).round();
}

/// How far into the book a saved [positionTicks] is, from 0 to 1.
double fractionForPosition(
  int positionTicks,
  int pageCount,
  int? runTimeTicks,
) {
  final fraction = runTimeTicks == null || runTimeTicks <= 0
      ? (pageCount <= 0 ? 0.0 : positionTicks / ticksPerPage / pageCount)
      : positionTicks / runTimeTicks;
  return fraction.clamp(0.0, 1.0);
}
