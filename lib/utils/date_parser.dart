
import 'package:intl/intl.dart';

DateFormat dateFormat = DateFormat("dd-MM-yyyy");

DateTime DateParser(final String date) {
  final List<DateFormat> dateFormats = [
    DateFormat("dd-MM-yyyy"),
    DateFormat("dd/MM/yyyy"),
    DateFormat("dd.MM.yyyy"),
    DateFormat("MM-dd-yyyy"),
    DateFormat("MM/dd/yyyy"),
    DateFormat("MM.dd.yyyy"),
  ];
  for (final DateFormat format in dateFormats) {
    try {
      return format.parse(date);
    } catch (e) {
      print('Failed to parse date with format $format');
    }
  }
  return DateTime.now();
}