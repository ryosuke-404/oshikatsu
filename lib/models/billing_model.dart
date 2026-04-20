// --------------------------------------------------
// lib/models/billing_model.dart
// ★★★ このファイルの内容を全て置き換えてください ★★★
// --------------------------------------------------
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'billing_model.g.dart';

// ★★★ 修正点: typeIdを100番台に変更 ★★★
@HiveType(typeId: 101)
enum BillingCategory {
  @HiveField(0)
  liveTicket,
  @HiveField(1)
  stageEvent,
  @HiveField(2)
  goods,
  @HiveField(3)
  cdDvd,
  @HiveField(4)
  magazinePhotobook,
  @HiveField(5)
  transportation,
  @HiveField(6)
  accommodation,
  @HiveField(7)
  streamingTicket,
  @HiveField(8)
  fanClubSubscription,
  @HiveField(9)
  giftsPostage,
}

const Map<BillingCategory, Map<String, dynamic>> billingCategoryDetails = {
  BillingCategory.liveTicket: {
    'icon': Icons.confirmation_number,
    'color': 0xFFF44336
  },
  BillingCategory.stageEvent: {
    'icon': Icons.theater_comedy,
    'color': 0xFF9C27B0
  },
  BillingCategory.goods: {'icon': Icons.shopping_bag, 'color': 0xFFFF9800},
  BillingCategory.cdDvd: {'icon': Icons.album, 'color': 0xFF2196F3},
  BillingCategory.magazinePhotobook: {'icon': Icons.book, 'color': 0xFF795548},
  BillingCategory.transportation: {
    'icon': Icons.directions_transit,
    'color': 0xFF009688
  },
  BillingCategory.accommodation: {'icon': Icons.hotel, 'color': 0xFF3F51B5},
  BillingCategory.streamingTicket: {'icon': Icons.live_tv, 'color': 0xFFE91E63},
  BillingCategory.fanClubSubscription: {
    'icon': Icons.card_membership,
    'color': 0xFFFF5722
  },
  BillingCategory.giftsPostage: {
    'icon': Icons.card_giftcard,
    'color': 0xFF4CAF50
  },
};

// ★★★ 修正点: typeIdを100番台に変更 ★★★
@HiveType(typeId: 102)
enum PaymentMethod {
  @HiveField(0)
  cash,
  @HiveField(1)
  card,
  @HiveField(2)
  eMoney,
  @HiveField(3)
  other,
}

// ★★★ 修正点: typeIdを100番台に変更 ★★★
@HiveType(typeId: 100)
class BillingRecord extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  int amount;
  @HiveField(3)
  BillingCategory category;
  @HiveField(4)
  DateTime date;
  @HiveField(5)
  String? oshiId;
  @HiveField(6)
  String? receiptImagePath;
  @HiveField(7)
  PaymentMethod? paymentMethod;
  @HiveField(8)
  bool? isRepeating; // New field for repeat setting
  @HiveField(9)
  bool? isCancelled; // New field for cancellation

  BillingRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.oshiId,
    this.receiptImagePath,
    this.paymentMethod,
    this.isRepeating,
    this.isCancelled,
  });
}
