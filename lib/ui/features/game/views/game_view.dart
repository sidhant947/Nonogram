import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/tangible_button.dart';
import '../../../providers.dart';
import '../view_models/game_view_model.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({
    super.key,
    required this.levelNumber,
    this.isRandom = false,
    this.randomDifficulty,
  });

  final int levelNumber;
  final bool isRandom;
  final String? randomDifficulty;

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> {
  CellState _currentDrawMode = CellState.filled;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final vm = ref.read(gameViewModelProvider.notifier);
      if (widget.isRandom) {
        vm.loadRandomLevel(widget.randomDifficulty ?? 'Easy');
      } else {
        vm.loadLevel(widget.levelNumber);
      }
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameViewModelProvider);
    final vm = ref.read(gameViewModelProvider.notifier);

    ref.listen<GameViewModelState>(gameViewModelProvider, (previous, next) {
      if ((previous == null || !previous.isComplete) && next.isComplete) {
        _showCompletionDialog(context, next, vm);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.headingDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isRandom ? '' : 'LEVEL ${widget.levelNumber}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.headingDark,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: state.isLoading || state.level == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
            : Stack(
                children: [
                  // Layer 1: Scalable Nonogram Board Area with Edge Dissolve Mask
                  Column(
                    children: [
                      const SizedBox(height: 90), // Reserved top space
                      Expanded(
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black,
                                Colors.black,
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.08, 0.92, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: InteractiveViewer(
                            minScale: 0.8,
                            maxScale: 4.0,
                            boundaryMargin: const EdgeInsets.all(40.0),
                            clipBehavior: Clip.none,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: _buildNonogramGrid(context, state, vm),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 75), // Reserved bottom space
                    ],
                  ),

                  // Layer 2: Top Controls with Ultra-Smooth Dissolve Gradient
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.bg,
                            AppColors.bg.withValues(alpha: 0.95),
                            AppColors.bg.withValues(alpha: 0.6),
                            AppColors.bg.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.55, 0.8, 1.0],
                        ),
                      ),
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Timer and Move Count header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, color: AppColors.subtext, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatTime(state.elapsedSeconds),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.subtext,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.touch_app_outlined, color: AppColors.subtext, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'MOVES: ${state.moveCount}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.subtext,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Action Row: Undo, Hint, Restart
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  icon: Icons.undo_rounded,
                                  label: 'UNDO',
                                  onPressed: state.canUndo && !state.isComplete ? vm.undo : null,
                                ),
                                _buildActionButton(
                                  icon: Icons.lightbulb_outline_rounded,
                                  label: 'HINT',
                                  iconColor: AppColors.gold,
                                  onPressed: state.isComplete ? null : vm.requestHint,
                                ),
                                _buildActionButton(
                                  icon: Icons.refresh_rounded,
                                  label: 'RESTART',
                                  onPressed: vm.resetLevel,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Layer 3: Bottom Controls with Ultra-Smooth Dissolve Gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.bg,
                            AppColors.bg.withValues(alpha: 0.95),
                            AppColors.bg.withValues(alpha: 0.6),
                            AppColors.bg.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.55, 0.8, 1.0],
                        ),
                      ),
                      padding: const EdgeInsets.only(top: 24, bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildModeButton(
                            mode: CellState.filled,
                            icon: Icons.square,
                            label: 'FILL',
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 24),
                          _buildModeButton(
                            mode: CellState.cross,
                            icon: Icons.close_rounded,
                            label: 'CROSS (X)',
                            color: AppColors.cellCross,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showCompletionDialog(
    BuildContext context,
    GameViewModelState state,
    GameViewModel vm,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.border,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.gold,
                size: 56,
              ),
              const SizedBox(height: 12),
              const Text(
                'LEVEL COMPLETED!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.headingDark,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Moves: ${state.moveCount}  •  Time: ${_formatTime(state.elapsedSeconds)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.subtext,
                ),
              ),
              const SizedBox(height: 24),

              // 1. Next Level Button
              TangibleButton(
                text: widget.isRandom ? 'Play Again' : 'Next Level',
                onPressed: () async {
                  await vm.completeLevel();
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  if (widget.isRandom) {
                    vm.loadRandomLevel(widget.randomDifficulty ?? 'Easy');
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameView(levelNumber: widget.levelNumber + 1),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 12),

              // 2. Buy Me a Coffee Button
              TangibleButton(
                text: 'Buy Me a Coffee',
                isSecondary: true,
                icon: Icons.coffee_rounded,
                onPressed: () async {
                  final Uri url = Uri.parse('https://ko-fi.com/sidhant947');
                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    throw Exception('Could not launch $url');
                  }
                },
              ),

              const SizedBox(height: 12),

              // 3. Home Button
              TangibleButton(
                text: 'Home',
                isSecondary: true,
                icon: Icons.home_rounded,
                onPressed: () async {
                  await vm.completeLevel();
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    Color? iconColor,
  }) {
    final bool isDisabled = onPressed == null;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDisabled ? AppColors.subtext.withOpacity(0.4) : (iconColor ?? AppColors.headingDark),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isDisabled ? AppColors.subtext.withOpacity(0.4) : AppColors.headingDark,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required CellState mode,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _currentDrawMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _currentDrawMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : AppColors.border,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? (color == Colors.white || color == AppColors.accent ? Colors.black : Colors.white) : color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: isSelected ? (color == Colors.white || color == AppColors.accent ? Colors.black : Colors.white) : AppColors.headingDark,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNonogramGrid(
    BuildContext context,
    GameViewModelState state,
    GameViewModel vm,
  ) {
    final level = state.level!;
    final size = level.gridSize;

    final maxColClueLen = level.colClues.map((c) => c.length).fold(1, (a, b) => a > b ? a : b);
    final maxRowClueLen = level.rowClues.map((r) => r.length).fold(1, (a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availWidth = constraints.maxWidth;
        final availHeight = constraints.maxHeight;

        // Dynamic scale calculation based on screen dimensions & grid size
        final double maxClueWidthRatio = 0.28;
        final double maxClueHeightRatio = 0.25;

        final estimatedCellSizeWidth = (availWidth * (1.0 - maxClueWidthRatio)) / size;
        final estimatedCellSizeHeight = (availHeight * (1.0 - maxClueHeightRatio)) / (size + 1);

        double cellSize = (estimatedCellSizeWidth < estimatedCellSizeHeight
                ? estimatedCellSizeWidth
                : estimatedCellSizeHeight)
            .floorToDouble();

        cellSize = cellSize.clamp(24.0, 68.0);

        final fontSize = (cellSize * 0.42).clamp(11.0, 18.0);
        final rowClueWidth = (maxRowClueLen * (fontSize * 0.9)).clamp(cellSize * 1.2, availWidth * maxClueWidthRatio);
        final clueHeight = (maxColClueLen * (fontSize * 1.15)).clamp(cellSize * 1.2, availHeight * maxClueHeightRatio);

        return FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: Table(
            columnWidths: {
              0: FixedColumnWidth(rowClueWidth),
              for (int c = 0; c < size; c++) c + 1: FixedColumnWidth(cellSize),
            },
            children: [
              // Top Header Row for Column Clues
              TableRow(
                children: [
                  const SizedBox.shrink(), // Empty top-left corner
                  for (int c = 0; c < size; c++)
                    Container(
                      height: clueHeight,
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 4),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: level.colClues[c]
                              .map((val) => Text(
                                    '$val',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.subtext,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                ],
              ),

              // Rows with Row Clues + Board Cells
              for (int r = 0; r < size; r++)
                TableRow(
                  children: [
                    // Row Clue
                    Container(
                      height: cellSize,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: level.rowClues[r]
                              .map((val) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                    child: Text(
                                      '$val',
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.headingDark,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          ),
                      ),
                    ),

                    // Cells in row
                    for (int c = 0; c < size; c++)
                      GestureDetector(
                        onTap: () {
                          if (state.board[r][c] == _currentDrawMode) {
                            vm.setCellState(r, c, CellState.empty);
                          } else {
                            vm.setCellState(r, c, _currentDrawMode);
                          }
                        },
                        child: Container(
                          width: cellSize,
                          height: cellSize,
                          margin: const EdgeInsets.all(1.0),
                          decoration: BoxDecoration(
                            color: _getCellColor(r, c, state),
                            borderRadius: BorderRadius.circular(size > 8 ? 4 : 6),
                            border: Border.all(
                              color: state.hintCell == (r * size + c)
                                  ? AppColors.gold
                                  : AppColors.border,
                              width: state.hintCell == (r * size + c) ? 2.5 : 1,
                            ),
                          ),
                          child: _buildCellContent(state.board[r][c], cellSize),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getCellColor(int r, int c, GameViewModelState state) {
    final cellState = state.board[r][c];
    if (cellState == CellState.filled) {
      return AppColors.accent;
    }
    return AppColors.surface;
  }

  Widget? _buildCellContent(CellState cellState, double cellSize) {
    if (cellState == CellState.cross) {
      return Icon(
        Icons.close_rounded,
        size: (cellSize * 0.65).clamp(12.0, 36.0),
        color: AppColors.cellCross,
      );
    }
    return null;
  }
}
