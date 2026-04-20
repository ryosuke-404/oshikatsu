import 'package:flutter/material.dart';

class AppIcons {
  static const Map<String, IconData> iconMap = {
    'flag': Icons.flag,
    'savings': Icons.savings,
    'cake': Icons.cake,
    'flight_takeoff': Icons.flight_takeoff,
    'card_giftcard': Icons.card_giftcard,
    'music_note': Icons.music_note,
    'movie': Icons.movie,
    'camera_alt': Icons.camera_alt,
    'book': Icons.book,
    'shopping_cart': Icons.shopping_cart,
    'star': Icons.star,
    'favorite': Icons.favorite,
    'lightbulb': Icons.lightbulb,
    'palette': Icons.palette,
    'videogame_asset': Icons.videogame_asset,
    'mic': Icons.mic,
    'location_on': Icons.location_on,
    'photo_album': Icons.photo_album,
    'celebration': Icons.celebration,
    'theaters': Icons.theaters,
    'brush': Icons.brush,
    'computer': Icons.computer,
    'group': Icons.group,
    'wallet': Icons.wallet,
  };

  static IconData? fromString(String? key) {
    if (key == null) return null;
    return iconMap[key];
  }

  static String? fromIconData(IconData? icon) {
    if (icon == null) return null;
    for (var entry in iconMap.entries) {
      if (entry.value == icon) {
        return entry.key;
      }
    }
    return null;
  }
}
