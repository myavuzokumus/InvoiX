import 'package:flutter/material.dart';
import 'package:invoix/utils/date_parser.dart';

class CustomDateRangePicker extends StatefulWidget {
  final Function(DateTime, DateTime) onDateRangeChanged;
  final DateTimeRange? initialTimeRange;

  const CustomDateRangePicker({super.key, required this.onDateRangeChanged, this.initialTimeRange});

  @override
  State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {

  late final TextEditingController dateTextController;
  late DateTimeRange initialDateTime;

  @override
  void initState() {
    dateTextController = TextEditingController();
    if (widget.initialTimeRange != null) {
      initialDateTime = widget.initialTimeRange!;
      dateTextController.text = "${dateFormat.format(initialDateTime.start)} - ${dateFormat.format(initialDateTime.end)}";
    }
    else {
      initialDateTime = DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    dateTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return TextField(
      textAlign: TextAlign.center,
      maxLength: 50,
      controller: dateTextController,
      readOnly: true,
      decoration: const InputDecoration(
        filled: true,
        label: Center(
          child: Text("Date", style: TextStyle(fontSize: 24)),
        ),
      ),
      onTap: () async {
        final DateTimeRange? pickedDate = await showDateRangePicker(
          context: context,
          initialDateRange: initialDateTime,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          final List<String> formattedDate = [
            dateFormat.format(pickedDate.start),
            dateFormat.format(pickedDate.end),
          ];
          setState(() {
            dateTextController.text =
                "${formattedDate[0]} - ${formattedDate[1]}";
          });
          initialDateTime = DateTimeRange(
            start: pickedDate.start,
            end: pickedDate.end);
          widget.onDateRangeChanged(pickedDate.start, pickedDate.end);
        }
      },
    );
  }
}
