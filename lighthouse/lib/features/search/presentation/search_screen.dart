import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/error_retry.dart';
import '../../home/presentation/home_screen.dart';
import '../../library/data/library_repository.dart';

/// Results for a search term, all kinds together (grouped on screen).
final searchResultsProvider = FutureProvider.autoDispose
    .family<List<BaseItemDto>, String>(
      (ref, term) => ref.watch(libraryRepositoryProvider).search(term),
    );

/// Search across the libraries. Asks the server once typing pauses, and
/// shows the results as rows by kind (Movies, Shows, Episodes...).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  /// Searched for at once (the floating top bar's search field).
  final String initialQuery;

  static const field = Key('search.field');
  static const noResults = Key('search.none');
  static Key row(BaseItemKind kind) => Key('search.${kind.name}');

  /// Typing pause before a request: no request per keystroke.
  static const debounce = Duration(milliseconds: 300);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late String _term = widget.initialQuery.trim();
  late final _text = TextEditingController(text: widget.initialQuery);
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _changed(String text) {
    _debounce?.cancel();
    _debounce = Timer(SearchScreen.debounce, () {
      if (mounted) setState(() => _term = text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          key: SearchScreen.field,
          controller: _text,
          autofocus: true,
          decoration: InputDecoration(
            hintText: context.l10n.searchHint,
            border: InputBorder.none,
          ),
          onChanged: _changed,
          onSubmitted: (text) {
            _debounce?.cancel();
            setState(() => _term = text.trim());
          },
        ),
      ),
      body: _term.isEmpty
          ? const SizedBox.shrink()
          : switch (ref.watch(searchResultsProvider(_term))) {
              AsyncData(value: final items) when items.isEmpty => Center(
                child: Text(
                  context.l10n.nothingFound(_term),
                  key: SearchScreen.noResults,
                ),
              ),
              // Clear of a notch at the sides.
              AsyncData(value: final items) => SafeArea(
                top: false,
                bottom: false,
                child: _Results(items: items),
              ),
              AsyncError(:final error) => Center(
                child: ErrorRetry(
                  error: error,
                  onRetry: () => ref.invalidate(searchResultsProvider(_term)),
                ),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.items});

  final List<BaseItemDto> items;

  static String _title(BaseItemKind kind, AppLocalizations l10n) =>
      switch (kind) {
        BaseItemKind.movie => l10n.movies,
        BaseItemKind.series => l10n.shows,
        BaseItemKind.episode => l10n.episodes,
        BaseItemKind.musicAlbum => l10n.albums,
        BaseItemKind.audio => l10n.songs,
        _ => l10n.books,
      };

  @override
  Widget build(BuildContext context) => ListView(
    // Scrolls past the gesture bar.
    padding: EdgeInsets.only(
      top: 16,
      bottom: 16 + MediaQuery.paddingOf(context).bottom,
    ),
    children: [
      for (final kind in searchKinds)
        if (items.where((i) => i.type == kind).toList() case final group
            when group.isNotEmpty)
          ItemRow(
            key: SearchScreen.row(kind),
            title: _title(kind, context.l10n),
            items: AsyncData(group),
            cardWidth: kind == BaseItemKind.episode ? 240 : 140,
          ),
    ],
  );
}
