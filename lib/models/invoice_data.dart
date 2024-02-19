import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/utils/date_parser.dart';
import 'package:uuid/uuid.dart';

part 'invoice_data.g.dart';

@HiveType(typeId: 0)
class InvoiceData extends HiveObject {
  @HiveField(0)
  final String ImagePath;
  @HiveField(1)
  final String id = const Uuid().v4();
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
        date = DateParser(json["date"]),
        totalAmount = double.parse(json["totalAmount"]),
        taxAmount = double.parse(json["taxAmount"]);

  InvoiceData copyWith({
    final String? ImagePath,
    final String? companyName,
    final String? invoiceNo,
    final DateTime? date,
    final double? totalAmount,
    final double? taxAmount,
  }) {
    return InvoiceData(
      ImagePath: ImagePath ?? this.ImagePath,
      companyName: companyName ?? this.companyName,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
    );
  }

}
