import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/states/loading_state.dart';

class LoadingAnimation extends ConsumerWidget {
  const LoadingAnimation({super.key, this.customHeight, this.message});

  final String? message;
  final double? customHeight;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final loadingState = ref.watch(loadingProvider);
    final bool isLandScape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return SizedBox(
        height: customHeight ?? double.maxFinite,
        child: isLandScape
            ? SingleChildScrollView(child: addition(context, message, loadingState))
            : addition(context, message, loadingState)
    );
  }

  Widget addition(final context, final String? message, final loadingState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const LinearProgressIndicator(),
        Column(
          children: [
            Image.asset("assets/loading/InvoiceReadLoading.gif",
                height: MediaQuery.of(context).size.height / 5.5),
            message == null
                ? const SizedBox() : Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        Text(loadingState.message,
            style: const TextStyle(
                color: Colors.red,
                fontSize: 32,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
      ],
    );
  }
}
