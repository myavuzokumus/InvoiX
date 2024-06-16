import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingAnimation extends ConsumerWidget {
  const LoadingAnimation({super.key, this.customHeight, this.subsControl = false});

  final double? customHeight;
  final bool subsControl;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {

    final errorState = ref.watch(errorProvider);

    return SizedBox(
        height: customHeight ?? double.maxFinite,
        child: Column(
          children: [
            const LinearProgressIndicator(),
            Expanded(child: Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/loading/InvoiceReadLoading.gif"),
                Text(errorState.errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                if (!errorState.subs && subsControl) const Text("Please check your subscription status!", style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
              ],
            ))),

      ],
    ));
  }
}

class ErrorState {
  ErrorState({required this.errorMessage, this.subs = true});

  String errorMessage;
  bool subs;
}

final errorProvider = StateProvider.autoDispose<ErrorState>((final ref) => ErrorState(errorMessage: ""));