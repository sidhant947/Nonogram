import 'package:flutter/material.dart';
import '../../domain/models/user_progress.dart';
import '../../ui/core/theme/app_colors.dart';
import '../services/hive_service.dart';

class ProgressRepository extends ChangeNotifier {
  ProgressRepository(this._hiveService);

  final HiveService _hiveService;
  UserProgress? _cachedProgress;

  UserProgress? get cachedProgress => _cachedProgress;

  bool get hapticsEnabled => _cachedProgress?.hapticsEnabled ?? true;

  bool get longPressToCrossEnabled => _cachedProgress?.longPressToCrossEnabled ?? true;

  bool get cycleModeEnabled => _cachedProgress?.cycleModeEnabled ?? false;

  String get themeMode => _cachedProgress?.themeMode ?? 'system';

  void updateAppColors([Brightness? platformBrightness]) {
    final mode = themeMode;
    final brightness = platformBrightness ??
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark = mode == 'dark' ||
        (mode == 'system' && brightness == Brightness.dark);
    AppColors.setTheme(isDark ? AppThemes.classic : AppThemes.light);
  }

  Future<UserProgress> getProgress() async {
    if (_cachedProgress != null) return _cachedProgress!;
    _cachedProgress = await _hiveService.getProgress();
    updateAppColors();
    return _cachedProgress!;
  }

  Future<void> saveProgress(UserProgress progress) async {
    _cachedProgress = progress;
    updateAppColors();
    notifyListeners();
    await _hiveService.saveProgress(progress);
  }

  Future<void> setThemeMode(String mode) async {
    if (_cachedProgress?.themeMode == mode) return;
    _cachedProgress = (_cachedProgress ?? const UserProgress()).copyWith(themeMode: mode);
    updateAppColors();
    notifyListeners();
    await _hiveService.saveProgress(_cachedProgress!);
  }

  Future<void> toggleHaptics() async {
    final current = await getProgress();
    await saveProgress(current.copyWith(hapticsEnabled: !current.hapticsEnabled));
  }

  Future<void> toggleLongPressToCross() async {
    final current = await getProgress();
    await saveProgress(current.copyWith(longPressToCrossEnabled: !current.longPressToCrossEnabled));
  }

  Future<void> toggleCycleMode() async {
    final current = await getProgress();
    await saveProgress(current.copyWith(cycleModeEnabled: !current.cycleModeEnabled));
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
