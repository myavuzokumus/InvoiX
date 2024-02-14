import 'package:flutter/material.dart';
import 'package:invoix/widgets/loading_animation.dart';

class AIButton extends StatelessWidget {
  const AIButton({super.key});

  @override
  Widget build(final BuildContext context) {
    return IconButton.outlined(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.35),
        side: const BorderSide(width: 1.5, color: Colors.orangeAccent),
      ),
      onPressed: () {
        showModalBottomSheet<void>(
          showDragHandle: true,
          context: context,
          builder: (final BuildContext context) {
            return SizedBox(
              height: 200,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 24, right: 24),
                child: LayoutBuilder(
                  builder: (final BuildContext context, final BoxConstraints constraints) {
                    return Card(elevation: 16, child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            LoadingAnimation(customHeight: constraints.maxHeight - 72),
                            const Text('Very soon, it will be possible to analyze invoices using AI.', textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ));
                  },
                ),
              ),
            );
          },
        );
      },
      icon: const Text("✨", style: TextStyle(fontSize: 17)),
      tooltip: 'Analyze it with AI',
    );
  }
}
