import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/tangible_button.dart';
import '../../game/views/game_view.dart';

class MultiplayerView extends ConsumerStatefulWidget {
  const MultiplayerView({super.key});

  @override
  ConsumerState<MultiplayerView> createState() => _MultiplayerViewState();
}

class _MultiplayerViewState extends ConsumerState<MultiplayerView> {
  static const List<String> _difficulties = [
    'Easy',
    'Medium',
    'Hard',
    'Master',
    'Expert',
  ];

  String _selectedDifficulty = 'Easy';
  late int _seed;
  late final TextEditingController _codeController;
  String? _inputError;

  @override
  void initState() {
    super.initState();
    _seed = _generateSeed();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  int _generateSeed() => Random().nextInt(900000) + 100000;

  String get _roomCode => '$_selectedDifficulty-$_seed';

  void _joinGame(String rawCode) {
    final trimmed = rawCode.trim();
    final parts = trimmed.split('-');
    if (parts.length != 2) {
      setState(() => _inputError = 'Format: Difficulty-Code (e.g. Easy-123456)');
      return;
    }

    final diff = _difficulties.firstWhere(
      (d) => d.toLowerCase() == parts[0].toLowerCase(),
      orElse: () => '',
    );
    final seed = int.tryParse(parts[1]);

    if (diff.isEmpty || seed == null) {
      setState(() => _inputError = 'Invalid code');
      return;
    }

    setState(() => _inputError = null);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameView(
          levelNumber: 0,
          isRandom: true,
          randomDifficulty: diff,
          randomSeed: seed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'MULTIPLAYER',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.headingDark,
            letterSpacing: 1.0,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.headingDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DIFFICULTY',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.subtext,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _difficulties.map((diff) {
                        final isSelected = diff == _selectedDifficulty;
                        return ChoiceChip(
                          label: Text(
                            diff,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black : AppColors.headingDark,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.accent,
                          backgroundColor: AppColors.bg,
                          side: BorderSide(
                            color: isSelected ? AppColors.accent : AppColors.border,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedDifficulty = diff;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.0),
                ),
                child: Column(
                  children: [
                    Text(
                      'YOUR ROOM CODE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.subtext,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _roomCode,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TangibleButton(
                            text: 'Copy Code',
                            icon: Icons.copy_rounded,
                            isSecondary: true,
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _roomCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Code copied to clipboard!'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.refresh_rounded, color: AppColors.headingDark),
                          onPressed: () => setState(() => _seed = _generateSeed()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TangibleButton(
                      text: 'Start Puzzle',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameView(
                              levelNumber: 0,
                              isRandom: true,
                              randomDifficulty: _selectedDifficulty,
                              randomSeed: _seed,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'JOIN WITH CODE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.subtext,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _codeController,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.headingDark,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'e.g. Easy-123456',
                        hintStyle: TextStyle(
                          color: AppColors.subtext.withValues(alpha: 0.6),
                        ),
                        errorText: _inputError,
                        filled: true,
                        fillColor: AppColors.bg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.accent, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.paste_rounded, color: AppColors.subtext),
                          onPressed: () async {
                            final data = await Clipboard.getData('text/plain');
                            if (data?.text != null) {
                              _codeController.text = data!.text!.trim();
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TangibleButton(
                      text: 'Join Puzzle',
                      isSecondary: true,
                      onPressed: () => _joinGame(_codeController.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
