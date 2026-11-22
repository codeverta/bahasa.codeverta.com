import 'package:bahasa_master/core/offline/learning_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final learningCacheProvider = FutureProvider<PersistentLearningCache>((ref) {
  return PersistentLearningCache.open();
});

final learningCacheStatsProvider = StreamProvider<LearningCacheStats>((
  ref,
) async* {
  final cache = await ref.watch(learningCacheProvider.future);
  yield await cache.stats();
  yield* cache.statsChanges;
});
