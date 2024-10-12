import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoix/utils/date_parser.dart';
import 'package:uuid/uuid.dart';

part 'invoice_data.g.dart';

@HiveType(typeId: 0)
class InvoiceData extends HiveObject {
  @HiveField(0)
  final String imagePath;
  @HiveField(1)
  late String _id; //Attention!
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
  @HiveField(7, defaultValue: "Others")
  final String category;
  @HiveField(8, defaultValue: "EUR")
  final String unit;
  @HiveField(9, defaultValue: "")
  final String companyId;
  @HiveField(10, defaultValue: {})
  late Map<String, dynamic> contentCache;

  String get id => _id;

  InvoiceData(
      {required this.imagePath,
      required this.companyName,
      required this.invoiceNo,
      required this.date,
      required this.totalAmount,
      required this.taxAmount,
      required this.category,
      required this.unit,
      required this.companyId,
      final Map<String, dynamic>? contentCache,
      final String? id}) {
    id != null ? _id = id : _id = const Uuid().v4();
    contentCache != null ? this.contentCache = contentCache : this.contentCache = <String, dynamic>{};
  }

  InvoiceData.fromJson(final Map<String, dynamic> json)
      : imagePath = json["ImagePath"] ?? "",
        companyName = json["companyName"] ?? "",
        invoiceNo = json["invoiceNo"] ?? "",
        date = dateParser(json["date"] ?? DateTime.now().toString()),
        category = json["category"] ?? "",
        _id = const Uuid().v4(),
        totalAmount = _parseAmount(json["totalAmount"].toString()),
        taxAmount = _parseAmount(json["taxAmount"].toString()),
        unit = json["unit"] ?? "EUR",
        companyId = json["companyId"] ?? "",
        contentCache = <String, dynamic>{};

  Map<String, dynamic> toJson() {
    return {
      "ImagePath": imagePath,
      "companyName": companyName,
      "invoiceNo": invoiceNo,
      "date": date.toString(),
      "totalAmount": totalAmount,
      "taxAmount": taxAmount,
      "category": category,
      "unit": unit,
      "companyId": companyId,
      "contentCache": contentCache,
      "id": _id,
    };
  }

  static double _parseAmount(final String amount) {

    print(amount);
    // Ondalık ayraçlarını düzelt
    final newAmount = amount.replaceAllMapped(
        RegExp(r'(\d+)([.,])(\d{1,2})$'),
            (final Match m) => '${m[1]}${"."}${m[3]}'
    );

    String reversedText = newAmount.split('').reversed.join('');

    // İlk noktayı bul ve metni ikiye ayır
    int lastDotIndex = reversedText.indexOf('.');
    String beforeLastDot = reversedText.substring(lastDotIndex + 1);
    String afterLastDot = reversedText.substring(0, lastDotIndex + 1);

    // Noktaları kaldır ve metni tekrar birleştir
    beforeLastDot = beforeLastDot.replaceAll('.', '');
    String result = beforeLastDot + afterLastDot;

    result = result.split('').reversed.join('');

    // Metni tekrar ters çevir
    print(result.replaceAll(",", "."));
    return double.tryParse(newAmount.replaceAll(",", ".")) ?? 0;
  }

  InvoiceData copyWith({
    final String? imagePath,
    final String? companyName,
    final String? invoiceNo,
    final DateTime? date,
    final double? totalAmount,
    final double? taxAmount,
    final String? category,
    final String? unit,
    final String? companyId,
    final Map<String, dynamic>? contentCache,
    final String? id,
  }) {
    return InvoiceData(
      imagePath: imagePath ?? this.imagePath,
      companyName: companyName ?? this.companyName,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      companyId: companyId ?? this.companyId,
      contentCache: contentCache ?? this.contentCache,
      id: id ?? _id,
    );
  }

}
