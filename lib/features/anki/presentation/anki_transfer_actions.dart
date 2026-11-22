import 'package:bahasa_master/features/anki/data/anki_repository.dart';
import 'package:bahasa_master/features/anki/data/anki_transfer_repository.dart';
import 'package:bahasa_master/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart' hide XFile;

class AnkiExportButton extends ConsumerStatefulWidget {
  const AnkiExportButton({required this.deckId, super.key});
  final String deckId;
  @override
  ConsumerState<AnkiExportButton> createState() => _ExportState();
}

class _ExportState extends ConsumerState<AnkiExportButton> {
  bool _busy = false;
  final _cancel = CancelToken();
  @override
  void dispose() {
    _cancel.cancel();
    super.dispose();
  }

  Future<void> _export() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      await context.push('/login');
      return;
    }
    final format = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                context.l10n.ankiExportDeck,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final entry in {
              'apkg': context.l10n.ankiExportFormatApkg,
              'csv': context.l10n.ankiExportFormatCsv,
              'json': context.l10n.ankiExportFormatJson,
            }.entries)
              ListTile(
                leading: const Icon(Icons.file_download_outlined),
                title: Text(entry.value),
                onTap: () => Navigator.pop(context, entry.key),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(context.l10n.ankiExportIncludes),
            ),
          ],
        ),
      ),
    );
    if (format == null ||
        !mounted ||
        ref.read(authControllerProvider).user?.id != user.id) {
      return;
    }
    setState(() => _busy = true);
    try {
      final bytes = await ref
          .read(ankiTransferRepositoryProvider)
          .export(widget.deckId, format, cancelToken: _cancel);
      if (!mounted || ref.read(authControllerProvider).user?.id != user.id) {
        return;
      }
      final name = 'bahasa-deck-${widget.deckId}.$format';
      await saveAnkiExport(context, bytes, name, format);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is AnkiTransferFailure
                  ? error.message
                  : context.l10n.ankiExportFailed,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    key: const Key('anki-export'),
    onPressed: _busy ? null : _export,
    icon: _busy
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.file_download_outlined),
    label: Text(
      _busy ? context.l10n.ankiExportPreparing : context.l10n.ankiExportDeck,
    ),
  );
}

Future<void> saveAnkiExport(
  BuildContext context,
  Uint8List bytes,
  String name,
  String format,
) async {
  final fileTypeLabel = context.l10n.ankiDeckFileLabel;
  final mime = switch (format) {
    'csv' => 'text/csv',
    'json' => 'application/json',
    _ => 'application/octet-stream',
  };
  final file = XFile.fromData(bytes, name: name, mimeType: mime);
  if (!kIsWeb &&
      const [
        TargetPlatform.windows,
        TargetPlatform.linux,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform)) {
    final result = await getSaveLocation(
      suggestedName: name,
      acceptedTypeGroups: [
        XTypeGroup(label: fileTypeLabel, extensions: [format]),
      ],
    );
    if (result != null) await file.saveTo(result.path);
    return;
  }
  if (!context.mounted) return;
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(
    ShareParams(
      files: [file],
      fileNameOverrides: [name],
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}

Future<void> deleteAnkiDeck(
  BuildContext context,
  WidgetRef ref,
  String id,
) async {
  final owner = ref.read(authControllerProvider).user?.id;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.ankiDeletePersonalDeck),
      content: Text(context.l10n.ankiThisDeck),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.ankiClear),
        ),
      ],
    ),
  );
  if (confirmed != true ||
      !context.mounted ||
      ref.read(authControllerProvider).user?.id != owner) {
    return;
  }
  try {
    await ref.read(ankiTransferRepositoryProvider).delete(id);
    ref
      ..invalidate(ankiDecksProvider)
      ..invalidate(ankiDeckProvider(id));
    if (context.mounted) context.go('/anki');
  } on Object catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is AnkiTransferFailure
                ? error.message
                : context.l10n.ankiDeleteFailed,
          ),
        ),
      );
    }
  }
}
