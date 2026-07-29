import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HowToPlayView extends StatelessWidget {
  const HowToPlayView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'HOW TO PLAY',
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
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildRuleCard(
              number: '1',
              title: 'REVEAL THE PICTURE',
              description:
                  'Nonograms are logic puzzles where grid cells must be filled or left blank according to numbers at the side of the grid.',
              icon: Icons.grid_on_rounded,
            ),
            const SizedBox(height: 16),
            _buildRuleCard(
              number: '2',
              title: 'READ THE CLUES',
              description:
                  'The numbers show sequences of filled cells in that row or column. E.g., "3 1" means a block of 3 filled cells followed by 1 filled cell.',
              icon: Icons.format_list_numbered_rounded,
            ),
            const SizedBox(height: 16),
            _buildRuleCard(
              number: '3',
              title: 'MARK BLANK SPACES',
              description:
                  'Tap a cell to fill it, or mark empty spaces with an "X" to keep track of spaces that cannot be filled.',
              icon: Icons.close_rounded,
            ),
            const SizedBox(height: 16),
            _buildRuleCard(
              number: '4',
              title: 'COMPLETE THE GRID',
              description:
                  'Solve the entire puzzle using logic without guessing to reveal the hidden pixel image!',
              icon: Icons.emoji_events_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required String number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.accent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number. $title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.headingDark,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.subtext,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
