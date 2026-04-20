import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'goods_model.g.dart';

// --- New String-based Category System ---

// 1. A list of unique keys for each category
const List<String> goodsCategoryKeys = [
  'photobook',
  'bromide',
  'cdDvd',
  'canBadge',
  'acrylicStand',
  'keychain',
  'figure',
  'tapestry',
  'apparel',
  'rubberBand',
  'towel',
  'silverTape',
  'gacha',
];

// 2. Details map now uses String keys
final Map<String, Map<String, dynamic>> goodsCategoryDetails = {
  'photobook': {
    'icon': Icons.photo_album,
    'mainColor': const Color(0xFFADD8E6),
    'accentColor': const Color(0xFF87CEEB),
  },
  'bromide': {
    'icon': Icons.photo,
    'mainColor': const Color(0xFF90EE90),
    'accentColor': const Color(0xFF3CB371),
  },
  'cdDvd': {
    'icon': Icons.album,
    'mainColor': const Color(0xFFA8D8EA),
    'accentColor': const Color(0xFF79C7E3),
  },
  'canBadge': {
    'icon': Icons.adjust,
    'mainColor': const Color(0xFFFFD93D),
    'accentColor': const Color(0xFFFFB700),
  },
  'acrylicStand': {
    'icon': Icons.star_border,
    'mainColor': const Color(0xFFB8E6B8),
    'accentColor': const Color(0xFF88D888),
  },
  'keychain': {
    'icon': Icons.vpn_key,
    'mainColor': const Color(0xFFFFB3BA),
    'accentColor': const Color(0xFFFF8A95),
  },
  'figure': {
    'icon': Icons.person_outline,
    'mainColor': const Color(0xFFFFDFBA),
    'accentColor': const Color(0xFFFFD1A3),
  },
  'tapestry': {
    'icon': Icons.photo_size_select_large,
    'mainColor': const Color(0xFFC7CEEA),
    'accentColor': const Color(0xFFA5B4FC),
  },
  'apparel': {
    'icon': Icons.shopping_bag,
    'mainColor': const Color(0xFFC5A3FF),
    'accentColor': const Color(0xFFB388FF),
  },
  'rubberBand': {
    'icon': Icons.watch,
    'mainColor': const Color(0xFFB2EBF2),
    'accentColor': const Color(0xFF80DEEA),
  },
  'towel': {
    'icon': Icons.checkroom,
    'mainColor': const Color(0xFFC8E6C9),
    'accentColor': const Color(0xFFA5D6A7),
  },
  'silverTape': {
    'icon': Icons.movie_filter,
    'mainColor': const Color(0xFFCFD8DC),
    'accentColor': const Color(0xFFB0BEC5),
  },
  'gacha': {
    'icon': Icons.casino,
    'mainColor': const Color(0xFFFFECB3),
    'accentColor': const Color(0xFFFFE082),
  },
};

// 3. Goods model now uses a String for the category
@HiveType(typeId: 110)
class Goods extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? imagePath;

  @HiveField(3)
  String category; // Changed from GoodsCategory to String

  @HiveField(4)
  String oshiId;

  @HiveField(5)
  bool isOwned;

  @HiveField(6)
  String? memo;

  @HiveField(7)
  String? series;

  @HiveField(8)
  int order;

  Goods({
    required this.id,
    required this.name,
    this.imagePath,
    required this.category,
    required this.oshiId,
    this.isOwned = true,
    this.memo,
    this.series,
    required this.order,
  });
}
