import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Replaces the old English coverage test: all UI text lives in the ARB
/// template and no Indonesian source text or `.localized` calls remain.
void main() {
  final template =
      jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
          as Map<String, dynamic>;

  test('every key in app_en.arb has a non-empty message', () {
    final keys = template.keys.where((k) => !k.startsWith('@'));
    expect(keys, isNotEmpty);
    for (final key in keys) {
      final value = template[key];
      expect(value, isA<String>(), reason: key);
      expect((value as String).trim(), isNotEmpty, reason: key);
    }
  });

  test('every locale ARB only uses keys from the template', () {
    final names = template.keys.where((k) => !k.startsWith('@')).toSet();
    final arbs = Directory(
      'lib/l10n',
    ).listSync().whereType<File>().where((f) => f.path.endsWith('.arb'));
    for (final file in arbs) {
      final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      for (final key in data.keys.where((k) => !k.startsWith('@'))) {
        expect(names, contains(key), reason: '${file.path}: $key');
      }
    }
  });

  final dartFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.startsWith('lib/l10n/'))
      .toList();

  test('lib has no .localized( calls', () {
    for (final file in dartFiles) {
      expect(
        file.readAsStringSync(),
        isNot(contains('.localized(')),
        reason: file.path,
      );
    }
  });

  test('no common Indonesian UI words in lib string literals', () {
    const denylist = [
      'Beranda',
      'Belajar',
      'Masuk',
      'Simpan',
      'Batal',
      'Lanjut',
      'Pengaturan',
      'Profil',
      'Kembali',
    ];
    final literal = RegExp(r'''(['"])((?:\\.|(?!\1).)*)\1''');
    final offenders = <String>[];
    for (final file in dartFiles) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.startsWith('//') || line.startsWith('import ')) continue;
        for (final match in literal.allMatches(lines[i])) {
          final text = match.group(2)!;
          for (final word in denylist) {
            if (RegExp('\\b$word\\b').hasMatch(text)) {
              offenders.add('${file.path}:${i + 1} $word');
            }
          }
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
