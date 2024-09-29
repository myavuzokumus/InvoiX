import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingState {
  LoadingState({required this.message});

  final String message;

  LoadingState copyWith({final String? message}) {
    return LoadingState(
      message: message ?? this.message,
    );
  }
}

final loadingProvider = StateProvider.autoDispose<LoadingState>(
        (final ref) => LoadingState(message: ""));
