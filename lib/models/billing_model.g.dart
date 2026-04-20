// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillingRecordAdapter extends TypeAdapter<BillingRecord> {
  @override
  final int typeId = 100;

  @override
  BillingRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillingRecord(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as int,
      category: fields[3] as BillingCategory,
      date: fields[4] as DateTime,
      oshiId: fields[5] as String?,
      receiptImagePath: fields[6] as String?,
      paymentMethod: fields[7] as PaymentMethod?,
      isRepeating: fields[8] as bool?,
      isCancelled: fields[9] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, BillingRecord obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.oshiId)
      ..writeByte(6)
      ..write(obj.receiptImagePath)
      ..writeByte(7)
      ..write(obj.paymentMethod)
      ..writeByte(8)
      ..write(obj.isRepeating)
      ..writeByte(9)
      ..write(obj.isCancelled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BillingCategoryAdapter extends TypeAdapter<BillingCategory> {
  @override
  final int typeId = 101;

  @override
  BillingCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BillingCategory.liveTicket;
      case 1:
        return BillingCategory.stageEvent;
      case 2:
        return BillingCategory.goods;
      case 3:
        return BillingCategory.cdDvd;
      case 4:
        return BillingCategory.magazinePhotobook;
      case 5:
        return BillingCategory.transportation;
      case 6:
        return BillingCategory.accommodation;
      case 7:
        return BillingCategory.streamingTicket;
      case 8:
        return BillingCategory.fanClubSubscription;
      case 9:
        return BillingCategory.giftsPostage;
      default:
        return BillingCategory.liveTicket;
    }
  }

  @override
  void write(BinaryWriter writer, BillingCategory obj) {
    switch (obj) {
      case BillingCategory.liveTicket:
        writer.writeByte(0);
        break;
      case BillingCategory.stageEvent:
        writer.writeByte(1);
        break;
      case BillingCategory.goods:
        writer.writeByte(2);
        break;
      case BillingCategory.cdDvd:
        writer.writeByte(3);
        break;
      case BillingCategory.magazinePhotobook:
        writer.writeByte(4);
        break;
      case BillingCategory.transportation:
        writer.writeByte(5);
        break;
      case BillingCategory.accommodation:
        writer.writeByte(6);
        break;
      case BillingCategory.streamingTicket:
        writer.writeByte(7);
        break;
      case BillingCategory.fanClubSubscription:
        writer.writeByte(8);
        break;
      case BillingCategory.giftsPostage:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 102;

  @override
  PaymentMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMethod.cash;
      case 1:
        return PaymentMethod.card;
      case 2:
        return PaymentMethod.eMoney;
      case 3:
        return PaymentMethod.other;
      default:
        return PaymentMethod.cash;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    switch (obj) {
      case PaymentMethod.cash:
        writer.writeByte(0);
        break;
      case PaymentMethod.card:
        writer.writeByte(1);
        break;
      case PaymentMethod.eMoney:
        writer.writeByte(2);
        break;
      case PaymentMethod.other:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
