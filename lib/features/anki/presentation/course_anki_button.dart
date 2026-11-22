import 'package:bahasa_master/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A built-in Anki deck that drills the same material as a course.
class CourseAnkiDeck {
  const CourseAnkiDeck({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;

  /// Deck name without the level, as Indonesian source copy; localized with
  /// `.localized(context)`.
  final String title;
  final String subtitle;
}

/// The built-in decks matching a course and level. The Japanese built-in decks
/// were removed and no default deck set ships yet, so no course has a matching
/// deck and the button stays hidden. The mapping returns when the default
/// Bahasa Master decks arrive (docs/TODO.md, Fase 5 and 6).
List<CourseAnkiDeck> courseAnkiDecks(String type, String level) => const [];

/// App-bar action that opens the Anki deck for the course level, or lets the
/// user pick when several decks match.
class CourseAnkiButton extends StatelessWidget {
  const CourseAnkiButton({required this.type, required this.level, super.key});

  final String type;
  final String level;

  Future<void> _open(BuildContext context, List<CourseAnkiDeck> decks) async {
    if (decks.length == 1) {
      await context.push('/anki/decks/${decks.single.id}');
      return;
    }
    final picked = await showModalBottomSheet<CourseAnkiDeck>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'Pilih deck Anki'.localized(context),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final deck in decks)
              ListTile(
                key: ValueKey('course-anki-deck-${deck.id}'),
                leading: const Icon(Icons.style_outlined),
                title: Text('$level · ${deck.title.localized(context)}'),
                subtitle: Text(deck.subtitle.localized(context)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(context, deck),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null && context.mounted) {
      await context.push('/anki/decks/${picked.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final decks = courseAnkiDecks(type, level);
    if (decks.isEmpty) return const SizedBox.shrink();
    return IconButton(
      key: const ValueKey('course-anki-button'),
      tooltip: 'Latihan kartu Anki'.localized(context),
      icon: const Icon(Icons.style_outlined),
      onPressed: () => _open(context, decks),
    );
  }
}
