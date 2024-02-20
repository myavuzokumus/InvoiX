import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/utils/date_parser.dart';
import 'package:uuid/uuid.dart';

part 'invoice_data.g.dart';

@HiveType(typeId: 0)
class InvoiceData extends HiveObject {
  @HiveField(0)
  final String imagePath;
  @HiveField(1)
  late String _id;
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

  String get id => _id;

  InvoiceData(
      {required this.imagePath,
      required this.companyName,
      required this.invoiceNo,
      required this.date,
      required this.totalAmount,
      required this.taxAmount,
      final String? id}) {
    id != null ? _id = id : _id = const Uuid().v4();
  }

  InvoiceData.fromJson(final Map<String, dynamic> json)
      : imagePath = json["ImagePath"] ?? "",
        companyName = json["companyName"] ?? "",
        invoiceNo = json["invoiceNo"] ?? "",
        date = DateParser(json["date"]),
        totalAmount = double.parse(json["totalAmount"].replaceAll(",", ".")),
        taxAmount = double.parse(json["taxAmount"].replaceAll(",", ".")),
        _id = const Uuid().v4();

  InvoiceData copyWith({
    final String? imagePath,
    final String? companyName,
    final String? invoiceNo,
    final DateTime? date,
    final double? totalAmount,
    final double? taxAmount,
    final String? id,
  }) {
    return InvoiceData(
      imagePath: imagePath ?? this.imagePath,
      companyName: companyName ?? this.companyName,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      id: id ?? this._id,
    );
  }

}
