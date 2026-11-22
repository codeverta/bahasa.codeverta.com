import 'package:bahasa_master/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A Japanese example line: text, reading and meaning.
class LevelListExample {
  const LevelListExample({
    required this.japanese,
    required this.reading,
    required this.meaning,
  });

  factory LevelListExample.fromJson(Map<String, dynamic> json) =>
      LevelListExample(
        japanese: json['japanese'] as String? ?? '',
        reading: json['reading'] as String? ?? '',
        meaning: json['meaning'] as String? ?? '',
      );

  final String japanese;
  final String reading;
  final String meaning;
}

/// One grammar point of a level, with the lesson it belongs to.
class GrammarListItem {
  const GrammarListItem({
    required this.lessonId,
    required this.lessonTitle,
    required this.lessonNumber,
    required this.pattern,
    required this.meaning,
    required this.formation,
    required this.explanation,
    required this.commonMistake,
    required this.examples,
  });

  final String lessonId;
  final String lessonTitle;
  final int lessonNumber;
  final String pattern;
  final String meaning;
  final String formation;
  final String explanation;
  final String commonMistake;
  final List<LevelListExample> examples;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return '$pattern $meaning $lessonTitle'.toLowerCase().contains(q);
  }
}

enum LevelListKind {
  grammar('grammar', 'points');

  const LevelListKind(this.path, this.listSegment);

  final String path;
  final String listSegment;
}

List<LevelListExample> _examples(Object? value) => [
  if (value is List)
    for (final item in value)
      if (item is Map<String, dynamic>) LevelListExample.fromJson(item),
];

String _text(Map<String, dynamic> json, String key) =>
    json[key] as String? ?? '';

class LevelListRepository {
  LevelListRepository(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> _lessons(
    LevelListKind kind,
    String level,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/${kind.path}/levels/$level/${kind.listSegment}',
    );
    final data = response.data?['data'];
    final lessons = data is Map<String, dynamic> ? data['lessons'] : null;
    return [
      if (lessons is List)
        for (final lesson in lessons)
          if (lesson is Map<String, dynamic>) lesson,
    ];
  }

  Future<List<GrammarListItem>> grammar(String level) async {
    final lessons = await _lessons(LevelListKind.grammar, level);
    return [
      for (final (index, lesson) in lessons.indexed)
        for (final point in (lesson['points'] as List?) ?? const [])
          if (point is Map<String, dynamic>)
            GrammarListItem(
              lessonId: _text(lesson, 'id'),
              lessonTitle: _text(lesson, 'title'),
              lessonNumber: index + 1,
              pattern: _text(point, 'pattern'),
              meaning: _text(point, 'meaning'),
              formation: _text(point, 'formation'),
              explanation: _text(point, 'explanation'),
              commonMistake: _text(point, 'commonMistake'),
              examples: _examples(point['examples']),
            ),
    ];
  }
}

final levelListRepositoryProvider = Provider<LevelListRepository>(
  (ref) => LevelListRepository(ref.watch(dioProvider)),
);

final grammarLevelListProvider = FutureProvider.autoDispose
    .family<List<GrammarListItem>, String>(
      (ref, level) => ref.watch(levelListRepositoryProvider).grammar(level),
    );
