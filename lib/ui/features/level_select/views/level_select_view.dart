import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers.dart';
import '../../game/views/game_view.dart';

class LevelSelectView extends ConsumerWidget {
  const LevelSelectView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final highestCompleted = homeState.progress?.highestLevelCompleted ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SELECT LEVEL',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.headingDark,
            letterSpacing: 1.0,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.headingDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: 100,
          itemBuilder: (context, index) {
            final levelNumber = index + 1;
            final isUnlocked = levelNumber <= highestCompleted + 1;
            final isCompleted = levelNumber <= highestCompleted;

            return GestureDetector(
              onTap: isUnlocked
                  ? () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameView(levelNumber: levelNumber),
                        ),
                      );
                      ref.read(homeViewModelProvider.notifier).loadProgress();
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.accent.withOpacity(0.2)
                      : (isUnlocked ? AppColors.surface : AppColors.surface.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.accent
                        : (isUnlocked ? AppColors.border : Colors.transparent),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: isUnlocked
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$levelNumber',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isCompleted ? AppColors.accent : AppColors.headingDark,
                            ),
                          ),
                          if (isCompleted)
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: AppColors.accent,
                            ),
                        ],
                      )
                    : const Icon(
                        Icons.lock_rounded,
                        color: AppColors.subtext,
                        size: 20,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
