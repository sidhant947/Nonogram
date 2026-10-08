import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

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
    this.randomSeed,
  });

  final int levelNumber;
  final bool isRandom;
  final String? randomDifficulty;
  final int? randomSeed;

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> {
  CellState _currentDrawMode = CellState.filled;
  int _pointerCount = 0;
  (int, int)? _dragStart;
  Axis? _dragAxis;
  Set<(int, int)> _dragCells = {};
  CellState? _dragTargetState;
  Timer? _longPressTimer;

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final vm = ref.read(gameViewModelProvider.notifier);
      if (widget.isRandom) {
        vm.loadRandomLevel(
          widget.randomDifficulty ?? 'Easy',
          seed: widget.randomSeed,
        );
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
    ref.watch(progressRepositoryProvider);
    final state = ref.watch(gameViewModelProvider);
    final vm = ref.read(gameViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.headingDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isRandom ? '' : 'LEVEL ${widget.levelNumber}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.headingDark,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColors.headingDark,
            ),
            tooltip: 'RESTART',
            onPressed: vm.resetLevel,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: state.isLoading || state.level == null
            ? Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
            : Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 90),
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
                          child: Listener(
                            onPointerDown: (_) => setState(() => _pointerCount++),
                            onPointerUp: (_) => setState(() => _pointerCount = (_pointerCount - 1).clamp(0, 10)),
                            onPointerCancel: (_) => setState(() => _pointerCount = (_pointerCount - 1).clamp(0, 10)),
                            child: InteractiveViewer(
                              minScale: 0.8,
                              maxScale: 4.0,
                              boundaryMargin: const EdgeInsets.all(40.0),
                              clipBehavior: Clip.none,
                              panEnabled: _pointerCount >= 2,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: _buildNonogramGrid(context, state, vm),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: state.isComplete
                            ? 210
                            : (ref.watch(progressRepositoryProvider).cycleModeEnabled
                                ? 16
                                : 75),
                      ),
                    ],
                  ),

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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      color: AppColors.subtext,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatTime(state.elapsedSeconds),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.subtext,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.touch_app_outlined,
                                      color: AppColors.subtext,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'MOVES: ${state.moveCount}',
                                      style: TextStyle(
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

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  icon: Icons.undo_rounded,
                                  label: 'UNDO',
                                  onPressed: state.canUndo && !state.isComplete
                                      ? vm.undo
                                      : null,
                                ),
                                _buildActionButton(
                                  icon: Icons.lightbulb_outline_rounded,
                                  label: 'HINT',
                                  iconColor: AppColors.gold,
                                  onPressed: state.isComplete
                                      ? null
                                      : vm.requestHint,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: state.isComplete
                          ? KeyedSubtree(
                              key: const ValueKey('completion_panel'),
                              child: _buildCompletionBottomPanel(
                                context,
                                state,
                                vm,
                              ),
                            )
                          : (!ref.watch(progressRepositoryProvider).cycleModeEnabled
                              ? KeyedSubtree(
                                  key: const ValueKey('mode_buttons'),
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
                                    padding: const EdgeInsets.only(
                                      top: 24,
                                      bottom: 16,
                                    ),
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
                                )
                              : const SizedBox.shrink(
                                  key: ValueKey('empty_bottom'),
                                )),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCompletionBottomPanel(
    BuildContext context,
    GameViewModelState state,
    GameViewModel vm,
  ) {
    return Container(
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'CONGRATULATIONS!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.headingDark,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          TangibleButton(
            text: widget.isRandom ? 'Play Again' : 'Next Level',
            height: 44,
            fontSize: 13,
            onPressed: () async {
              await vm.completeLevel();
              if (!context.mounted) return;
              if (widget.isRandom) {
                vm.loadRandomLevel(widget.randomDifficulty ?? 'Easy');
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GameView(levelNumber: widget.levelNumber + 1),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          TangibleButton(
            text: 'Home',
            isSecondary: true,
            icon: Icons.home_rounded,
            height: 44,
            fontSize: 13,
            onPressed: () async {
              await vm.completeLevel();
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
          TangibleButton(
            text: 'Buy Me a Coffee',
            isSecondary: true,
            icon: Icons.coffee_rounded,
            height: 44,
            fontSize: 13,
            onPressed: () async {
              final Uri url = Uri.parse('https://ko-fi.com/sidhant947');
              if (!await launchUrl(
                url,
                mode: LaunchMode.externalApplication,
              )) {
                throw Exception('Could not launch $url');
              }
            },
          ),
        ],
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
              color: isDisabled
                  ? AppColors.subtext.withValues(alpha: 0.4)
                  : (iconColor ?? AppColors.headingDark),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isDisabled
                    ? AppColors.subtext.withValues(alpha: 0.4)
                    : AppColors.headingDark,
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
      onTap: () {
        if (ref.read(progressRepositoryProvider).hapticsEnabled) {
          HapticFeedback.lightImpact();
        }
        setState(() => _currentDrawMode = mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (color.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                : AppColors.border,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white)
                  : color,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: isSelected
                    ? (color.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white)
                    : AppColors.headingDark,
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

    final maxColClueLen = level.colClues
        .map((c) => c.length)
        .fold(1, (a, b) => a > b ? a : b);
    final maxRowClueLen = level.rowClues
        .map((r) => r.length)
        .fold(1, (a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availWidth = constraints.maxWidth;
        final availHeight = constraints.maxHeight;

        // Dynamic scale calculation based on screen dimensions & grid size
        final double maxClueWidthRatio = 0.28;
        final double maxClueHeightRatio = 0.25;

        final estimatedCellSizeWidth =
            (availWidth * (1.0 - maxClueWidthRatio)) / size;
        final estimatedCellSizeHeight =
            (availHeight * (1.0 - maxClueHeightRatio)) / (size + 1);

        double cellSize =
            (estimatedCellSizeWidth < estimatedCellSizeHeight
                    ? estimatedCellSizeWidth
                    : estimatedCellSizeHeight)
                .floorToDouble();

        cellSize = cellSize.clamp(24.0, 68.0);

        final fontSize = (cellSize * 0.42).clamp(11.0, 18.0);
        final rowClueWidth = (maxRowClueLen * (fontSize * 0.9)).clamp(
          cellSize * 1.2,
          availWidth * maxClueWidthRatio,
        );
        final clueHeight = (maxColClueLen * (fontSize * 1.15)).clamp(
          cellSize * 1.2,
          availHeight * maxClueHeightRatio,
        );

        return FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) => _onGridPointerDown(
              event,
              rowClueWidth,
              clueHeight,
              cellSize,
              size,
              state,
              vm,
            ),
            onPointerMove: (event) => _onGridPointerMove(
              event,
              rowClueWidth,
              clueHeight,
              cellSize,
              size,
            ),
            onPointerUp: (event) => _onGridPointerUp(vm),
            onPointerCancel: (event) => _onGridPointerCancel(),
            child: Table(
              columnWidths: {
                0: FixedColumnWidth(rowClueWidth),
                for (int c = 0; c < size; c++) c + 1: FixedColumnWidth(cellSize),
              },
              children: [
                TableRow(
                  children: [
                    const SizedBox.shrink(),
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
                                .map(
                                  (val) => Text(
                                    '$val',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.subtext,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                  ],
                ),
                for (int r = 0; r < size; r++)
                  TableRow(
                    children: [
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
                                .map(
                                  (val) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0,
                                    ),
                                    child: Text(
                                      '$val',
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.headingDark,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      for (int c = 0; c < size; c++)
                        Container(
                          width: cellSize,
                          height: cellSize,
                          margin: const EdgeInsets.all(1.0),
                          decoration: BoxDecoration(
                            color: _getCellColor(r, c, state),
                            borderRadius: BorderRadius.circular(
                              size > 8 ? 4 : 6,
                            ),
                            border: Border.all(
                              color: state.hintCell == (r * size + c)
                                  ? AppColors.gold
                                  : AppColors.border,
                              width: state.hintCell == (r * size + c) ? 2.5 : 1,
                            ),
                          ),
                          child: _buildCellContent(
                            _getDisplayCellState(r, c, state),
                            cellSize,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  CellState _getDisplayCellState(int r, int c, GameViewModelState state) {
    if (_dragCells.contains((r, c)) && _dragTargetState != null) {
      return _dragTargetState!;
    }
    return state.board[r][c];
  }

  Color _getCellColor(int r, int c, GameViewModelState state) {
    final cellState = _getDisplayCellState(r, c, state);
    if (cellState == CellState.filled) {
      return AppColors.accent;
    }
    return AppColors.surface;
  }

  void _onGridPointerDown(
    PointerDownEvent event,
    double rowClueWidth,
    double clueHeight,
    double cellSize,
    int size,
    GameViewModelState state,
    GameViewModel vm,
  ) {
    if (state.isComplete || _pointerCount > 1) {
      _cancelDrag();
      return;
    }

    final double gridX = event.localPosition.dx - rowClueWidth;
    final double gridY = event.localPosition.dy - clueHeight;
    if (gridX < 0 || gridY < 0 || gridX >= size * cellSize || gridY >= size * cellSize) {
      return;
    }

    final int c = (gridX / cellSize).floor();
    final int r = (gridY / cellSize).floor();
    if (r < 0 || r >= size || c < 0 || c >= size) return;

    final cell = (r, c);
    _dragStart = cell;
    _dragAxis = null;

    final current = state.board[r][c];
    if (ref.read(progressRepositoryProvider).cycleModeEnabled) {
      if (current == CellState.empty) {
        _dragTargetState = CellState.filled;
      } else if (current == CellState.filled) {
        _dragTargetState = CellState.cross;
      } else {
        _dragTargetState = CellState.empty;
      }
    } else {
      if (current == _currentDrawMode) {
        _dragTargetState = CellState.empty;
      } else {
        _dragTargetState = _currentDrawMode;
      }
    }

    _dragCells = {cell};

    if (!ref.read(progressRepositoryProvider).cycleModeEnabled &&
        ref.read(progressRepositoryProvider).longPressToCrossEnabled) {
      _longPressTimer?.cancel();
      _longPressTimer = Timer(const Duration(milliseconds: 350), () {
        if (_dragStart == cell && _dragCells.length == 1) {
          if (ref.read(progressRepositoryProvider).hapticsEnabled) {
            HapticFeedback.mediumImpact();
          }
          final cur = state.board[r][c];
          _dragTargetState = cur == CellState.cross ? CellState.empty : CellState.cross;
          setState(() {});
        }
      });
    }

    setState(() {});
  }

  void _onGridPointerMove(
    PointerMoveEvent event,
    double rowClueWidth,
    double clueHeight,
    double cellSize,
    int size,
  ) {
    if (_pointerCount > 1) {
      _cancelDrag();
      return;
    }
    if (_dragStart == null || _dragTargetState == null) return;

    final double gridX = event.localPosition.dx - rowClueWidth;
    final double gridY = event.localPosition.dy - clueHeight;

    final int c = (gridX / cellSize).floor().clamp(0, size - 1);
    final int r = (gridY / cellSize).floor().clamp(0, size - 1);
    final (r0, c0) = _dragStart!;

    if (r != r0 || c != c0) {
      _longPressTimer?.cancel();
    }

    if (_dragAxis == null && (r != r0 || c != c0)) {
      _dragAxis = (c - c0).abs() >= (r - r0).abs()
          ? Axis.horizontal
          : Axis.vertical;
    }

    final newCells = <(int, int)>{};
    if (_dragAxis == Axis.horizontal) {
      final minC = c0 < c ? c0 : c;
      final maxC = c0 > c ? c0 : c;
      for (int k = minC; k <= maxC; k++) {
        newCells.add((r0, k));
      }
    } else if (_dragAxis == Axis.vertical) {
      final minR = r0 < r ? r0 : r;
      final maxR = r0 > r ? r0 : r;
      for (int k = minR; k <= maxR; k++) {
        newCells.add((k, c0));
      }
    } else {
      newCells.add((r0, c0));
    }

    if (newCells.length > _dragCells.length &&
        ref.read(progressRepositoryProvider).hapticsEnabled) {
      HapticFeedback.selectionClick();
    }

    setState(() {
      _dragCells = newCells;
    });
  }

  void _onGridPointerUp(GameViewModel vm) {
    _longPressTimer?.cancel();
    if (_dragStart != null && _dragCells.isNotEmpty && _dragTargetState != null) {
      final cellsToApply = _dragCells.toList();
      final target = _dragTargetState!;
      _dragStart = null;
      _dragCells = {};
      _dragTargetState = null;
      _dragAxis = null;
      setState(() {});
      vm.applyStroke(cellsToApply, target);
    } else {
      _cancelDrag();
    }
  }

  void _onGridPointerCancel() {
    _cancelDrag();
  }

  void _cancelDrag() {
    _longPressTimer?.cancel();
    if (_dragStart != null || _dragCells.isNotEmpty || _dragTargetState != null) {
      setState(() {
        _dragStart = null;
        _dragCells = {};
        _dragTargetState = null;
        _dragAxis = null;
      });
    }
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
