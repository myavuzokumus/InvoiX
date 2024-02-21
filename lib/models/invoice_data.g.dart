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
      ImagePath: fields[0] as String,
      companyName: fields[2] as String,
      invoiceNo: fields[3] as String,
      date: fields[4] as DateTime,
      amount: fields[5] as double,
    );
  }

  @override
  void write(final BinaryWriter writer, final InvoiceData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.ImagePath)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.companyName)
      ..writeByte(3)
      ..write(obj.invoiceNo)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.amount);
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
