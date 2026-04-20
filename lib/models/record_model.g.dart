// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecordAdapter extends TypeAdapter<Record> {
  @override
  final int typeId = 2;

  @override
  Record read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Record(
      id: fields[0] as String,
      title: fields[1] as String,
      category: fields[2] as RecordCategory,
      date: fields[3] as DateTime,
      imagePath: fields[4] as String?,
      rating: fields[5] as double,
      emotionTags: (fields[6] as List).cast<String>(),
      videoPath: fields[7] as String?,
      address: fields[8] as String?,
      companions: (fields[9] as List).cast<String>(),
      oshiId: fields[10] as String?,
      setlist: (fields[11] as List?)?.cast<String>(),
      memo: fields[12] as String?,
      relatedUrl: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Record obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.emotionTags)
      ..writeByte(7)
      ..write(obj.videoPath)
      ..writeByte(8)
      ..write(obj.address)
      ..writeByte(9)
      ..write(obj.companions)
      ..writeByte(10)
      ..write(obj.oshiId)
      ..writeByte(11)
      ..write(obj.setlist)
      ..writeByte(12)
      ..write(obj.memo)
      ..writeByte(13)
      ..write(obj.relatedUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecordCategoryAdapter extends TypeAdapter<RecordCategory> {
  @override
  final int typeId = 3;

  @override
  RecordCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecordCategory.liveConcert;
      case 1:
        return RecordCategory.event;
      case 2:
        return RecordCategory.tvMedia;
      case 3:
        return RecordCategory.pilgrimage;
      case 4:
        return RecordCategory.travel;
      case 5:
        return RecordCategory.oshiCafe;
      case 6:
        return RecordCategory.goods;
      case 7:
        return RecordCategory.ticket;
      case 8:
        return RecordCategory.streaming;
      case 9:
        return RecordCategory.other;
      default:
        return RecordCategory.liveConcert;
    }
  }

  @override
  void write(BinaryWriter writer, RecordCategory obj) {
    switch (obj) {
      case RecordCategory.liveConcert:
        writer.writeByte(0);
        break;
      case RecordCategory.event:
        writer.writeByte(1);
        break;
      case RecordCategory.tvMedia:
        writer.writeByte(2);
        break;
      case RecordCategory.pilgrimage:
        writer.writeByte(3);
        break;
      case RecordCategory.travel:
        writer.writeByte(4);
        break;
      case RecordCategory.oshiCafe:
        writer.writeByte(5);
        break;
      case RecordCategory.goods:
        writer.writeByte(6);
        break;
      case RecordCategory.ticket:
        writer.writeByte(7);
        break;
      case RecordCategory.streaming:
        writer.writeByte(8);
        break;
      case RecordCategory.other:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
