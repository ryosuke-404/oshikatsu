import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '・$title',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
            child: Text(
              description,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBarForegroundColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.black87 // ライトモードでは黒系の色
            : Colors.white; // ダークモードでは白

    return Scaffold(
      appBar: AppBar(
        title: Text('about_app'.tr()),
        foregroundColor: appBarForegroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'about_app_header'.tr(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'about_app_version'.tr(),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              'about_app_description'.tr(),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              'about_app_main_features'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem('feature_oshi_management_title'.tr(),
                'feature_oshi_management_description'.tr()),
            _buildFeatureItem('feature_schedule_event_title'.tr(),
                'feature_schedule_event_description'.tr()),
            _buildFeatureItem('feature_goods_management_title'.tr(),
                'feature_goods_management_description'.tr()),
            _buildFeatureItem('feature_expense_tracking_title'.tr(),
                'feature_expense_tracking_description'.tr()),
            _buildFeatureItem('feature_mission_title'.tr(),
                'feature_mission_description'.tr()),
            _buildFeatureItem(
                'feature_record_title'.tr(), 'feature_record_description'.tr()),
            _buildFeatureItem('feature_series_management_title'.tr(),
                'feature_series_management_description'.tr()),
            _buildFeatureItem(
              'feature_theme_settings_title'.tr(),
              'feature_theme_settings_description'.tr(),
            ),
            const SizedBox(height: 24),
            Text(
              'about_app_developer'.tr(),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
