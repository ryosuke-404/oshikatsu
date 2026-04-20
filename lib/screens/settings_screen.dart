import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // 追加
import '../models/oshi_model.dart';
import '../services/theme_provider.dart';
import 'settings/add_oshi_screen.dart';
import 'settings/view_oshi_screen.dart';
import 'settings/about_app_screen.dart';
import 'settings/terms_of_service_screen.dart';
import 'settings/privacy_policy_screen.dart';
import '../utils/custom_page_route.dart';
import 'package:oshikatu/widgets/custom_tap_effect.dart';
import 'package:oshikatu/widgets/ad_banner.dart';
import '../providers/ad_provider.dart';

import 'package:oshikatu/widgets/animated_gradient_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _adBannerHeight = 0;

  void _showLanguageDialog() {
    final Map<String, Locale> supportedLanguages = {
      'English': const Locale('en'),
      '日本語': const Locale('ja'),
      '简体中文': const Locale('zh', 'CN'),
      '繁體中文': const Locale('zh', 'TW'),
      '한국어': const Locale('ko'),
      'Español': const Locale('es'),
      'Français': const Locale('fr'),
      'Deutsch': const Locale('de'),
      'Português (Brasil)': const Locale('pt', 'BR'),
      'Русский': const Locale('ru'),
      'हिन्दी': const Locale('hi'),
      'العربية': const Locale('ar'),
      'Bahasa Indonesia': const Locale('id'),
      'Bahasa Melayu': const Locale('ms'),
      'ไทย': const Locale('th'),
      'Tiếng Việt': const Locale('vi'),
      'Italiano': const Locale('it'),
      'Nederlands': const Locale('nl'),
      'Polski': const Locale('pl'),
      'Türkçe': const Locale('tr'),
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('select_language'.tr()),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: supportedLanguages.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  onTap: () {
                    context.setLocale(entry.value);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final adProvider = Provider.of<AdProvider>(context);

    return Scaffold(
      appBar: AnimatedGradientAppBar(
        title: Text('oshi_title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: Text('language'.tr()),
                          onTap: () {
                            Navigator.pop(context); // BottomSheetを閉じる
                            _showLanguageDialog();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: Text('about_app'.tr()),
                          onTap: () {
                            Navigator.pop(context); // BottomSheetを閉じる
                            Navigator.of(context).push(
                                CustomPageRoute(child: const AboutAppScreen()));
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: Text('terms_of_service'.tr()),
                          onTap: () {
                            Navigator.pop(context); // BottomSheetを閉じる
                            Navigator.of(context).push(CustomPageRoute(
                                child: const TermsOfServiceScreen()));
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip_outlined),
                          title: Text('privacy_policy'.tr()),
                          onTap: () {
                            Navigator.pop(context); // BottomSheetを閉じる
                            Navigator.of(context).push(CustomPageRoute(
                                child: const PrivacyPolicyScreen()));
                          },
                        ),
                        // フィードバックを送る項目をここに追加
                        ListTile(
                          leading: const Icon(Icons.feedback),
                          title: Text('send_feedback'.tr()),
                          onTap: () async {
                            Navigator.pop(context); // BottomSheetを閉じる
                            const String packageName =
                                'com.ryosuke.oshikatu'; // アプリのパッケージ名
                            final Uri googlePlayUrl = Uri.parse(
                              'market://details?id=$packageName&showAllReviews=true',
                            );
                            final Uri googlePlayWebUrl = Uri.parse(
                              'https://play.google.com/store/apps/details?id=$packageName&showAllReviews=true',
                            );

                            if (await canLaunchUrl(googlePlayUrl)) {
                              await launchUrl(googlePlayUrl);
                            } else if (await canLaunchUrl(googlePlayWebUrl)) {
                              await launchUrl(googlePlayWebUrl,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'could_not_launch_google_play'.tr())),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<Box<Oshi>>(
              valueListenable: Hive.box<Oshi>('oshis').listenable(),
              builder: (context, box, _) {
                final oshiList = box.values.toList();
                oshiList.sort((a, b) => a.level.index.compareTo(b.level.index));

                return Column(
                  children: [
                    SwitchListTile(
                      title: Text('dark_mode'.tr()),
                      value: themeProvider.isNeonMode,
                      onChanged: (bool value) {
                        themeProvider.toggleNeonMode();
                      },
                      secondary: const Icon(Icons.dark_mode_outlined),
                    ),
                    const Divider(),
                    if (oshiList.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.person_add_alt_1,
                                  size: 80, color: Color(0xFFBDBDBD)),
                              const SizedBox(height: 16),
                              Text(
                                'no_oshi_prompt'.tr(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 16, color: Color(0xFF757575)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: oshiList.length,
                          itemBuilder: (context, index) {
                            final oshi = oshiList[index];
                            Oshi? mainOshi;
                            try {
                              mainOshi = oshiList.firstWhere(
                                  (o) => o.level == OshiLevel.saiOshi);
                            } catch (e) {
                              mainOshi = null;
                            }
                            return _buildOshiCard(
                                oshi, oshi.id == mainOshi?.id);
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Visibility(
            visible: false,
            child: AdBanner(
              onAdLoaded: (ad) {
                if (mounted) {
                  setState(() {
                    _adBannerHeight = ad.size.height.toDouble();
                  });
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(CustomPageRoute(child: const AddOshiScreen())),
        tooltip: 'add_new_oshi'.tr(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOshiCard(Oshi oshi, bool isMain) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final details = oshiLevelDetails[oshi.level]!;
    final oshiDuration = _calculateOshiDuration(oshi.startDate);

    Color borderColor = oshi.mainColorValue != null
        ? Color(oshi.mainColorValue!)
        : Colors.transparent;
    final textColor = themeProvider.isNeonMode ? Colors.white : Colors.black;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: isMain ? 8 : 4,
      color: themeProvider.isNeonMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: isMain ? 3 : 1.5),
      ),
      child: CustomTapEffect(
        onTap: () => Navigator.of(context)
            .push(CustomPageRoute(child: ViewOshiScreen(oshi: oshi))),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage:
                    (oshi.imagePath != null && oshi.imagePath!.isNotEmpty)
                        ? FileImage(File(oshi.imagePath!))
                        : null,
                child: (oshi.imagePath == null || oshi.imagePath!.isEmpty)
                    ? Icon(details['icon'] as IconData, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(oshi.name,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    const SizedBox(height: 4),
                    Text('推し歴: $oshiDuration',
                        style: TextStyle(color: textColor.withOpacity(0.7))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateOshiDuration(DateTime startDate) {
    final now = DateTime.now();
    final difference = now.difference(startDate);
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;

    if (years > 0) return '$years年 $monthsヶ月';
    if (months > 0) return '$monthsヶ月';
    return '${difference.inDays}日';
  }
}

// ヘルパー関数 (クラスの外に定義)
String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
