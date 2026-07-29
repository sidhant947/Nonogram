import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/progress_repository.dart';
import '../data/services/hive_service.dart';
import '../domain/use_cases/level_generator.dart';
import '../ui/features/game/view_models/game_view_model.dart';
import '../ui/features/home/view_models/home_view_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final progressRepositoryProvider = ChangeNotifierProvider<ProgressRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ProgressRepository(hiveService: hiveService);
});

final levelGeneratorProvider = Provider<LevelGenerator>((ref) {
  return LevelGenerator();
});

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewModelState>((ref) {
  final progressRepository = ref.read(progressRepositoryProvider);
  return HomeViewModel(progressRepository: progressRepository);
});

final gameViewModelProvider =
    StateNotifierProvider.autoDispose<GameViewModel, GameViewModelState>((ref) {
  final progressRepository = ref.read(progressRepositoryProvider);
  final levelGenerator = ref.read(levelGeneratorProvider);
  return GameViewModel(
    progressRepository: progressRepository,
    levelGenerator: levelGenerator,
  );
});
