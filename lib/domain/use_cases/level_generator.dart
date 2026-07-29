import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/game_level.dart';

class LevelGenerator {
  final Map<int, GameLevel> _cache = {};
  final Set<int> _generating = {};

  GameLevel generate(int levelNumber) {
    GameLevel level;
    if (_cache.containsKey(levelNumber)) {
      debugPrint('⚡ [LevelGenerator] Cache HIT for level $levelNumber.');
      level = _cache.remove(levelNumber)!;
    } else {
      debugPrint('🐌 [LevelGenerator] Cache MISS for level $levelNumber. Generating.');
      level = _generateInternal(levelNumber);
    }
    _generating.remove(levelNumber);
    _pregenerateNext(levelNumber + 1);
    return level;
  }

  GameLevel _generateInternal(int levelNumber) {
    final random = Random(levelNumber);
    final gridSize = _getGridSize(levelNumber);
    return _generateLevelWithSeed(levelNumber, gridSize, random);
  }

  void _pregenerateNext(int startLevel) {
    for (int i = 0; i < 3; i++) {
      final levelNumber = startLevel + i;
      if (!_cache.containsKey(levelNumber) && !_generating.contains(levelNumber)) {
        _generating.add(levelNumber);
        compute(_isolateGenerate, levelNumber).then((level) {
          _cache[levelNumber] = level;
          _generating.remove(levelNumber);
        }).catchError((e) {
          _generating.remove(levelNumber);
        });
      }
    }
  }

  static GameLevel _isolateGenerate(int levelNumber) {
    return LevelGenerator()._generateInternal(levelNumber);
  }

  GameLevel generateRandom({required int gridSize, required int seed}) {
    final random = Random(seed);
    return _generateLevelWithSeed(-1, gridSize, random);
  }

  int _getGridSize(int level) {
    if (level <= 5) return 5;
    if (level <= 15) return 6;
    if (level <= 30) return 7;
    if (level <= 45) return 8;
    if (level <= 60) return 9;
    if (level <= 75) return 10;
    if (level <= 90) return 11;
    return 12;
  }

  GameLevel _generateLevelWithSeed(int levelNumber, int gridSize, Random random) {
    int attempts = 0;
    while (attempts < 50) {
      attempts++;
      final fillDensity = 0.45 + (random.nextDouble() * 0.20);
      final grid = List.generate(
        gridSize,
        (_) => List.generate(gridSize, (_) => random.nextDouble() < fillDensity),
      );

      final rowClues = _computeRowClues(grid, gridSize);
      final colClues = _computeColClues(grid, gridSize);

      bool valid = true;
      for (final r in rowClues) {
        if (r.isEmpty || (r.length == 1 && r[0] == 0)) {
          valid = false;
          break;
        }
      }
      for (final c in colClues) {
        if (c.isEmpty || (c.length == 1 && c[0] == 0)) {
          valid = false;
          break;
        }
      }

      if (valid && (gridSize <= 7 ? _hasUniqueSolutionFast(gridSize, rowClues, colClues) : true)) {
        return GameLevel(
          levelNumber: levelNumber,
          gridSize: gridSize,
          solutionGrid: grid,
          rowClues: rowClues,
          colClues: colClues,
        );
      }
    }

    // High-contrast structured fallback grid guaranteed to generate smooth, clean, valid clues
    final fallbackGrid = List.generate(
      gridSize,
      (r) => List.generate(gridSize, (c) => (r % 2 == 0) ? (c % 2 == 0) : (c % 2 != 0)),
    );
    return GameLevel(
      levelNumber: levelNumber,
      gridSize: gridSize,
      solutionGrid: fallbackGrid,
      rowClues: _computeRowClues(fallbackGrid, gridSize),
      colClues: _computeColClues(fallbackGrid, gridSize),
    );
  }

  static List<List<int>> _computeRowClues(List<List<bool>> grid, int size) {
    final clues = <List<int>>[];
    for (int r = 0; r < size; r++) {
      final rowClue = <int>[];
      int count = 0;
      for (int c = 0; c < size; c++) {
        if (grid[r][c]) {
          count++;
        } else if (count > 0) {
          rowClue.add(count);
          count = 0;
        }
      }
      if (count > 0) rowClue.add(count);
      clues.add(rowClue.isEmpty ? [0] : rowClue);
    }
    return clues;
  }

  static List<List<int>> _computeColClues(List<List<bool>> grid, int size) {
    final clues = <List<int>>[];
    for (int c = 0; c < size; c++) {
      final colClue = <int>[];
      int count = 0;
      for (int r = 0; r < size; r++) {
        if (grid[r][c]) {
          count++;
        } else if (count > 0) {
          colClue.add(count);
          count = 0;
        }
      }
      if (count > 0) colClue.add(count);
      clues.add(colClue.isEmpty ? [0] : colClue);
    }
    return clues;
  }

  /// Fast depth-limited solver for small grids (<= 7x7) to prevent UI thread freezing
  bool _hasUniqueSolutionFast(
    int size,
    List<List<int>> rowClues,
    List<List<int>> colClues,
  ) {
    int solutionCount = 0;
    int steps = 0;
    const maxSteps = 1000;
    final currentGrid = List.generate(size, (_) => List<bool>.filled(size, false));

    void solve(int cellIndex) {
      if (solutionCount >= 2 || steps > maxSteps) return;
      steps++;

      if (cellIndex == size * size) {
        if (_matchesColClues(currentGrid, size, colClues)) {
          solutionCount++;
        }
        return;
      }

      final r = cellIndex ~/ size;
      final c = cellIndex % size;

      currentGrid[r][c] = false;
      if (c == size - 1) {
        if (_rowMatchesClue(currentGrid[r], rowClues[r])) {
          solve(cellIndex + 1);
        }
      } else {
        solve(cellIndex + 1);
      }

      if (solutionCount >= 2 || steps > maxSteps) return;

      currentGrid[r][c] = true;
      if (c == size - 1) {
        if (_rowMatchesClue(currentGrid[r], rowClues[r])) {
          solve(cellIndex + 1);
        }
      } else {
        solve(cellIndex + 1);
      }

      currentGrid[r][c] = false;
    }

    solve(0);
    return solutionCount == 1 && steps <= maxSteps;
  }

  bool _rowMatchesClue(List<bool> row, List<int> expectedClue) {
    final clue = <int>[];
    int count = 0;
    for (final val in row) {
      if (val) {
        count++;
      } else if (count > 0) {
        clue.add(count);
        count = 0;
      }
    }
    if (count > 0) clue.add(count);
    final actual = clue.isEmpty ? [0] : clue;
    if (actual.length != expectedClue.length) return false;
    for (int i = 0; i < actual.length; i++) {
      if (actual[i] != expectedClue[i]) return false;
    }
    return true;
  }

  bool _matchesColClues(List<List<bool>> grid, int size, List<List<int>> colClues) {
    for (int c = 0; c < size; c++) {
      final clue = <int>[];
      int count = 0;
      for (int r = 0; r < size; r++) {
        if (grid[r][c]) {
          count++;
        } else if (count > 0) {
          clue.add(count);
          count = 0;
        }
      }
      if (count > 0) clue.add(count);
      final actual = clue.isEmpty ? [0] : clue;
      if (actual.length != colClues[c].length) return false;
      for (int i = 0; i < actual.length; i++) {
        if (actual[i] != colClues[c][i]) return false;
      }
    }
    return true;
  }
}
