import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/tangible_button.dart';
import '../../game/views/game_view.dart';
import '../../how_to_play/views/how_to_play_view.dart';
import '../../level_select/views/level_select_view.dart';
import '../../multiplayer/views/multiplayer_view.dart';
import '../../settings/views/settings_view.dart';
import '../../../providers.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeViewModelProvider.notifier).loadProgress());
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    double iconSize = 20,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        if (ref.read(progressRepositoryProvider).hapticsEnabled) {
          HapticFeedback.lightImpact();
        }
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white24,
            width: 1.0,
          ),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ?? AppColors.headingDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Top Action Row (App Bar)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleButton(
                    icon: Icons.star_rounded,
                    iconColor: AppColors.gold,
                    onTap: () => _launchUrl('https://github.com/sidhant947/Nonogram'),
                  ),
                  if (state.progress != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white24,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        'LEVEL ${state.progress!.currentLevel}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.headingDark,
                          letterSpacing: 0.8,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  _circleButton(
                    icon: Icons.favorite_rounded,
                    iconColor: const Color(0xFFEF4444),
                    onTap: () => _launchUrl('https://ko-fi.com/sidhant947'),
                  ),
                ],
              ),
              const Spacer(flex: 3),

              // Game Title
              Text(
                'NONOGRAM',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accent,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PICTURE LOGIC PUZZLE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.subtext,
                  letterSpacing: 1.5,
                ),
              ),

              const Spacer(flex: 4),

              // Play Button (Primary CTA)
              TangibleButton(
                text: 'Play',
                onPressed: state.isLoading
                    ? null
                    : () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GameView(levelNumber: state.progress?.currentLevel ?? 1),
                          ),
                        );
                        ref.read(homeViewModelProvider.notifier).loadProgress();
                      },
              ),

              const SizedBox(height: 16),

              // Level Select Button
              TangibleButton(
                text: 'Select Level',
                isSecondary: true,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LevelSelectView(),
                    ),
                  );
                  ref.read(homeViewModelProvider.notifier).loadProgress();
                },
              ),

              const SizedBox(height: 16),

              // Random Puzzle Button
              TangibleButton(
                text: 'Random Puzzle',
                isSecondary: true,
                onPressed: () => _showDifficultyDialog(context),
              ),

              const SizedBox(height: 16),

              // Multiplayer Button
              TangibleButton(
                text: 'Multiplayer',
                isSecondary: true,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MultiplayerView(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // How to Play Button
              TangibleButton(
                text: 'How to Play',
                isSecondary: true,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HowToPlayView(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Settings Button
              TangibleButton(
                text: 'Settings',
                isSecondary: true,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsView(),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white24,
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'CHOOSE DIFFICULTY',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.headingDark,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Play a dynamically generated Nonogram puzzle.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subtext,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Builder(
                builder: (context) {
                  Widget diffButton(String label, String diff, {bool isSecondary = false}) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TangibleButton(
                        text: label,
                        isSecondary: isSecondary,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameView(
                                levelNumber: 0,
                                isRandom: true,
                                randomDifficulty: diff,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      diffButton('Easy', 'Easy'),
                      diffButton('Medium', 'Medium', isSecondary: true),
                      diffButton('Hard', 'Hard', isSecondary: true),
                      diffButton('Master', 'Master', isSecondary: true),
                      diffButton('Expert', 'Expert', isSecondary: true),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    color: AppColors.subtext,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
