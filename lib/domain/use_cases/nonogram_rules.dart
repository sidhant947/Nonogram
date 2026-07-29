import '../models/game_level.dart';
import '../../ui/features/game/view_models/game_view_model.dart';

class NonogramRules {
  NonogramRules._();

  /// Check if the player's current board matches the solution requirements
  static bool isComplete(List<List<CellState>> board, GameLevel level) {
    final size = level.gridSize;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final isFilledSolution = level.solutionGrid[r][c];
        final isFilledPlayer = board[r][c] == CellState.filled;
        if (isFilledSolution != isFilledPlayer) {
          return false;
        }
      }
    }
    return true;
  }

  /// Compute conflicts matrix (cells incorrectly filled where solution expects empty)
  static List<List<bool>> computeConflicts(
    List<List<CellState>> board,
    GameLevel level,
  ) {
    final size = level.gridSize;
    final conflicts = List.generate(
      size,
      (_) => List<bool>.filled(size, false),
    );

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        // Highlight cell as conflict if filled by player but solution is empty
        if (board[r][c] == CellState.filled && !level.solutionGrid[r][c]) {
          conflicts[r][c] = true;
        }
      }
    }

    return conflicts;
  }

  /// Suggest a hint: returns [row, col] of an unrevealed or incorrect cell
  static List<int>? suggestHint(
    List<List<CellState>> board,
    GameLevel level,
  ) {
    final size = level.gridSize;

    // First look for incorrectly filled cells
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (board[r][c] == CellState.filled && !level.solutionGrid[r][c]) {
          return [r, c];
        }
      }
    }

    // Next look for missing filled cells
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (level.solutionGrid[r][c] && board[r][c] != CellState.filled) {
          return [r, c];
        }
      }
    }

    return null;
  }
}
