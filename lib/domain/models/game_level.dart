import 'package:flutter/foundation.dart';

@immutable
class GameLevel {
  const GameLevel({
    required this.levelNumber,
    required this.gridSize,
    required this.solutionGrid,
    required this.rowClues,
    required this.colClues,
  });

  final int levelNumber;
  final int gridSize;
  /// 2D boolean matrix where true = filled cell, false = empty cell
  final List<List<bool>> solutionGrid;
  /// Sequence of contiguous filled block lengths for each row
  final List<List<int>> rowClues;
  /// Sequence of contiguous filled block lengths for each column
  final List<List<int>> colClues;

  GameLevel copyWith({
    int? levelNumber,
    int? gridSize,
    List<List<bool>>? solutionGrid,
    List<List<int>>? rowClues,
    List<List<int>>? colClues,
  }) {
    return GameLevel(
      levelNumber: levelNumber ?? this.levelNumber,
      gridSize: gridSize ?? this.gridSize,
      solutionGrid: solutionGrid ?? this.solutionGrid,
      rowClues: rowClues ?? this.rowClues,
      colClues: colClues ?? this.colClues,
    );
  }
}
