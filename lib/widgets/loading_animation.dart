import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingAnimation extends ConsumerWidget {
  const LoadingAnimation({super.key, this.customHeight});

  final double? customHeight;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {

    final errorState = ref.watch(errorProvider);

    return SizedBox(
        height: customHeight ?? double.maxFinite,
        child: Column(
          children: [
            const LinearProgressIndicator(),
            Expanded(child: Center(child: Image.asset("assets/loading/InvoiceReadLoading.gif"))),
            Text(errorState, style: const TextStyle(color: Colors.red)),
      ],
    ));
  }
}

final errorProvider = StateProvider.autoDispose<String>((final ref) => "");
