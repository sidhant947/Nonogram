import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/progress_repository.dart';
import '../../../../domain/models/user_progress.dart';

class HomeViewModelState {
  const HomeViewModelState({
    this.progress,
    this.isLoading = false,
  });

  final UserProgress? progress;
  final bool isLoading;

  HomeViewModelState copyWith({
    UserProgress? progress,
    bool? isLoading,
  }) {
    return HomeViewModelState(
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeViewModelState> {
  HomeViewModel({required this.progressRepository})
      : super(const HomeViewModelState());

  final ProgressRepository progressRepository;

  Future<void> loadProgress() async {
    state = state.copyWith(isLoading: true);
    final progress = await progressRepository.getProgress();
    state = HomeViewModelState(progress: progress, isLoading: false);
  }
}
