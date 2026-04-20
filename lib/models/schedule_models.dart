import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'schedule_models.g.dart';

@HiveType(typeId: 16)
enum EventCategory {
  @HiveField(0)
  liveConcert,
  @HiveField(1)
  event,
  @HiveField(2)
  tvMedia,
  @HiveField(3)
  pilgrimage,
  @HiveField(4)
  travel,
  @HiveField(5)
  oshiCafe,
  @HiveField(6)
  goods,
  @HiveField(7)
  ticket,
  @HiveField(8)
  streaming,
  @HiveField(10) // Moved up
  release,
  @HiveField(11)
  birthday, // Added birthday category
  @HiveField(9) // Moved down
  other,
}

const Map<EventCategory, Map<String, dynamic>> eventCategoryDetails = {
  EventCategory.liveConcert: {'icon': Icons.music_note, 'color': Colors.red},
  EventCategory.event: {'icon': Icons.local_activity, 'color': Colors.orange},
  EventCategory.tvMedia: {'icon': Icons.tv, 'color': Colors.green},
  EventCategory.release: {'icon': Icons.album, 'color': Colors.teal},
  EventCategory.pilgrimage: {'icon': Icons.location_on, 'color': Colors.blue},
  EventCategory.travel: {'icon': Icons.flight_takeoff, 'color': Colors.indigo},
  EventCategory.oshiCafe: {'icon': Icons.local_cafe, 'color': Colors.purple},
  EventCategory.goods: {'icon': Icons.shopping_bag, 'color': Colors.pink},
  EventCategory.ticket: {
    'icon': Icons.confirmation_number,
    'color': Colors.amber
  },
  EventCategory.birthday: {
    'icon': Icons.cake,
    'color': Colors.deepOrangeAccent
  }, // Added birthday details

  EventCategory.other: {'icon': Icons.more_horiz, 'color': Colors.grey},
};

@HiveType(typeId: 12)
class Event extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  DateTime date;
  @HiveField(3)
  String? memo;
  @HiveField(4)
  String? oshiId;
  @HiveField(5)
  EventCategory category;
  @HiveField(6)
  int priority;
  @HiveField(7)
  bool isYearlyRecurring;

  Event({
    required this.id,
    required this.title,
    required this.date,
    this.memo,
    this.oshiId,
    required this.category,
    this.priority = 3,
    this.isYearlyRecurring = false,
  });
}

@HiveType(typeId: 15) // typeIdを15に変更
class TodoItem {
  // extends HiveObject を削除
  @HiveField(0)
  String description;
  @HiveField(1)
  bool isCompleted;

  TodoItem({
    required this.description,
    this.isCompleted = false,
  });
}

@HiveType(typeId: 13)
class Itinerary extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  DateTime startDate;
  @HiveField(3)
  DateTime endDate;
  @HiveField(4)
  String memoContent;
  @HiveField(5)
  String? oshiId;
  @HiveField(7) // フィールド番号を7に変更
  List<TodoItem>? todoList; // HiveList<TodoItem> から List<TodoItem> に変更

  Itinerary({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.memoContent = '',
    this.oshiId,
    this.todoList, // コンストラクタに追加
  });
}
