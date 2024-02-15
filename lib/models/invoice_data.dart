import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:invoix/widgets/date_format.dart';
import 'package:uuid/uuid.dart';

part 'invoice_data.g.dart';

@HiveType(typeId: 0)
class InvoiceData extends HiveObject {
  @HiveField(0)
  final String ImagePath;
  @HiveField(1)
  final String id = const Uuid().toString();
  @HiveField(2)
  final String companyName;
  @HiveField(3)
  final String invoiceNo;
  @HiveField(4)
  late final DateTime date;
  @HiveField(5)
  final double totalAmount;
  @HiveField(6, defaultValue: 0.0)
  final double taxAmount;

  InvoiceData(
      {required this.ImagePath,
      required this.companyName,
      required this.invoiceNo,
      required this.date,
      required this.totalAmount,
      required this.taxAmount});

  InvoiceData.fromJson(final Map<String, dynamic> json)
      : ImagePath = json["ImagePath"] ?? "",
        companyName = json["companyName"] ?? "",
        invoiceNo = json["invoiceNo"] ?? "",
        totalAmount = double.parse(json["totalAmount"]),
        taxAmount = double.parse(json["taxAmount"]) {
    for (final DateFormat format in dateFormats) {
      try {
        date = format.parse(json['date']);
        print('Parsed Date with format $format: $date');
        break;
      } catch (e) {
        print('Failed to parse date with format $format');
      }
    }
  }

}
