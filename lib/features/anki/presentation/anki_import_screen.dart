import 'dart:math';
import 'dart:typed_data';

import 'package:bahasa_master/features/anki/data/anki_repository.dart';
import 'package:bahasa_master/features/anki/data/anki_transfer_repository.dart';
import 'package:bahasa_master/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bahasa_master/l10n/l10n.dart';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AnkiImportScreen extends ConsumerStatefulWidget {
  const AnkiImportScreen({super.key});
  @override
  ConsumerState<AnkiImportScreen> createState() => _AnkiImportState();
}

class _AnkiImportState extends ConsumerState<AnkiImportScreen> {
  final _title = TextEditingController();
  final _cancel = CancelToken();
  Uint8List? _bytes;
  String? _filename;
  String? _requestId;
  Map<String, dynamic>? _preview;
  String? _error;
  bool _busy = false;
  bool _committing = false;

  @override
  void dispose() {
    _cancel.cancel();
    _title.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    if (_busy) return;
    final l10n = context.l10n;
    final owner = ref.read(authControllerProvider).user?.id;
    if (owner == null) {
      await context.push('/login');
      return;
    }
    setState(() {
      _busy = true;
      _committing = false;
      _error = null;
      _preview = null;
      _bytes = null;
    });
    try {
      final file = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(
            label: l10n.ankiDeckFileLabel,
            extensions: const ['apkg', 'csv', 'json'],
            mimeTypes: const [
              'application/zip',
              'application/octet-stream',
              'text/csv',
              'application/json',
              'text/plain',
            ],
            uniformTypeIdentifiers: const ['public.data'],
          ),
        ],
      );
      if (file == null) return;
      if (!mounted || ref.read(authControllerProvider).user?.id != owner) {
        return;
      }
      if (await file.length() > AnkiTransferRepository.maxFileBytes) {
        throw AnkiTransferFailure(l10n.ankiTransferFileSize);
      }
      final bytes = await file.readAsBytes();
      if (!mounted || ref.read(authControllerProvider).user?.id != owner) {
        return;
      }
      final preview = await ref
          .read(ankiTransferRepositoryProvider)
          .importFile(
            name: file.name,
            bytes: bytes,
            preview: true,
            cancelToken: _cancel,
          );
      if (!mounted || ref.read(authControllerProvider).user?.id != owner) {
        return;
      }
      setState(() {
        _bytes = bytes;
        _filename = file.name;
        _preview = preview;
        _requestId = _newRequestId();
        _title.text = preview['title'] as String;
      });
    } on Object catch (error) {
      if (mounted) {
        setState(
          () => _error = error is AnkiTransferFailure
              ? error.message
              : context.l10n.ankiImportOpenFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    if (_busy || _preview == null || _bytes == null) return;
    if (_title.text.trim().isEmpty) {
      setState(() => _error = context.l10n.ankiImportNameRequired);
      return;
    }
    final owner = ref.read(authControllerProvider).user?.id;
    setState(() {
      _busy = true;
      _committing = true;
      _error = null;
    });
    try {
      final deck = await ref
          .read(ankiTransferRepositoryProvider)
          .importFile(
            name: _filename!,
            bytes: _bytes!,
            preview: false,
            title: _title.text.trim(),
            digest: _preview!['sha256'] as String,
            requestId: _requestId,
            cancelToken: _cancel,
          );
      if (!mounted || ref.read(authControllerProvider).user?.id != owner) {
        return;
      }
      ref.invalidate(ankiDecksProvider);
      if (context.canPop()) {
        context.pop(deck['id'] as String);
      } else {
        context.go('/anki/decks/${deck['id']}');
      }
    } on Object catch (error) {
      if (mounted) {
        setState(
          () => _error = error is AnkiTransferFailure
              ? error.message
              : context.l10n.ankiImportFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider.select((state) => state.user?.id), (
      previous,
      next,
    ) {
      if (previous != next) {
        _cancel.cancel('Account changed');
        if (context.mounted) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/anki');
          }
        }
      }
    });
    final preview = _preview;
    return PopScope(
      canPop: !_busy || !_committing,
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.ankiImportDeck)),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Icon(
              Icons.file_upload_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.ankiBringYour,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(context.l10n.ankiChooseAn),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              key: const Key('anki-import-pick'),
              onPressed: _busy ? null : _pick,
              icon: const Icon(Icons.folder_open_outlined),
              label: Text(
                _filename ?? context.l10n.ankiImportChooseFile,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_busy) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                _committing
                    ? context.l10n.ankiImportSaving
                    : context.l10n.ankiImportReading,
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (preview != null) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _title,
                enabled: !_busy && !_committing,
                maxLength: 140,
                decoration: InputDecoration(
                  labelText: context.l10n.ankiDeckName,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.ankiImportSummary(
                  (preview['cardCount'] as num).toInt(),
                  (preview['mediaCount'] as num).toInt(),
                ),
              ),
              const SizedBox(height: 12),
              Text(context.l10n.ankiPersonalDecks),
              const SizedBox(height: 16),
              for (final raw in preview['preview'] as List)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (raw as Map)['front'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text((raw['answers'] as List).join(' · ')),
                        if ((raw['meaning'] as String? ?? '').isNotEmpty)
                          Text(raw['meaning'] as String),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('anki-import-confirm'),
                onPressed: _busy ? null : _import,
                icon: const Icon(Icons.add_rounded),
                label: Text(context.l10n.ankiImportAs),
              ),
            ],
            const SizedBox(height: 24),
            ExpansionTile(
              title: Text(context.l10n.ankiFileFormats),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(context.l10n.ankiCsvColumns),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _newRequestId() {
  final bytes = List.generate(16, (_) => Random.secure().nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final hex = bytes
      .map((value) => value.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
