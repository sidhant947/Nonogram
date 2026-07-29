import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/progress_repository.dart';
import '../../../../domain/models/game_level.dart';
import '../../../../domain/use_cases/level_generator.dart';
import '../../../../domain/use_cases/nonogram_rules.dart';

enum CellState {
  empty,
  filled,
  cross,
}

@immutable
class _Snapshot {
  const _Snapshot(this.board, this.moveCount);
  final List<List<CellState>> board;
  final int moveCount;
}

@immutable
class GameViewModelState {
  const GameViewModelState({
    this.level,
    this.board = const [],
    this.conflicts = const [],
    this.isLoading = false,
    this.isComplete = false,
    this.moveCount = 0,
    this.elapsedSeconds = 0,
    this.canUndo = false,
    this.hintCell,
    this.error,
    this.isRandomMode = false,
    this.randomDifficulty,
    this.randomSeed,
    this.randomGridSize,
  });

  final GameLevel? level;
  final List<List<CellState>> board;
  final List<List<bool>> conflicts;
  final bool isLoading;
  final bool isComplete;
  final int moveCount;
  final int elapsedSeconds;
  final bool canUndo;
  final int? hintCell;
  final String? error;
  final bool isRandomMode;
  final String? randomDifficulty;
  final int? randomSeed;
  final int? randomGridSize;

  GameViewModelState copyWith({
    GameLevel? level,
    List<List<CellState>>? board,
    List<List<bool>>? conflicts,
    bool? isLoading,
    bool? isComplete,
    int? moveCount,
    int? elapsedSeconds,
    bool? canUndo,
    int? hintCell,
    bool clearHint = false,
    String? error,
    bool? isRandomMode,
    String? randomDifficulty,
    int? randomSeed,
    int? randomGridSize,
  }) {
    return GameViewModelState(
      level: level ?? this.level,
      board: board ?? this.board,
      conflicts: conflicts ?? this.conflicts,
      isLoading: isLoading ?? this.isLoading,
      isComplete: isComplete ?? this.isComplete,
      moveCount: moveCount ?? this.moveCount,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      canUndo: canUndo ?? this.canUndo,
      hintCell: clearHint ? null : (hintCell ?? this.hintCell),
      error: error,
      isRandomMode: isRandomMode ?? this.isRandomMode,
      randomDifficulty: randomDifficulty ?? this.randomDifficulty,
      randomSeed: randomSeed ?? this.randomSeed,
      randomGridSize: randomGridSize ?? this.randomGridSize,
    );
  }
}

class GameViewModel extends StateNotifier<GameViewModelState> {
  GameViewModel({
    required this.progressRepository,
    required this.levelGenerator,
  }) : super(const GameViewModelState());

  final ProgressRepository progressRepository;
  final LevelGenerator levelGenerator;

