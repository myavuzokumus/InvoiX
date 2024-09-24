import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErrorState {
  ErrorState({required this.errorMessage});

  final String errorMessage;

  ErrorState copyWith({final String? errorMessage}) {
    return ErrorState(
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final errorProvider = StateProvider.autoDispose<ErrorState>(
        (final ref) => ErrorState(errorMessage: ""));
