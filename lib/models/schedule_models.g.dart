// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 12;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[2] as DateTime,
      memo: fields[3] as String?,
      oshiId: fields[4] as String?,
      category: fields[5] as EventCategory,
      priority: fields[6] as int,
      isYearlyRecurring: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.memo)
      ..writeByte(4)
      ..write(obj.oshiId)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.isYearlyRecurring);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TodoItemAdapter extends TypeAdapter<TodoItem> {
  @override
  final int typeId = 15;

  @override
  TodoItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoItem(
      description: fields[0] as String,
      isCompleted: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TodoItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItineraryAdapter extends TypeAdapter<Itinerary> {
  @override
  final int typeId = 13;

  @override
  Itinerary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Itinerary(
      id: fields[0] as String,
      title: fields[1] as String,
      startDate: fields[2] as DateTime,
      endDate: fields[3] as DateTime,
      memoContent: fields[4] as String,
      oshiId: fields[5] as String?,
      todoList: (fields[7] as List?)?.cast<TodoItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, Itinerary obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.memoContent)
      ..writeByte(5)
      ..write(obj.oshiId)
      ..writeByte(7)
      ..write(obj.todoList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItineraryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EventCategoryAdapter extends TypeAdapter<EventCategory> {
  @override
  final int typeId = 16;

  @override
  EventCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EventCategory.liveConcert;
      case 1:
        return EventCategory.event;
      case 2:
        return EventCategory.tvMedia;
      case 3:
        return EventCategory.pilgrimage;
      case 4:
        return EventCategory.travel;
      case 5:
        return EventCategory.oshiCafe;
      case 6:
        return EventCategory.goods;
      case 7:
        return EventCategory.ticket;
      case 8:
        return EventCategory.streaming;
      case 10:
        return EventCategory.release;
      case 11:
        return EventCategory.birthday;
      case 9:
        return EventCategory.other;
      default:
        return EventCategory.liveConcert;
    }
  }

  @override
  void write(BinaryWriter writer, EventCategory obj) {
    switch (obj) {
      case EventCategory.liveConcert:
        writer.writeByte(0);
        break;
      case EventCategory.event:
        writer.writeByte(1);
        break;
      case EventCategory.tvMedia:
        writer.writeByte(2);
        break;
      case EventCategory.pilgrimage:
        writer.writeByte(3);
        break;
      case EventCategory.travel:
        writer.writeByte(4);
        break;
      case EventCategory.oshiCafe:
        writer.writeByte(5);
        break;
      case EventCategory.goods:
        writer.writeByte(6);
        break;
      case EventCategory.ticket:
        writer.writeByte(7);
        break;
      case EventCategory.streaming:
        writer.writeByte(8);
        break;
      case EventCategory.release:
        writer.writeByte(10);
        break;
      case EventCategory.birthday:
        writer.writeByte(11);
        break;
      case EventCategory.other:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
