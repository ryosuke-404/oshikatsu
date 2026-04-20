import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';
import '../models/record_model.dart';

class LevelData {
  final String title;
  final String description;

  LevelData({required this.title, required this.description});
}

class OshikatsuLevelService {
  final Box<Record> recordBox;
  final Box _settingsBox = Hive.box('settings');

  OshikatsuLevelService(this.recordBox);

  int get recordCount {
    final bonusRecordCount =
        _settingsBox.get('bonus_record_count', defaultValue: 0) as int;
    return recordBox.length + bonusRecordCount;
  }

  LevelData get levelData {
    if (recordCount >= 300) {
      return LevelData(
          title: 'level_10_title_full'.tr(),
          description: 'level_10_description'.tr());
    } else if (recordCount >= 201) {
      return LevelData(
          title: 'level_9_title_full'.tr(),
          description: 'level_9_description'.tr());
    } else if (recordCount >= 151) {
      return LevelData(
          title: 'level_8_title_full'.tr(),
          description: 'level_8_description'.tr());
    } else if (recordCount >= 101) {
      return LevelData(
          title: 'level_7_title_full'.tr(),
          description: 'level_7_description'.tr());
    } else if (recordCount >= 76) {
      return LevelData(
          title: 'level_6_title_full'.tr(),
          description: 'level_6_description'.tr());
    } else if (recordCount >= 51) {
      return LevelData(
          title: 'level_5_title_full'.tr(),
          description: 'level_5_description'.tr());
    } else if (recordCount >= 31) {
      return LevelData(
          title: 'level_4_title_full'.tr(),
          description: 'level_4_description'.tr());
    } else if (recordCount >= 16) {
      return LevelData(
          title: 'level_3_title_full'.tr(),
          description: 'level_3_description'.tr());
    } else if (recordCount >= 6) {
      return LevelData(
          title: 'level_2_title_full'.tr(),
          description: 'level_2_description'.tr());
    } else if (recordCount >= 1) {
      return LevelData(
          title: 'level_1_title_full'.tr(),
          description: 'level_1_description'.tr());
    } else {
      return LevelData(
          title: 'level_0_title'.tr(), description: 'level_0_description'.tr());
    }
  }

  int get currentLevel {
    if (recordCount >= 300) {
      return 10;
    } else if (recordCount >= 201) {
      return 9;
    } else if (recordCount >= 151) {
      return 8;
    } else if (recordCount >= 101) {
      return 7;
    } else if (recordCount >= 76) {
      return 6;
    } else if (recordCount >= 51) {
      return 5;
    } else if (recordCount >= 31) {
      return 4;
    } else if (recordCount >= 16) {
      return 3;
    } else if (recordCount >= 6) {
      return 2;
    } else if (recordCount >= 1) {
      return 1;
    } else {
      return 0;
    }
  }

  double get progressToNextLevel {
    if (recordCount >= 300) {
      return 1.0; // 最大レベル到達
    } else if (recordCount >= 201) {
      return (recordCount - 201) / 99.0; // 201-300 (99段階)
    } else if (recordCount >= 151) {
      return (recordCount - 151) / 50.0; // 151-200 (50段階)
    } else if (recordCount >= 101) {
      return (recordCount - 101) / 50.0; // 101-150 (50段階)
    } else if (recordCount >= 76) {
      return (recordCount - 76) / 25.0; // 76-100 (25段階)
    } else if (recordCount >= 51) {
      return (recordCount - 51) / 25.0; // 51-75 (25段階)
    } else if (recordCount >= 31) {
      return (recordCount - 31) / 20.0; // 31-50 (20段階)
    } else if (recordCount >= 16) {
      return (recordCount - 16) / 15.0; // 16-30 (15段階)
    } else if (recordCount >= 6) {
      return (recordCount - 6) / 10.0; // 6-15 (10段階)
    } else if (recordCount >= 1) {
      return (recordCount - 1) / 5.0; // 1-5 (5段階)
    } else {
      return 0.0; // レベル0の場合
    }
  }

  // 次のレベルまでに必要な記録数を取得
  int get recordsNeededForNextLevel {
    if (recordCount >= 300) {
      return 0; // 最大レベル到達
    } else if (recordCount >= 201) {
      return 300 - recordCount;
    } else if (recordCount >= 151) {
      return 201 - recordCount;
    } else if (recordCount >= 101) {
      return 151 - recordCount;
    } else if (recordCount >= 76) {
      return 101 - recordCount;
    } else if (recordCount >= 51) {
      return 76 - recordCount;
    } else if (recordCount >= 31) {
      return 51 - recordCount;
    } else if (recordCount >= 16) {
      return 31 - recordCount;
    } else if (recordCount >= 6) {
      return 16 - recordCount;
    } else if (recordCount >= 1) {
      return 6 - recordCount;
    } else {
      return 1 - recordCount;
    }
  }

  // 次のレベルの情報を取得
  LevelData? get nextLevelData {
    final nextLevel = currentLevel + 1;
    if (nextLevel > 10) return null;

    switch (nextLevel) {
      case 1:
        return LevelData(
            title: 'level_1_title_full'.tr(),
            description: 'level_1_description'.tr());
      case 2:
        return LevelData(
            title: 'level_2_title_full'.tr(),
            description: 'level_2_description'.tr());
      case 3:
        return LevelData(
            title: 'level_3_title_full'.tr(),
            description: 'level_3_description'.tr());
      case 4:
        return LevelData(
            title: 'level_4_title_full'.tr(),
            description: 'level_4_description'.tr());
      case 5:
        return LevelData(
            title: 'level_5_title_full'.tr(),
            description: 'level_5_description'.tr());
      case 6:
        return LevelData(
            title: 'level_6_title_full'.tr(),
            description: 'level_6_description'.tr());
      case 7:
        return LevelData(
            title: 'level_7_title_full'.tr(),
            description: 'level_7_description'.tr());
      case 8:
        return LevelData(
            title: 'level_8_title_full'.tr(),
            description: 'level_8_description'.tr());
      case 9:
        return LevelData(
            title: 'level_9_title_full'.tr(),
            description: 'level_9_description'.tr());
      case 10:
        return LevelData(
            title: 'level_10_title_full'.tr(),
            description: 'level_10_description'.tr());
      default:
        return null;
    }
  }
}
