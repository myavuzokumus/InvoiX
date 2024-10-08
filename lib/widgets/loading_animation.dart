import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingAnimation extends ConsumerWidget {
  const LoadingAnimation({super.key, this.customHeight, this.subsControl = false});

  final double? customHeight;
  final bool subsControl;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {

    final errorState = ref.watch(errorProvider);
    final bool isLandScape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return SizedBox(
        height: customHeight ?? double.maxFinite,
        child: isLandScape ? SingleChildScrollView(child: NewWidget(errorState: errorState, subsControl: subsControl)) : NewWidget(errorState: errorState, subsControl: subsControl));
  }
}

class NewWidget extends StatelessWidget {
  const NewWidget({
    super.key,
    required this.errorState,
    required this.subsControl,
  });

  final ErrorState errorState;
  final bool subsControl;

  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const LinearProgressIndicator(),
        Image.asset("assets/loading/InvoiceReadLoading.gif", height: MediaQuery.of(context).size.height / 5),
        Column(
          children: [
            if (!errorState.subs && subsControl) const Text("Please check your subscription status!", style: TextStyle(color: Colors.red, fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text(errorState.errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          ],
        ),
      ],
    );
  }
}

class ErrorState {
  ErrorState({required this.errorMessage, this.subs = true});

  final String errorMessage;
  final bool subs;

  ErrorState copyWith({final String? errorMessage, final bool? subs}) {
    return ErrorState(
      errorMessage: errorMessage ?? this.errorMessage,
      subs: subs ?? this.subs,
    );
  }
}

final errorProvider = StateProvider.autoDispose<ErrorState>((final ref) => ErrorState(errorMessage: ""));
