import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/repositories/progress_repository.dart';
import 'data/services/hive_service.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/providers.dart';
import 'ui/features/home/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  final progressRepository = ProgressRepository(hiveService);
  await progressRepository.getProgress();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
        progressRepositoryProvider.overrideWith((ref) => progressRepository),
      ],
      child: const NonogramApp(),
    ),
  );
}

class NonogramApp extends ConsumerWidget {
  const NonogramApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressRepositoryProvider);
    final themeModeStr = progress.themeMode;
    final platformBrightness = MediaQuery.maybePlatformBrightnessOf(context) ??
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    progress.updateAppColors(platformBrightness);

    final ThemeMode themeMode;
    if (themeModeStr == 'light') {
      themeMode = ThemeMode.light;
    } else if (themeModeStr == 'dark') {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.system;
    }

    return MaterialApp(
      title: 'Nonogram',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
