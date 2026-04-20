// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oshi_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OshiAdapter extends TypeAdapter<Oshi> {
  @override
  final int typeId = 4;

  @override
  Oshi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Oshi(
      id: fields[0] as String,
      name: fields[1] as String,
      level: fields[2] as OshiLevel,
      startDate: fields[3] as DateTime,
      imagePath: fields[4] as String?,
      mainColorValue: fields[5] as int?,
      subColorValue: fields[6] as int?,
      officialWebsite: fields[7] as String?,
      twitterUrl: fields[8] as String?,
      instagramUrl: fields[9] as String?,
      facebookUrl: fields[10] as String?,
      tiktokUrl: fields[11] as String?,
      youtubeUrl: fields[12] as String?,
      spotifyUrl: fields[13] as String?,
      appleMusicUrl: fields[14] as String?,
      pinterestUrl: fields[15] as String?,
      threadsUrl: fields[16] as String?,
      weverseUrl: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Oshi obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.mainColorValue)
      ..writeByte(6)
      ..write(obj.subColorValue)
      ..writeByte(7)
      ..write(obj.officialWebsite)
      ..writeByte(8)
      ..write(obj.twitterUrl)
      ..writeByte(9)
      ..write(obj.instagramUrl)
      ..writeByte(10)
      ..write(obj.facebookUrl)
      ..writeByte(11)
      ..write(obj.tiktokUrl)
      ..writeByte(12)
      ..write(obj.youtubeUrl)
      ..writeByte(13)
      ..write(obj.spotifyUrl)
      ..writeByte(14)
      ..write(obj.appleMusicUrl)
      ..writeByte(15)
      ..write(obj.pinterestUrl)
      ..writeByte(16)
      ..write(obj.threadsUrl)
      ..writeByte(17)
      ..write(obj.weverseUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OshiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OshiLevelAdapter extends TypeAdapter<OshiLevel> {
  @override
  final int typeId = 5;

  @override
  OshiLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OshiLevel.saiOshi;
      case 1:
        return OshiLevel.oshi;
      case 2:
        return OshiLevel.hakoOshi;
      case 3:
        return OshiLevel.tanOshi;
      case 4:
        return OshiLevel.dd;
      case 5:
        return OshiLevel.kininaru;
      case 6:
        return OshiLevel.oshinoOshi;
      default:
        return OshiLevel.saiOshi;
    }
  }

  @override
  void write(BinaryWriter writer, OshiLevel obj) {
    switch (obj) {
      case OshiLevel.saiOshi:
        writer.writeByte(0);
        break;
      case OshiLevel.oshi:
        writer.writeByte(1);
        break;
      case OshiLevel.hakoOshi:
        writer.writeByte(2);
        break;
      case OshiLevel.tanOshi:
        writer.writeByte(3);
        break;
      case OshiLevel.dd:
        writer.writeByte(4);
        break;
      case OshiLevel.kininaru:
        writer.writeByte(5);
        break;
      case OshiLevel.oshinoOshi:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OshiLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
