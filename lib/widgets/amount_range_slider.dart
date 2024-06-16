import 'package:flutter/material.dart';

class AmountRangeSlider extends StatefulWidget {
  final double minAmount;
  final double maxAmount;
  final Function(double, double) onAmountRangeChanged;

  const AmountRangeSlider({super.key,
    required this.minAmount,
    required this.maxAmount,
    required this.onAmountRangeChanged,
  });

  @override
  State<AmountRangeSlider> createState() => _AmountRangeSliderState();
}

class _AmountRangeSliderState extends State<AmountRangeSlider> {
  late RangeValues _currentRangeValues;

  @override
  void initState() {
    super.initState();
    _currentRangeValues = RangeValues(widget.minAmount, widget.maxAmount);
  }

  @override
  void didUpdateWidget(final AmountRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minAmount != widget.minAmount || oldWidget.maxAmount != widget.maxAmount) {
      _currentRangeValues = RangeValues(widget.minAmount, widget.maxAmount);
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        const Opacity(opacity: 0.75,
        child: Text("Amount Range", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),)),
        RangeSlider(
        values: _currentRangeValues,
        min: widget.minAmount,
        max: widget.maxAmount,
        divisions: 10,
        labels: RangeLabels(
          _currentRangeValues.start.round().toString(),
          _currentRangeValues.end.round().toString(),
        ),
        onChanged: (final RangeValues values) {
          setState(() {
            _currentRangeValues = values;
            widget.onAmountRangeChanged(values.start, values.end);
          });
        },
      ),
      ]
    );
  }
}
