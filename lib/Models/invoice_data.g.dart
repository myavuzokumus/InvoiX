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
      InvoiceImage: fields[0] as Image,
      CompanyName: fields[2] as String,
      InvoiceNo: fields[3] as String,
      Date: fields[4] as DateTime,
      Amount: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.InvoiceImage)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.CompanyName)
      ..writeByte(3)
      ..write(obj.InvoiceNo)
      ..writeByte(4)
      ..write(obj.Date)
      ..writeByte(5)
      ..write(obj.Amount);
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