  static const int _maxUndo = 50;
  final List<_Snapshot> _undoStack = [];
  Timer? _timer;
  Timer? _hintTimer;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isComplete) {
        _timer?.cancel();
        return;
      }
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  List<List<CellState>> _emptyBoard(int n) =>
      List.generate(n, (_) => List<CellState>.filled(n, CellState.empty));

  Future<void> loadLevel(int levelNumber) async {
    _undoStack.clear();
    state = const GameViewModelState(isLoading: true);

    try {
      final level = levelGenerator.generate(levelNumber);
      final progress = await progressRepository.getProgress();
      List<List<CellState>> board;
      int moveCount = 0;
      int elapsed = 0;

      if (progress.savedLevelNumber == levelNumber &&
          progress.savedBoard != null &&
          progress.savedBoard!.length == level.gridSize) {
        board = progress.savedBoard!
            .map((row) =>
                row.map((i) => CellState.values[i]).toList(growable: false))
            .toList();
        moveCount = progress.savedMoveCount;
        elapsed = progress.savedElapsedSeconds;
      } else {
        board = _emptyBoard(level.gridSize);
      }

      final conflicts = NonogramRules.computeConflicts(board, level);
      final isComplete = NonogramRules.isComplete(board, level);

      state = GameViewModelState(
        level: level,
        board: board,
        conflicts: conflicts,
        moveCount: moveCount,
        elapsedSeconds: elapsed,
        isComplete: isComplete,
      );
      if (!isComplete) _startTimer();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load level: $e',
      );
    }
  }

  Future<void> loadRandomLevel(String difficulty, {int? seed}) async {
    _undoStack.clear();
    final int levelSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
    state = GameViewModelState(
      isLoading: true,
      isRandomMode: true,
      randomDifficulty: difficulty,
      randomSeed: levelSeed,
    );

    try {
      int gridSize = 5;
      if (difficulty == 'Medium') {
        gridSize = 7;
      } else if (difficulty == 'Hard') {
        gridSize = 8;
      } else if (difficulty == 'Expert') {
        gridSize = 10;
      } else if (difficulty == 'Master') {
        gridSize = 12;
      }

      final level = levelGenerator.generateRandom(
        gridSize: gridSize,
        seed: levelSeed,
      );
      final board = _emptyBoard(gridSize);
      final conflicts = NonogramRules.computeConflicts(board, level);

      state = state.copyWith(
        level: level,
        board: board,
        conflicts: conflicts,
        moveCount: 0,
        elapsedSeconds: 0,
        canUndo: false,
        isLoading: false,
        randomGridSize: gridSize,
      );
      _startTimer();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load random level: $e',
      );
    }
  }

  void toggleCell(int r, int c) {
    final level = state.level;
    if (state.isComplete || level == null) return;

    _pushUndo();

    final n = level.gridSize;
    final newBoard = List.generate(
      n,
      (row) => List<CellState>.from(state.board[row]),
    );

    final current = newBoard[r][c];
    CellState next;
    int movesDelta = 0;

    if (current == CellState.empty) {
      next = CellState.filled;
      movesDelta = 1;
      HapticFeedback.mediumImpact();
    } else if (current == CellState.filled) {
      next = CellState.cross;
      HapticFeedback.lightImpact();
    } else {
      next = CellState.empty;
      HapticFeedback.lightImpact();
    }

    newBoard[r][c] = next;

    final newConflicts = NonogramRules.computeConflicts(newBoard, level);
    final isComplete = NonogramRules.isComplete(newBoard, level);

    if (isComplete) {
      HapticFeedback.heavyImpact();
      _stopTimer();
    }

    state = state.copyWith(
      board: newBoard,
      conflicts: newConflicts,
      moveCount: state.moveCount + movesDelta,
      isComplete: isComplete,
      canUndo: _undoStack.isNotEmpty,
      clearHint: true,
    );

    _persistInProgress();
  }

  void setCellState(int r, int c, CellState next) {
    final level = state.level;
    if (state.isComplete || level == null) return;

    final current = state.board[r][c];
    if (current == next) return;

    _pushUndo();

    final n = level.gridSize;
    final newBoard = List.generate(
      n,
      (row) => List<CellState>.from(state.board[row]),
    );

    newBoard[r][c] = next;

    final newConflicts = NonogramRules.computeConflicts(newBoard, level);
    final isComplete = NonogramRules.isComplete(newBoard, level);

    if (isComplete) {
      HapticFeedback.heavyImpact();
      _stopTimer();
    } else {
      HapticFeedback.selectionClick();
    }

    state = state.copyWith(
      board: newBoard,
      conflicts: newConflicts,
      moveCount: state.moveCount + (next == CellState.filled ? 1 : 0),
      isComplete: isComplete,
      canUndo: _undoStack.isNotEmpty,
      clearHint: true,
    );

    _persistInProgress();
  }

  void _pushUndo() {
    final snapshotBoard = state.board
        .map((row) => List<CellState>.from(row))
        .toList(growable: false);
    _undoStack.add(_Snapshot(snapshotBoard, state.moveCount));
    if (_undoStack.length > _maxUndo) {
      _undoStack.removeAt(0);
    }
  }

  void undo() {
    if (_undoStack.isEmpty || state.level == null || state.isComplete) return;
    final snapshot = _undoStack.removeLast();
    final conflicts = NonogramRules.computeConflicts(snapshot.board, state.level!);
    HapticFeedback.lightImpact();
    state = state.copyWith(
      board: snapshot.board,
      conflicts: conflicts,
      moveCount: snapshot.moveCount,
      canUndo: _undoStack.isNotEmpty,
      clearHint: true,
    );
    _persistInProgress();
  }

  void requestHint() {
    final level = state.level;
    if (level == null || state.isComplete) return;
    final hint = NonogramRules.suggestHint(state.board, level);
    if (hint == null) return;
    final encoded = hint[0] * level.gridSize + hint[1];
    HapticFeedback.selectionClick();
    state = state.copyWith(hintCell: encoded);

    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) state = state.copyWith(clearHint: true);
    });
  }

  void _persistInProgress() {
    final level = state.level;
    if (level == null || state.isRandomMode || state.isComplete) return;
    final boardIndices = state.board
        .map((row) => row.map((cell) => cell.index).toList())
        .toList();
    progressRepository.saveInProgress(
      level.levelNumber,
      boardIndices,
      state.moveCount,
      state.elapsedSeconds,
    );
  }

  Future<void> completeLevel() async {
    final level = state.level;
    if (level == null || !state.isComplete) return;
    if (state.isRandomMode) {
      await progressRepository.addRandomLevelMoves(state.moveCount);
    } else {
      await progressRepository.completeLevel(level.levelNumber, state.moveCount);
      await progressRepository.recordLevelResult(
        level.levelNumber,
        state.moveCount,
        state.elapsedSeconds,
      );
      await progressRepository.clearInProgress();
    }
  }

  Future<void> resetLevel() async {
    final level = state.level;
    if (level == null) return;
    if (state.isRandomMode) {
      await loadRandomLevel(state.randomDifficulty ?? 'Easy',
          seed: state.randomSeed);
    } else {
      await progressRepository.clearInProgress();
      await loadLevel(level.levelNumber);
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _hintTimer?.cancel();
    super.dispose();
  }
}
