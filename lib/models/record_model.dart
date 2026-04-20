// --------------------------------------------------
// lib/models/record_model.dart
// ★★★ このファイルの内容を全て置き換えてください ★★★
// --------------------------------------------------
import 'package:hive/hive.dart';
import 'package:flutter/material.dart'; // 追加
part 'record_model.g.dart';

@HiveType(typeId: 3)
enum RecordCategory {
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
  @HiveField(9)
  other,
}

final Map<RecordCategory, Map<String, dynamic>> categoryDetails = {
  RecordCategory.liveConcert: {
    'name': 'category_live_concert',
    'icon': Icons.music_note,
    'color': Colors.red
  },
  RecordCategory.event: {
    'name': 'category_event',
    'icon': Icons.local_activity,
    'color': Colors.orange
  },
  RecordCategory.tvMedia: {
    'name': 'category_tv_media',
    'icon': Icons.tv,
    'color': Colors.green
  },
  RecordCategory.pilgrimage: {
    'name': 'category_pilgrimage',
    'icon': Icons.location_on,
    'color': Colors.blue
  },
  RecordCategory.travel: {
    'name': 'category_travel',
    'icon': Icons.flight_takeoff,
    'color': Colors.indigo
  },
  RecordCategory.oshiCafe: {
    'name': 'category_oshi_cafe',
    'icon': Icons.local_cafe,
    'color': Colors.purple
  },
  RecordCategory.goods: {
    'name': 'category_goods',
    'icon': Icons.shopping_bag,
    'color': Colors.pink
  },
  RecordCategory.ticket: {
    'name': 'category_ticket',
    'icon': Icons.confirmation_number,
    'color': Colors.amber
  },
  RecordCategory.streaming: {
    'name': 'category_streaming',
    'icon': Icons.live_tv,
    'color': Colors.lightBlue
  },
  RecordCategory.other: {
    'name': 'category_other',
    'icon': Icons.more_horiz,
    'color': Colors.grey
  },
};

@HiveType(typeId: 2)
class Record extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  RecordCategory category;
  @HiveField(3)
  DateTime date;
  @HiveField(4)
  String? imagePath;
  @HiveField(5)
  double rating;
  @HiveField(6)
  List<String> emotionTags;
  @HiveField(7)
  String? videoPath;
  @HiveField(8)
  String? address;
  @HiveField(9)
  List<String> companions;
  @HiveField(10)
  String? oshiId;
  @HiveField(11)
  List<String>? setlist; // セットリストを追加
  @HiveField(12)
  String? memo; // メモを追加
  @HiveField(13)
  String? relatedUrl; // 関連URLを追加

  Record({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    this.imagePath,
    this.rating = 0.0,
    this.emotionTags = const [],
    this.videoPath,
    this.address,
    this.companions = const [],
    this.oshiId,
    this.setlist,
    this.memo,
    this.relatedUrl,
  });
}
