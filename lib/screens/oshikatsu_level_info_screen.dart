import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OshikatsuLevelInfoScreen extends StatelessWidget {
  const OshikatsuLevelInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Define colors that adapt to the theme
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color titleColor =
        isDarkMode ? Colors.amberAccent : Colors.deepPurple;
    final Color accentColor =
        isDarkMode ? Colors.cyanAccent : Colors.pinkAccent;
    final Color greyColor = isDarkMode ? Colors.grey[600]! : Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: Text('oshikatsu_level_info_title'.tr()),
        // テーマに応じて文字色を調整
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
                'what_is_oshikatsu_level_title'.tr(), titleColor),
            _buildBodyText(
              'what_is_oshikatsu_level_description'.tr(),
              textColor,
            ),
            const SizedBox(height: 20),
            _buildSectionTitle(
                'how_level_is_determined_title'.tr(), titleColor),
            _buildBodyText(
              'how_level_is_determined_description'.tr(),
              textColor,
            ),
            _buildBulletPoint(
                'how_level_is_determined_bullet1'.tr(), textColor),
            _buildBulletPoint(
                'how_level_is_determined_bullet2'.tr(), textColor),
            _buildBulletPoint(
                'how_level_is_determined_bullet3'.tr(), textColor),
            _buildBulletPoint(
                'how_level_is_determined_bullet4'.tr(), textColor),
            const SizedBox(height: 20),
            _buildSectionTitle('level_details_title'.tr(), titleColor),
            _buildLevelDescription(
              level: 1,
              name: 'level_1_name'.tr(),
              description: 'level_1_description'.tr(),
              recordsNeeded: 'records_range_1_5'.tr(),
              textColor: textColor,
              accentColor: accentColor,
              greyColor: greyColor,
            ),
            _buildLevelDescription(
              level: 2,
              name: 'level_2_name'.tr(),
              description: 'level_2_description'.tr(),
              recordsNeeded: 'records_range_6_15'.tr(),
              textColor: textColor,
              accentColor: accentColor,
              greyColor: greyColor,
            ),
            _buildLevelDescription(
              level: 3,
              name: 'level_3_name'.tr(),
              description: 'level_3_description'.tr(),
              recordsNeeded: 'records_range_16_30'.tr(),
              textColor: textColor,
              accentColor: accentColor,
              greyColor: greyColor,
            ),
            _buildLevelDescription(
              level: 4,
              name: 'level_4_name'.tr(),
              description: 'level_4_description'.tr(),
              recordsNeeded: 'records_range_31_50'.tr(),
              textColor: textColor,
              accentColor: accentColor,
              greyColor: greyColor,
            ),
            _buildLevelDescription(
              level: 5,
              name: 'level_5_name'.tr(),
              description: 'level_5_description'.tr(),
              recordsNeeded: 'records_range_51_75'.tr(),
              textColor: textColor,
              accentColor: accentColor,
              greyColor: greyColor,
            ),
            _buildLevelDescription(
              level: 6,
              name: 'level_6_name'.tr(),
              description: 'level_6_description'.tr(),
              recordsNeeded: 'records_range_76_100'.tr(),
              textColor: textColor,
              accentColor: accentColor,
              greyColor: greyColor,
            ),
            _buildLevelDescription(
              level: 7,
              name: 'level_7_name'.tr(),
              description: 'level_7_description'.tr(),
              recordsNeeded: 'records_range_101_150'.tr(),
              textColor: textColor,
              accentColor: accentColor,
              greyColor: greyColor,
            ),
            _buildLevelDescription(
              level: 8,
              name: 'level_8_name'.tr(),
              description: 'level_8_description'.tr(),
              recordsNeeded: 'records_range_151_200'.tr(),
              textColor: textColor,
              accentColor: accentColor,
              greyColor: greyColor,
            ),
            _buildLevelDescription(
              level: 9,
              name: 'level_9_name'.tr(),
              description: 'level_9_description'.tr(),
              recordsNeeded: 'records_range_201_300'.tr(),
              textColor: textColor,
              accentColor: accentColor,
              greyColor: greyColor,
            ),
            _buildLevelDescription(
              level: 10,
              name: 'level_10_name'.tr(),
              description: 'level_10_description'.tr(),
              recordsNeeded: 'records_range_300_plus'.tr(),
              textColor: textColor,
              accentColor: accentColor,
              greyColor: greyColor,
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('level_up_merits_title'.tr(), titleColor),
            _buildBodyText(
              'level_up_merits_description'.tr(),
              textColor,
            ),
            const SizedBox(height: 20),
            _buildSectionTitle(
                'to_enjoy_oshikatsu_more_title'.tr(), titleColor),
            _buildBodyText(
              'to_enjoy_oshikatsu_more_description'.tr(),
              textColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildBodyText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: color,
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(fontSize: 16, color: color),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelDescription({
    required int level,
    required String name,
    required String description,
    required String recordsNeeded,
    required Color textColor,
    required Color accentColor,
    required Color greyColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lv.$level【$name】',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'records_needed_label'.tr(namedArgs: {'records': recordsNeeded}),
            style: TextStyle(
              fontSize: 14,
              color: greyColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
