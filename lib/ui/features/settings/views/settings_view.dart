import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/tangible_button.dart';
import '../../../providers.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  void _showResetConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFEF4444),
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'RESET PROGRESS?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.headingDark,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to reset all your game progress? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subtext,
                ),
              ),
              const SizedBox(height: 24),
              TangibleButton(
                text: 'Reset Progress',
                onPressed: () async {
                  await ref.read(progressRepositoryProvider).resetProgress();
                  ref.read(homeViewModelProvider.notifier).loadProgress();
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All progress has been reset.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.headingDark,
            letterSpacing: 1.0,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.headingDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                        title: Text(
                          'Theme',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.headingDark,
                            letterSpacing: 0.8,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              _buildThemeOption(
                                ref: ref,
                                label: 'Light',
                                mode: 'light',
                                icon: Icons.light_mode_rounded,
                              ),
                              const SizedBox(width: 8),
                              _buildThemeOption(
                                ref: ref,
                                label: 'Dark',
                                mode: 'dark',
                                icon: Icons.dark_mode_rounded,
                              ),
                              const SizedBox(width: 8),
                              _buildThemeOption(
                                ref: ref,
                                label: 'System',
                                mode: 'system',
                                icon: Icons.brightness_auto_rounded,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(color: AppColors.border, height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        title: Text(
                          'Haptic Feedback',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.headingDark,
                            letterSpacing: 0.8,
                          ),
                        ),
                        trailing: Switch(
                          value: ref.watch(progressRepositoryProvider).hapticsEnabled,
                          activeThumbColor: Colors.white,
                          activeTrackColor: Colors.grey[700],
                          inactiveThumbColor: AppColors.subtext,
                          inactiveTrackColor: AppColors.bg,
                          onChanged: (val) {
                            ref.read(progressRepositoryProvider).toggleHaptics();
                          },
                        ),
                      ),
                      Divider(color: AppColors.border, height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        title: Text(
                          'Long Press to Cross',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.headingDark,
                            letterSpacing: 0.8,
                          ),
                        ),
                        trailing: Switch(
                          value: ref.watch(progressRepositoryProvider).longPressToCrossEnabled,
                          activeThumbColor: Colors.white,
                          activeTrackColor: Colors.grey[700],
                          inactiveThumbColor: AppColors.subtext,
                          inactiveTrackColor: AppColors.bg,
                          onChanged: (val) {
                            ref.read(progressRepositoryProvider).toggleLongPressToCross();
                          },
                        ),
                      ),
                      Divider(color: AppColors.border, height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        title: Text(
                          'Cycle Mode',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.headingDark,
                            letterSpacing: 0.8,
                          ),
                        ),
                        trailing: Switch(
                          value: ref.watch(progressRepositoryProvider).cycleModeEnabled,
                          activeThumbColor: Colors.white,
                          activeTrackColor: Colors.grey[700],
                          inactiveThumbColor: AppColors.subtext,
                          inactiveTrackColor: AppColors.bg,
                          onChanged: (val) {
                            ref.read(progressRepositoryProvider).toggleCycleMode();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TangibleButton(
                text: 'Reset Progress',
                isSecondary: true,
                icon: Icons.restore_rounded,
                onPressed: () => _showResetConfirmationDialog(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required WidgetRef ref,
    required String label,
    required String mode,
    required IconData icon,
  }) {
    final currentMode = ref.watch(progressRepositoryProvider).themeMode;
    final isSelected = currentMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (ref.read(progressRepositoryProvider).hapticsEnabled) {
            HapticFeedback.selectionClick();
          }
          ref.read(progressRepositoryProvider).setThemeMode(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (AppColors.accent.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                  : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? (AppColors.accent.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                    : AppColors.subtext,
              ),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isSelected
                      ? (AppColors.accent.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                      : AppColors.headingDark,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
