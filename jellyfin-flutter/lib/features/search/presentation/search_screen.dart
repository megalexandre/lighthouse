import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
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
          decoration: const InputDecoration(
            hintText: 'Search movies, shows, music',
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
                  'Nothing found for "$_term".',
                  key: SearchScreen.noResults,
                ),
              ),
              AsyncData(value: final items) => _Results(items: items),
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

  static const _titles = {
    BaseItemKind.movie: 'Movies',
    BaseItemKind.series: 'Shows',
    BaseItemKind.episode: 'Episodes',
    BaseItemKind.musicAlbum: 'Albums',
    BaseItemKind.audio: 'Songs',
    BaseItemKind.book: 'Books',
  };

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.symmetric(vertical: 16),
    children: [
      for (final kind in searchKinds)
        if (items.where((i) => i.type == kind).toList() case final group
            when group.isNotEmpty)
          ItemRow(
            key: SearchScreen.row(kind),
            title: _titles[kind]!,
            items: AsyncData(group),
            cardWidth: kind == BaseItemKind.episode ? 240 : 140,
          ),
    ],
  );
}
