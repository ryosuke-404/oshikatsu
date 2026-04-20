import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:oshikatu/utils/app_icons.dart';

part 'mission_model.g.dart';

// =================================================================
// IconDataをHiveで保存するためのアダプター
// =================================================================
// このアダプターを登録しないと、IconDataをHiveに保存できません。
// アプリの初期化時 (main.dart など) で `Hive.registerAdapter(IconDataAdapter());` を呼び出してください。
class IconDataAdapter extends TypeAdapter<IconData> {
  @override
  final int typeId = 20; // 他のモデルのtypeIdと重複しないIDを指定

  @override
  IconData read(BinaryReader reader) {
    final iconKey = reader.readString();
    return AppIcons.fromString(iconKey) ?? Icons.help; // fallback icon
  }

  @override
  void write(BinaryWriter writer, IconData obj) {
    final iconKey = AppIcons.fromIconData(obj);
    writer.writeString(iconKey ?? '');
  }
}

// =================================================================
// Missionモデル
// =================================================================
@HiveType(typeId: 21) // ユーザー提供のIDを使用
class Mission extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int goalAmount;

  @HiveField(3)
  int currentAmount;

  @HiveField(4)
  DateTime deadline;

  @HiveField(5)
  IconData? icon;

  @HiveField(6)
  List<Deposit> deposits;

  Mission({
    required this.id,
    required this.title,
    required this.goalAmount,
    this.currentAmount = 0,
    required this.deadline,
    this.icon,
    required this.deposits,
  });
}

// =================================================================
// Depositモデル
// =================================================================
@HiveType(typeId: 22) // ユーザー提供のIDを使用
class Deposit extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int amount;

  @HiveField(2)
  final String? memo;

  Deposit({required this.date, required this.amount, this.memo});
}
