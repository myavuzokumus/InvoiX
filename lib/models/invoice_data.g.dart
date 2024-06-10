// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceDataAdapter extends TypeAdapter<InvoiceData> {
  @override
  final int typeId = 0;

  @override
  InvoiceData read(BinaryReader reader) {
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
    ).._id = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, InvoiceData obj) {
    writer
      ..writeByte(8)
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
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
