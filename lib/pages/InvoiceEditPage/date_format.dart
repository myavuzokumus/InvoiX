import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoix/utils/date_parser.dart';

enum DateFormatSegment { uk, us }
DateFormatSegment dateFormatView = DateFormatSegment.uk;

class DateFormatSegmented extends StatefulWidget {
  const DateFormatSegmented({super.key, this.onChange});

  final Function(DateFormatSegment)? onChange;

  @override
  State<DateFormatSegmented> createState() => _DateFormatSegmentedState();
}

class _DateFormatSegmentedState extends State<DateFormatSegmented> {
  @override
  Widget build(final BuildContext context) {
    return SegmentedButton<DateFormatSegment>(
      segments: const <ButtonSegment<DateFormatSegment>>[
        ButtonSegment<DateFormatSegment>(
            value: DateFormatSegment.uk,
            label: Text('UK Format'),
            icon: Icon(Icons.today)
        ),
        ButtonSegment<DateFormatSegment>(
            value: DateFormatSegment.us,
            label: Text('US Format'),
            icon: Icon(Icons.date_range)
        ),
      ],
      selected: <DateFormatSegment>{dateFormatView},
      onSelectionChanged: (final Set<DateFormatSegment> newSelection) {
        setState(() {
          dateFormatView = newSelection.first;
          if (dateFormatView == DateFormatSegment.us) {
            dateFormat = DateFormat("MM-dd-yyyy");
          } else {
            dateFormat = DateFormat("dd-MM-yyyy");
          }
        });
        if (widget.onChange != null) {
          widget.onChange!(dateFormatView);
        }
      },
    );
  }
}
