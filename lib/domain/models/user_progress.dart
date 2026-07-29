import 'dart:math' as math;
import 'package:flutter/foundation.dart';

@immutable
class UserProgress {
  const UserProgress({
    this.currentLevel = 1,
    this.highestLevelCompleted = 0,
    this.totalMoves = 0,
    this.bestMoves = const {},
    this.bestTimeSeconds = const {},
    this.savedLevelNumber,
    this.savedBoard,
    this.savedMoveCount = 0,
    this.savedElapsedSeconds = 0,
  });

  final int currentLevel;
  final int highestLevelCompleted;
  final int totalMoves;

  final Map<int, int> bestMoves;
  final Map<int, int> bestTimeSeconds;

  final int? savedLevelNumber;
  final List<List<int>>? savedBoard; // CellState indices
  final int savedMoveCount;
  final int savedElapsedSeconds;

  UserProgress copyWith({
    int? currentLevel,
    int? highestLevelCompleted,
    int? totalMoves,
    Map<int, int>? bestMoves,
    Map<int, int>? bestTimeSeconds,
    int? savedLevelNumber,
    List<List<int>>? savedBoard,
    int? savedMoveCount,
    int? savedElapsedSeconds,
  }) {
    return UserProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      highestLevelCompleted:
          highestLevelCompleted ?? this.highestLevelCompleted,
      totalMoves: totalMoves ?? this.totalMoves,
      bestMoves: bestMoves ?? this.bestMoves,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
      savedLevelNumber: savedLevelNumber ?? this.savedLevelNumber,
      savedBoard: savedBoard ?? this.savedBoard,
      savedMoveCount: savedMoveCount ?? this.savedMoveCount,
      savedElapsedSeconds: savedElapsedSeconds ?? this.savedElapsedSeconds,
    );
  }

  UserProgress incrementLevel() {
    return copyWith(
      currentLevel: currentLevel + 1,
      highestLevelCompleted: math.max(highestLevelCompleted, currentLevel),
    );
  }

  UserProgress addMoves(int moves) {
    return copyWith(totalMoves: totalMoves + moves);
  }

  UserProgress recordLevelResult(int level, int moves, int seconds) {
    final newBestMoves = Map<int, int>.from(bestMoves);
    final newBestTime = Map<int, int>.from(bestTimeSeconds);

    final priorMoves = newBestMoves[level];
    if (priorMoves == null || moves < priorMoves) {
      newBestMoves[level] = moves;
    }
    final priorTime = newBestTime[level];
    if (priorTime == null || seconds < priorTime) {
      newBestTime[level] = seconds;
    }

    return copyWith(bestMoves: newBestMoves, bestTimeSeconds: newBestTime);
  }

  UserProgress withSavedGame({
    required int levelNumber,
    required List<List<int>> boardStateIndices,
    required int moveCount,
    required int elapsedSeconds,
  }) {
    return copyWith(
      savedLevelNumber: levelNumber,
      savedBoard: boardStateIndices,
      savedMoveCount: moveCount,
      savedElapsedSeconds: elapsedSeconds,
    );
  }

  UserProgress withoutSavedGame() {
    return UserProgress(
      currentLevel: currentLevel,
      highestLevelCompleted: highestLevelCompleted,
      totalMoves: totalMoves,
      bestMoves: bestMoves,
      bestTimeSeconds: bestTimeSeconds,
      savedLevelNumber: null,
      savedBoard: null,
      savedMoveCount: 0,
      savedElapsedSeconds: 0,
    );
  }
}
