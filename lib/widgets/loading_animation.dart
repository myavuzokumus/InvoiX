import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/states/error_state.dart';
import 'package:invoix/widgets/no_internet_connection.dart';

class LoadingAnimation extends ConsumerWidget {
  const LoadingAnimation({super.key, this.customHeight});

  final double? customHeight;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final errorState = ref.watch(errorProvider);
    final bool isLandScape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return SizedBox(
        height: customHeight ?? double.maxFinite,
        child: isLandScape
            ? SingleChildScrollView(child: NewWidget(errorState: errorState))
            : NewWidget(errorState: errorState));
  }
}

class NewWidget extends StatelessWidget {
  const NewWidget({
    super.key,
    required this.errorState,
  });

  final ErrorState errorState;

  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const LinearProgressIndicator(),
        Image.asset("assets/loading/InvoiceReadLoading.gif",
            height: MediaQuery.of(context).size.height / 5),
        Column(
          children: [
            errorWidgetSelector(),
          ],
        ),
      ],
    );
  }

  Widget errorWidgetSelector() {
    switch (errorState.errorMessage) {
      case "No Internet Connection":
        return const NoInternetConnection();
      case "No Use Left":
        return const Text("You have no more rights to use AI features.",
            style: TextStyle(
                color: Colors.red, fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center);
      default:
        return const SizedBox();
    }
  }
}

