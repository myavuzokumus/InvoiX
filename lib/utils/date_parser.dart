
import 'package:intl/intl.dart';

DateFormat dateFormat = DateFormat("dd-MM-yyyy");

DateTime dateParser(final String date) {

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
      final DateTime newDate = format.parse(date);
      return newDate.isAfter(DateTime.now()) ? DateTime.now() : newDate;
    } catch (e) {
      print('Failed to parse date with format $format');
    }
  }
  return DateTime.now();
}

String updateYear(final String date) {
  final List<String> separators = ["-", ".", "/"];

  for (final sep in separators) {
    if (date.contains(sep)) {
      final List<String> parts = date.split(sep);
      if (parts[2][0] == "0" && parts[2][1] == "0") {
        parts[2] = '20${parts[2][2]}${parts[2][3]}';
      }
      return parts.join(sep);
    }
  }
  return date;
}
