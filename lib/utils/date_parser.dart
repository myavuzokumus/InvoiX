
import 'package:intl/intl.dart';

DateFormat dateFormat = DateFormat("dd-MM-yyyy");

DateTime dateParser(final String date) {

  //print("Original input: $date");

  // Remove the spaces, change to lower case and keep only the first part (omit the hour part)
  String cleanInput = date.trim().toLowerCase().split(' ')[0];

  // Standardize reagents
  cleanInput = cleanInput.replaceAll(RegExp(r'[./-]'), '-');

  final List<String> datePieces = cleanInput.split('-');

  String format = '';

  if (datePieces.length == 3) {
    // Determination of year (4 digit number)
    final int yearIndex = datePieces.indexWhere((final piece) => piece.length == 4 && int.tryParse(piece) != null);

    if (yearIndex != -1) {
      // Year found
      if (yearIndex == 0) format = 'yyyy-MM-dd';
      else if (yearIndex == 2) format = 'dd-MM-yyyy';
      else format = 'MM-dd-yyyy';
    } else {
      // Year not found, default to day-month-year
      format = 'dd-MM-yy';
    }
  } else {
    throw const FormatException('Invalid date format');
  }

  try {
    final DateFormat dateFormat = DateFormat(format);
    final DateTime parsedDate = dateFormat.parse(cleanInput);

    // Validity check
    if (parsedDate.year < 1900 || parsedDate.year > 2100) {
      throw FormatException('Geçersiz yıl: ${parsedDate.year}');
    }

    //print("Detected format: $format");
    //print("Parsed date: $parsedDate");

    return parsedDate;
  } catch (e) {
    //print('Date parse error: $e');
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
