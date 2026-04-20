import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'oshi_model.g.dart';

@HiveType(typeId: 5)
enum OshiLevel {
  @HiveField(0)
  saiOshi, // 最推し
  @HiveField(1)
  oshi, // 推し
  @HiveField(2)
  hakoOshi, // 箱推し
  @HiveField(3)
  tanOshi, // 単推し
  @HiveField(4)
  dd, // DD
  @HiveField(5)
  kininaru, // 気になる子
  @HiveField(6)
  oshinoOshi, // 推しの推し
}

const Map<OshiLevel, Map<String, dynamic>> oshiLevelDetails = {
  OshiLevel.saiOshi: {'icon': Icons.star, 'color': 0xFFFFDDC1}, // Light Peach
  OshiLevel.oshi: {'icon': Icons.favorite, 'color': 0xFFB2DFDB}, // Light Teal
  OshiLevel.hakoOshi: {'icon': Icons.group, 'color': 0xFFC5E1A5}, // Light Green
  OshiLevel.tanOshi: {
    'icon': Icons.person,
    'color': 0xFFFFF9C4
  }, // Light Yellow
  OshiLevel.dd: {'icon': Icons.diversity_3, 'color': 0xFFCFD8DC}, // Blue Grey
  OshiLevel.kininaru: {'icon': Icons.search, 'color': 0xFFF8BBD0}, // Pink
  OshiLevel.oshinoOshi: {
    'icon': Icons.person_add,
    'color': 0xFFD7CCC8
  }, // Brown (Coffee)
};

// Additional Earth and Pastel Colors
const List<int> additionalThemeColors = [
  0xFF8D6E63, // Brown
  0xFFBCAAA4, // Light Brown
  0xFFD7CCC8, // Very Light Brown
  0xFFEFEBE9, // Off White
  0xFFBDBDBD, // Grey
  0xFF795548, // Dark Brown
  0xFF5D4037, // Very Dark Brown

  0xFFF8BBD0, // Pink Pastel
  0xFFE1BEE7, // Purple Pastel
  0xFFBBDEFB, // Blue Pastel
  0xFFB2EBF2, // Cyan Pastel
  0xFFC8E6C9, // Green Pastel
  0xFFFFF9C4, // Yellow Pastel
  0xFFFFECB3, // Orange Pastel
  0xFFFFCCBC, // Red Pastel
  0xFFD7CCC8, // Earth Tone - Light Brown
  0xFFBCAAA4, // Earth Tone - Medium Light Brown
  0xFF8D6E63, // Earth Tone - Medium Brown
  0xFF6D4C41, // Earth Tone - Dark Brown
  0xFF5D4037, // Earth Tone - Very Dark Brown
  0xFF4E342E, // Earth Tone - Deep Brown
  0xFF3E2723, // Earth Tone - Darkest Brown
  0xFFB0BEC5, // Earth Tone - Light Blue Grey
  0xFF90A4AE, // Earth Tone - Medium Blue Grey
  0xFF78909C, // Earth Tone - Dark Blue Grey
  0xFF607D8B, // Earth Tone - Very Dark Blue Grey
  0xFFCFD8DC, // Pastel - Light Blue Grey
  0xFFECEFF1, // Pastel - Very Light Blue Grey
  0xFFF5F5DC, // Earth Tone - Beige
  0xFFFAEBD7, // Earth Tone - Antique White
  0xFFFFFAF0, // Earth Tone - Floral White
  0xFFFDF5E6, // Earth Tone - Old Lace
  0xFFFFF8DC, // Earth Tone - Cornsilk
  0xFFF0E68C, // Earth Tone - Khaki
  0xFFDAA520, // Earth Tone - Goldenrod
  0xFFCD853F, // Earth Tone - Peru
  0xFFD2B48C, // Earth Tone - Tan
  0xFFBC8F8F, // Earth Tone - Rosy Brown
  0xFF8B4513, // Earth Tone - Saddle Brown
  0xFFA0522D, // Earth Tone - Sienna
  0xFFD2691E, // Earth Tone - Chocolate
  0xFFB8860B, // Earth Tone - Dark Goldenrod
  0xFFDAA520, // Earth Tone - Goldenrod
  0xFFCD853F, // Earth Tone - Peru
  0xFFD2B48C, // Earth Tone - Tan
  0xFFBC8F8F, // Earth Tone - Rosy Brown
  0xFF8B4513, // Earth Tone - Saddle Brown
  0xFFA0522D, // Earth Tone - Sienna
  0xFFD2691E, // Earth Tone - Chocolate
  0xFFB8860B, // Earth Tone - Dark Goldenrod
];

@HiveType(typeId: 4)
class Oshi extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  OshiLevel level;
  @HiveField(3)
  DateTime startDate;
  @HiveField(4)
  String? imagePath;
  @HiveField(5)
  int? mainColorValue;
  @HiveField(6)
  int? subColorValue;
  @HiveField(7)
  String? officialWebsite;
  @HiveField(8)
  String? twitterUrl;
  @HiveField(9)
  String? instagramUrl;
  @HiveField(10)
  String? facebookUrl;
  @HiveField(11)
  String? tiktokUrl;
  @HiveField(12)
  String? youtubeUrl;
  @HiveField(13)
  String? spotifyUrl;
  @HiveField(14)
  String? appleMusicUrl;
  @HiveField(15)
  String? pinterestUrl;
  @HiveField(16)
  String? threadsUrl;
  @HiveField(17)
  String? weverseUrl;

  Oshi({
    required this.id,
    required this.name,
    required this.level,
    required this.startDate,
    this.imagePath,
    this.mainColorValue,
    this.subColorValue,
    this.officialWebsite,
    this.twitterUrl,
    this.instagramUrl,
    this.facebookUrl,
    this.tiktokUrl,
    this.youtubeUrl,
    this.spotifyUrl,
    this.appleMusicUrl,
    this.pinterestUrl,
    this.threadsUrl,
    this.weverseUrl,
  });
}
