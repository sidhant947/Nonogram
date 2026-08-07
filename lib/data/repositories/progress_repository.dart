import 'package:flutter/foundation.dart';
import '../../domain/models/user_progress.dart';
import '../services/hive_service.dart';

class ProgressRepository extends ChangeNotifier {
  ProgressRepository({required HiveService hiveService}) : _hiveService = hiveService;

  final HiveService _hiveService;
  UserProgress? _cachedProgress;

  UserProgress? get cachedProgress => _cachedProgress;

  bool get hapticsEnabled => _cachedProgress?.hapticsEnabled ?? true;

  Future<UserProgress> getProgress() async {
    if (_cachedProgress != null) return _cachedProgress!;
    _cachedProgress = await _hiveService.getProgress();
    return _cachedProgress!;
  }

  Future<void> saveProgress(UserProgress progress) async {
    _cachedProgress = progress;
    await _hiveService.saveProgress(progress);
    notifyListeners();
  }

  Future<void> toggleHaptics() async {
    final current = await getProgress();
    await saveProgress(current.copyWith(hapticsEnabled: !current.hapticsEnabled));
  }

  Future<void> completeLevel(int levelNumber, int moves) async {
    final current = await getProgress();
    final isNewCompletion = levelNumber == current.highestLevelCompleted + 1;
    final updated = isNewCompletion
        ? current.incrementLevel().addMoves(moves)
        : current.addMoves(moves);
    await saveProgress(updated);
  }

  Future<void> addRandomLevelMoves(int moves) async {
    final current = await getProgress();
    final updated = current.addMoves(moves);
    await saveProgress(updated);
  }

  Future<void> recordLevelResult(int level, int moves, int seconds) async {
    final current = await getProgress();
    await saveProgress(current.recordLevelResult(level, moves, seconds));
  }

  Future<void> saveInProgress(
    int level,
    List<List<int>> boardStateIndices,
    int moves,
    int seconds,
  ) async {
    final current = await getProgress();
    await saveProgress(
      current.withSavedGame(
        levelNumber: level,
        boardStateIndices: boardStateIndices,
        moveCount: moves,
        elapsedSeconds: seconds,
      ),
    );
  }

  Future<void> clearInProgress() async {
    final current = await getProgress();
    if (current.savedLevelNumber == null) return;
    await saveProgress(current.withoutSavedGame());
  }

  Future<void> resetProgress() async {
    _cachedProgress = null;
    await _hiveService.clearProgress();
    notifyListeners();
  }
}
