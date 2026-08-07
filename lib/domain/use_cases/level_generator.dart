import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/game_level.dart';

class LevelGenerator {
  final Map<int, GameLevel> _cache = {};
  final Set<int> _generating = {};

  LevelGenerator({bool pregenerate = true}) {
    if (pregenerate) {
      pregenerateBatch(1, count: 3);
    }
  }

  void pregenerateBatch(int startLevel, {int count = 3}) {
    for (int i = 0; i < count; i++) {
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
    pregenerateBatch(levelNumber + 1, count: 2);
    return level;
  }

  GameLevel _generateInternal(int levelNumber) {
    final gridSize = _getGridSize(levelNumber);
    return _generateLevelWithSeed(levelNumber, gridSize);
  }

  static GameLevel _isolateGenerate(int levelNumber) {
    return LevelGenerator(pregenerate: false)._generateInternal(levelNumber);
  }

  GameLevel generateRandom({required int gridSize, required int seed}) {
    return _generateLevelWithSeed(-1, gridSize, seedOverride: seed);
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

  GameLevel _generateLevelWithSeed(int levelNumber, int gridSize, {int? seedOverride}) {
    int seedOffset = 0;
    while (true) {
      final seed = seedOverride ?? ((levelNumber * 31337 + seedOffset * 7919) & 0x7FFFFFFF);
      seedOffset++;
      final random = Random(seed);
      final fillDensity = 0.40 + (random.nextDouble() * 0.25);
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

      if (valid && _countSolutions(gridSize, rowClues, colClues) == 1) {
        return GameLevel(
          levelNumber: levelNumber,
          gridSize: gridSize,
          solutionGrid: grid,
          rowClues: rowClues,
          colClues: colClues,
        );
      }
    }
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

  int _countSolutions(
    int size,
    List<List<int>> rowClues,
    List<List<int>> colClues,
  ) {
    int solutionsFound = 0;

    final rowPossibilities = <List<List<bool>>>[];
    for (int r = 0; r < size; r++) {
      rowPossibilities.add(_generateLinePossibilities(size, rowClues[r]));
    }

    final colPossibilities = <List<List<bool>>>[];
    for (int c = 0; c < size; c++) {
      colPossibilities.add(_generateLinePossibilities(size, colClues[c]));
    }

    bool changed = true;
    while (changed) {
      changed = false;
      for (int r = 0; r < size; r++) {
        if (rowPossibilities[r].isEmpty) return 0;
        for (int c = 0; c < size; c++) {
          bool allTrue = true;
          bool allFalse = true;
          for (final rp in rowPossibilities[r]) {
            if (rp[c]) {
              allFalse = false;
            } else {
              allTrue = false;
            }
          }
          if (allTrue || allFalse) {
            final targetVal = allTrue;
            final prevLen = colPossibilities[c].length;
            colPossibilities[c].removeWhere((cp) => cp[r] != targetVal);
            if (colPossibilities[c].length < prevLen) {
              changed = true;
              if (colPossibilities[c].isEmpty) return 0;
            }
          }
        }
      }
      for (int c = 0; c < size; c++) {
        if (colPossibilities[c].isEmpty) return 0;
        for (int r = 0; r < size; r++) {
          bool allTrue = true;
          bool allFalse = true;
          for (final cp in colPossibilities[c]) {
            if (cp[r]) {
              allFalse = false;
            } else {
              allTrue = false;
            }
          }
          if (allTrue || allFalse) {
            final targetVal = allTrue;
            final prevLen = rowPossibilities[r].length;
            rowPossibilities[r].removeWhere((rp) => rp[c] != targetVal);
            if (rowPossibilities[r].length < prevLen) {
              changed = true;
              if (rowPossibilities[r].isEmpty) return 0;
            }
          }
        }
      }
    }

    bool allSingle = true;
    for (int r = 0; r < size; r++) {
      if (rowPossibilities[r].length != 1) {
        allSingle = false;
        break;
      }
    }
    if (allSingle) {
      for (int c = 0; c < size; c++) {
        if (colPossibilities[c].length != 1) {
          allSingle = false;
          break;
        }
      }
    }
    if (allSingle) return 1;

    final colPossibilitiesInts = List<Set<int>>.generate(
      size,
      (c) {
        final set = <int>{};
        for (final p in colPossibilities[c]) {
          int val = 0;
          for (int i = 0; i < size; i++) {
            if (p[i]) {
              val |= (1 << i);
            }
          }
          set.add(val);
        }
        return set;
      },
    );

    final colHasTrue = List<List<bool>>.generate(
      size,
      (c) => List<bool>.generate(
        size,
        (r) {
          for (final p in colPossibilities[c]) {
            if (p[r]) return true;
          }
          return false;
        },
      ),
    );

    final colHasFalse = List<List<bool>>.generate(
      size,
      (c) => List<bool>.generate(
        size,
        (r) {
          for (final p in colPossibilities[c]) {
            if (!p[r]) return true;
          }
          return false;
        },
      ),
    );

    void solveRow(int rowIndex, List<List<bool>> currentGrid) {
      if (solutionsFound >= 2) return;

      if (rowIndex == size) {
        for (int c = 0; c < size; c++) {
          int colVal = 0;
          for (int r = 0; r < size; r++) {
            if (currentGrid[r][c]) {
              colVal |= (1 << r);
            }
          }
          if (!colPossibilitiesInts[c].contains(colVal)) {
            return;
          }
        }
        solutionsFound++;
        return;
      }

      for (final candidateRow in rowPossibilities[rowIndex]) {
        bool candidateValid = true;
        for (int c = 0; c < size; c++) {
          final val = candidateRow[c];
          if (val) {
            if (!colHasTrue[c][rowIndex]) {
              candidateValid = false;
              break;
            }
          } else {
            if (!colHasFalse[c][rowIndex]) {
              candidateValid = false;
              break;
            }
          }
        }

        if (!candidateValid) continue;

        currentGrid.add(candidateRow);
        solveRow(rowIndex + 1, currentGrid);
        currentGrid.removeLast();

        if (solutionsFound >= 2) return;
      }
    }

    solveRow(0, []);
    return solutionsFound;
  }

  static List<List<bool>> _generateLinePossibilities(int size, List<int> clues) {
    final results = <List<bool>>[];
    if (clues.isEmpty || (clues.length == 1 && clues[0] == 0)) {
      results.add(List<bool>.filled(size, false));
      return results;
    }

    void build(int clueIdx, int currentPos, List<bool> line) {
      if (clueIdx == clues.length) {
        results.add(List<bool>.from(line));
        return;
      }

      final blockLen = clues[clueIdx];
      final remainingCluesSum = clues.sublist(clueIdx + 1).fold<int>(0, (a, b) => a + b);
      final remainingGapCount = clues.length - 1 - clueIdx;
      final maxStart = size - (remainingCluesSum + remainingGapCount) - blockLen;

      for (int start = currentPos; start <= maxStart; start++) {
        for (int i = start; i < start + blockLen; i++) {
          line[i] = true;
        }

        final nextPos = start + blockLen + 1;
        build(clueIdx + 1, nextPos, line);

        for (int i = start; i < start + blockLen; i++) {
          line[i] = false;
        }
      }
    }

    build(0, 0, List<bool>.filled(size, false));
    return results;
  }

  bool _lineMatchesPossibilities(List<bool> line, List<List<bool>> possibilities) {
    for (final p in possibilities) {
      bool same = true;
      for (int i = 0; i < line.length; i++) {
        if (line[i] != p[i]) {
          same = false;
          break;
        }
      }
      if (same) return true;
    }
    return false;
  }
}
