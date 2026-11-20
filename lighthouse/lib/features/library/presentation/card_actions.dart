import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../l10n/l10n.dart';
import '../../../router.dart';
import '../application/library_providers.dart';
import 'card_popover.dart';
import 'item_card.dart';

/// What a long press on a card offers on touch, where there is no hover
/// panel (CardPopover): the main action (play, resume, read, episodes),
/// watched or not, and the details page.
class CardActions extends ConsumerStatefulWidget {
  const CardActions({super.key, required this.item});

  final BaseItemDto item;

  static const mainButton = Key('card.actions.main');
  static const watchedButton = Key('card.actions.watched');
  static const detailsButton = Key('card.actions.details');

  /// Whether a long press on [item]'s card opens the sheet: what the hover
  /// panel is for.
  static bool offeredFor(BaseItemDto item) => switch (item.type) {
    BaseItemKind.movie ||
    BaseItemKind.episode ||
    BaseItemKind.series ||
    BaseItemKind.video ||
    BaseItemKind.book => true,
    _ => false,
  };

  static Future<void> show(BuildContext context, BaseItemDto item) =>
      showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        builder: (_) => CardActions(item: item),
      );

  @override
  ConsumerState<CardActions> createState() => _CardActionsState();
}

class _CardActionsState extends ConsumerState<CardActions> {
  bool _saving = false;

  /// The sheet closes, then [route] opens on the page.
  void _go(String route) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    unawaited(router.push(route));
  }

  Future<void> _setWatched({required bool watched}) async {
    setState(() => _saving = true);
    await setWatched(context, ref, widget.item.id, watched: watched);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // The item as the server has it now (its watch state may have changed).
    final item = ref.watch(itemProvider(widget.item.id)).value ?? widget.item;
    final l10n = context.l10n;
    final played = item.userData?.played ?? false;
    final main = cardMainAction(item, l10n);
    final subtitle = cardSubtitle(item, l10n);
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: subtitle == null ? null : Text(subtitle),
          ),
          const Divider(height: 1),
          ListTile(
            key: CardActions.mainButton,
            leading: Icon(main.icon),
            title: Text(main.label),
            onTap: () => _go(main.route),
          ),
          ListTile(
            key: CardActions.watchedButton,
            enabled: !_saving,
            leading: Icon(played ? Icons.remove_done : Icons.check),
            title: Text(played ? l10n.markUnwatched : l10n.markWatched),
            onTap: () => unawaited(_setWatched(watched: !played)),
          ),
          ListTile(
            key: CardActions.detailsButton,
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.details),
            onTap: () => _go(Routes.item(item.id)),
          ),
        ],
      ),
    );
  }
}
