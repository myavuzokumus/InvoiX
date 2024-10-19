// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceDataAdapter extends TypeAdapter<InvoiceData> {
  @override
  final int typeId = 0;

  @override
  InvoiceData read(final BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceData(
      imagePath: fields[0] as String,
      companyName: fields[2] as String,
      invoiceNo: fields[3] as String,
      date: fields[4] as DateTime,
      totalAmount: fields[5] as double,
      taxAmount: fields[6] == null ? 0.0 : fields[6] as double,
      category: fields[7] == null ? 'Others' : fields[7] as String,
      unit: fields[8] == null ? 'EUR' : fields[8] as String,
      companyId: fields[9] == null ? '' : fields[9] as String,
      contentCache: fields[10] == null
          ? {}
          : (fields[10] as Map?)?.cast<String, dynamic>(),
    ).._id = fields[1] as String;
  }

  @override
  void write(final BinaryWriter writer, final InvoiceData obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.imagePath)
      ..writeByte(1)
      ..write(obj._id)
      ..writeByte(2)
      ..write(obj.companyName)
      ..writeByte(3)
      ..write(obj.invoiceNo)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.totalAmount)
      ..writeByte(6)
      ..write(obj.taxAmount)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.unit)
      ..writeByte(9)
      ..write(obj.companyId)
      ..writeByte(10)
      ..write(obj.contentCache);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is InvoiceDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
