import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oshikatu/screens/add_record_screen.dart';
import 'package:oshikatu/screens/management/add_billing_screen.dart';
import 'package:oshikatu/screens/schedule/edit_event_screen.dart';
import 'package:oshikatu/screens/schedule/view_event_screen.dart';
import 'package:oshikatu/screens/settings/edit_oshi_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // For InAppWebView
import 'package:url_launcher/url_launcher.dart'; // For launching URLs
import '../models/oshi_model.dart';
import '../models/schedule_models.dart';
import '../models/record_model.dart';
import '../models/billing_model.dart';
import 'package:oshikatu/widgets/animated_gradient_app_bar.dart';
import 'package:oshikatu/services/reward_ad_service.dart';
import 'package:provider/provider.dart';
import 'package:oshikatu/providers/ad_provider.dart';

// Helper to launch URL externally, moved to top-level
Future<void> _launchUrlExternal(BuildContext context, String url) async {
  String normalizedUrl = url;
  if (!normalizedUrl.startsWith('http://') &&
      !normalizedUrl.startsWith('https://')) {
    normalizedUrl = 'https://$normalizedUrl';
  }
  final uri = Uri.parse(normalizedUrl);
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'could_not_launch_url'.tr(namedArgs: {'url': normalizedUrl}))),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'error_launching_url'.tr(namedArgs: {'error': e.toString()}))),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Google Play StoreへのURLを生成するヘルパー関数
  void _launchGooglePlayStore(BuildContext context) async {
    const String packageName = 'com.ryosuke.oshikatu'; // アプリのパッケージ名
    final Uri googlePlayUrl = Uri.parse(
      'market://details?id=$packageName&showAllReviews=true',
    );
    final Uri googlePlayWebUrl = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageName&showAllReviews=true',
    );

    if (await canLaunchUrl(googlePlayUrl)) {
      await launchUrl(googlePlayUrl);
    } else if (await canLaunchUrl(googlePlayWebUrl)) {
      await launchUrl(googlePlayWebUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('could_not_launch_google_play'.tr())),
      );
    }
  }

  // --- Reward Logic Methods ---
  void _handleReward(RewardType type, BuildContext context) {
    final settingsBox = Hive.box('settings');
    String message = '';

    switch (type) {
      case RewardType.adFree:
        final adFreeUntil = DateTime.now().add(const Duration(days: 1));
        settingsBox.put('ad_free_until', adFreeUntil.toIso8601String());
        message = 'reward_earned_ad_free'.tr();
        break;
      case RewardType.experienceBoost:
        settingsBox.put('experience_boost_active', true);
        message = 'reward_earned_exp_boost'.tr();
        break;
      case RewardType.customTag:
        final currentRights = settingsBox.get('custom_tag_creation_rights',
            defaultValue: 0) as int;
        settingsBox.put('custom_tag_creation_rights', currentRights + 1);
        message = 'reward_earned_custom_tag'.tr();
        break;
    }

    // Update the ad status
    Provider.of<AdProvider>(context, listen: false).checkAdStatus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showRewardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('select_reward'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.ad_units_outlined),
                title: Text('reward_ad_free_title'.tr()),
                subtitle: Text('reward_ad_free_subtitle'.tr()),
                onTap: () {
                  Navigator.of(dialogContext).pop(); // Close the dialog
                  RewardAdService().showAd(
                    context: context,
                    rewardType: RewardType.adFree,
                    onRewardEarned: (type) => _handleReward(type, context),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: Text('reward_exp_boost_title'.tr()),
                subtitle: Text('reward_exp_boost_subtitle'.tr()),
                onTap: () {
                  Navigator.of(dialogContext).pop(); // Close the dialog
                  RewardAdService().showAd(
                    context: context,
                    rewardType: RewardType.experienceBoost,
                    onRewardEarned: (type) => _handleReward(type, context),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add_reaction_outlined),
                title: Text('reward_custom_tag_title'.tr()),
                subtitle: Text('reward_custom_tag_subtitle'.tr()),
                onTap: () {
                  Navigator.of(dialogContext).pop(); // Close the dialog
                  RewardAdService().showAd(
                    context: context,
                    rewardType: RewardType.customTag,
                    onRewardEarned: (type) => _handleReward(type, context),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
  // --- End of Reward Logic ---

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback を使用して、ウィジェットがビルドされた後にロジックを実行
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsBox = Hive.box('settings');
      final String? appStartDateString = settingsBox.get('app_start_date');
      final int recordCount = settingsBox.get('record_count', defaultValue: 0);
      final bool feedbackPromptShownUsage =
          settingsBox.get('feedback_prompt_shown_usage', defaultValue: false);

      if (!feedbackPromptShownUsage && appStartDateString != null) {
        final DateTime appStartDate = DateTime.parse(appStartDateString);
        final DateTime now = DateTime.now();
        final int daysSinceStart = now.difference(appStartDate).inDays;

        // 条件: アプリ利用3日後かつ記録3件以上
        if (daysSinceStart >= 3 && recordCount >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('feedback_prompt_message'.tr()),
              action: SnackBarAction(
                label: 'feedback_prompt_action'.tr(),
                onPressed: () {
                  _launchGooglePlayStore(context);
                },
              ),
              duration: const Duration(seconds: 10),
            ),
          );
          await settingsBox.put('feedback_prompt_shown_usage', true); // フラグを立てる
        }
      }
    });

    return Scaffold(
      appBar: AnimatedGradientAppBar(
        title: Text('home_title'.tr()),
      ),
      // ★★★ Listenable.mergeをやめ、ValueListenableBuilderをネストする方式に変更 (Corrected) ★★★
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Oshi>('oshis').listenable(),
        builder: (context, oshiBox, _) {
          return ValueListenableBuilder(
            valueListenable: Hive.box<Event>('events').listenable(),
            builder: (context, eventBox, _) {
              return ValueListenableBuilder(
                valueListenable: Hive.box<Record>('records').listenable(),
                builder: (context, recordBox, _) {
                  return ValueListenableBuilder(
                    valueListenable:
                        Hive.box<BillingRecord>('billing_records').listenable(),
                    builder: (context, billingBox, _) {
                      Oshi? gekiOshi;
                      try {
                        gekiOshi = oshiBox.values.firstWhere(
                            (oshi) => oshi.level == OshiLevel.saiOshi);
                      } catch (e) {
                        gekiOshi = null;
                      }

                      final today = DateTime.now();
                      final todayStart =
                          DateTime(today.year, today.month, today.day);

                      final List<Event> allEvents = eventBox.values.toList();
                      final List<Event> allUpcomingEvents = allEvents
                          .where((e) => e.date.isAfter(
                              todayStart.subtract(const Duration(days: 1))))
                          .toList();

                      allUpcomingEvents
                          .sort((a, b) => a.date.compareTo(b.date));
                      final displayEvents = allUpcomingEvents.take(5).toList();

                      return ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          _buildGekiOshiCard(context, gekiOshi),
                          const SizedBox(height: 16),
                          // --- Reward Ad Button Added ---
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              onTap: () {
                                _showRewardDialog(context);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.movie_creation_outlined,
                                        color: Colors.amber),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'get_reward_by_watching_video'.tr(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // --- End of Addition ---
                          const SizedBox(height: 16),
                          _buildQuickActionButtons(context),
                          const SizedBox(height: 24),
                          _buildUpcomingEventsSection(context,
                              'upcoming_events'.tr(), displayEvents, oshiBox),
                          const SizedBox(height: 16),
                          if (gekiOshi != null)
                            if (gekiOshi.officialWebsite != null &&
                                gekiOshi.officialWebsite!.isNotEmpty)
                              OshiWebsiteView(
                                  officialWebsite: gekiOshi.officialWebsite!)
                            else
                              _buildAddWebsiteCard(context, gekiOshi),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGekiOshiCard(BuildContext context, Oshi? gekiOshi) {
    if (gekiOshi == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('set_saioshi_prompt'.tr()),
        ),
      );
    }

    final anniversaryInfo = _getAnniversaryInfo(gekiOshi.startDate);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(gekiOshi.startDate.year,
        gekiOshi.startDate.month, gekiOshi.startDate.day);
    final daysSince = today.difference(startDate).inDays + 1;

    final duration = _calculateDuration(startDate, today);
    final years = duration['years']!;
    final months = duration['months']!;
    final durationDays = duration['days']!;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (gekiOshi.imagePath != null && gekiOshi.imagePath!.isNotEmpty)
            Center(
              child: CircleAvatar(
                radius: 100,
                backgroundImage: FileImage(File(gekiOshi.imagePath!)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gekiOshi.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: gekiOshi.mainColorValue != null
                            ? Color(gekiOshi.mainColorValue!)
                            : null,
                      ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge,
                    children: <TextSpan>[
                      TextSpan(text: 'days_since_oshi_start_prefix'.tr()),
                      TextSpan(
                        text: '$daysSince',
                        style: TextStyle(
                          color: gekiOshi.mainColorValue != null
                              ? Color(gekiOshi.mainColorValue!)
                              : Theme.of(context).colorScheme.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: 'days_since_oshi_start_suffix'.tr()),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'duration_since_oshi_start'.tr(namedArgs: {
                    'years': years.toString(),
                    'months': months.toString(),
                    'days': durationDays.toString()
                  }),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (anniversaryInfo.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    anniversaryInfo,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculateDuration(DateTime startDate, DateTime endDate) {
    int years = endDate.year - startDate.year;
    int months = endDate.month - startDate.month;
    int days = endDate.day - startDate.day;

    if (days < 0) {
      months--;
      int daysInPreviousMonth = DateTime(endDate.year, endDate.month, 0).day;
      days += daysInPreviousMonth;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return {'years': years, 'months': months, 'days': days + 1};
  }

  Widget _buildAddWebsiteCard(BuildContext context, Oshi oshi) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.language, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'add_website_prompt'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_link),
              label: Text('add_website_button'.tr()),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditOshiScreen(oshi: oshi),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              context,
              icon: Icons.edit_note,
              label: 'quick_action_record'.tr(),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AddRecordScreen())),
            ),
            _buildActionButton(
              context,
              icon: Icons.payment,
              label: 'quick_action_expense'.tr(),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AddBillingScreen())),
            ),
            _buildActionButton(
              context,
              icon: Icons.calendar_today,
              label: 'quick_action_schedule'.tr(),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const EditEventScreen(event: null))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          icon: Icon(icon),
          iconSize: 24,
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.secondaryContainer.withOpacity(0.5),
            foregroundColor: colorScheme.onSecondaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  String _getAnniversaryInfo(DateTime startDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final daysSince = today.difference(startDate).inDays + 1;
    final next100DayAnniversary = ((daysSince / 100).ceil() * 100);
    final daysTo100 = next100DayAnniversary - daysSince;
    if (daysTo100 >= 0 && daysTo100 <= 7) {
      return daysTo100 == 0
          ? 'anniversary_today_days'
              .tr(namedArgs: {'daysSince': daysSince.toString()})
          : 'anniversary_countdown_days'.tr(namedArgs: {
              'daysTo100': daysTo100.toString(),
              'next100DayAnniversary': next100DayAnniversary.toString()
            });
    }

    final nextYearAnniversary = DateTime(
        startDate.year + (today.year - startDate.year) + 1,
        startDate.month,
        startDate.day);
    final daysToYear = nextYearAnniversary.difference(today).inDays;
    if (daysToYear >= 0 && daysToYear <= 7) {
      final years = nextYearAnniversary.year - startDate.year;
      return daysToYear == 0
          ? 'anniversary_today_years'.tr(namedArgs: {'years': years.toString()})
          : 'anniversary_countdown_years'.tr(namedArgs: {
              'daysToYear': daysToYear.toString(),
              'years': years.toString()
            });
    }

    return '';
  }

  Widget _buildUpcomingEventsSection(BuildContext context, String title,
      List<Event> items, Box<Oshi> oshiBox) {
    final formatter = DateFormat('M/d(E)', 'ja_JP');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Text('no_upcoming_events'.tr())),
          )
        else
          ...items.map((item) {
            final isToday = isSameDay(item.date, DateTime.now());
            Oshi? oshi;
            if (item.oshiId != null) {
              final matchingOshis =
                  oshiBox.values.where((o) => o.id == item.oshiId);
              if (matchingOshis.isNotEmpty) {
                oshi = matchingOshis.first;
              }
            }
            Color iconColor =
                eventCategoryDetails[item.category]?['color'] as Color? ??
                    Colors.grey;
            if (item.category == EventCategory.birthday &&
                oshi?.mainColorValue != null) {
              iconColor = Color(oshi!.mainColorValue!);
            }
            return ListTile(
              leading: Icon(
                eventCategoryDetails[item.category]?['icon'] as IconData? ??
                    Icons.help_outline,
                color: iconColor,
              ),
              title: Text(item.title,
                  style: TextStyle(
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.normal)),
              subtitle: Text(
                oshi?.name ?? 'no_oshi'.tr(),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              trailing: Text(formatter.format(item.date)),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ViewEventScreen(event: item),
                  ),
                );
              },
            );
          }),
      ],
    );
  }
}

// ★★★ CORRECTED WIDGET ★★★
// This widget has been completely refactored to fix syntax errors and merge conflicting logic.
class OshiWebsiteView extends StatefulWidget {
  final String officialWebsite;

  const OshiWebsiteView({super.key, required this.officialWebsite});

  @override
  State<OshiWebsiteView> createState() => _OshiWebsiteViewState();
}

class _OshiWebsiteViewState extends State<OshiWebsiteView> {
  late InAppWebViewController _webViewController;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('saioshi_official_website'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text('open_in_external_browser'.tr()),
            onPressed: () =>
                _launchUrlExternal(context, widget.officialWebsite),
          ),
        ),
        SizedBox(
          height: 350,
          width: double.infinity,
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest:
                    URLRequest(url: WebUri(widget.officialWebsite)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  transparentBackground: true,
                  allowsInlineMediaPlayback: true,
                  allowsBackForwardNavigationGestures: true,
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  if (mounted) {
                    setState(() {
                      _isLoading = true;
                    });
                  }
                },
                onLoadStop: (controller, url) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                onReceivedServerTrustAuthRequest:
                    (controller, challenge) async {
                  return ServerTrustAuthResponse(
                      action: ServerTrustAuthResponseAction.PROCEED);
                },
                // This logic determines how to handle URL navigations.
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final officialUri = Uri.tryParse(widget.officialWebsite);
                  final requestUri = navigationAction.request.url;

                  // If official URI is invalid, block all navigation.
                  if (officialUri == null || officialUri.host.isEmpty) {
                    return NavigationActionPolicy.CANCEL;
                  }

                  // If the requested URL is on the same domain as the official site, allow it.
                  if (requestUri != null &&
                      requestUri.host.endsWith(officialUri.host)) {
                    return NavigationActionPolicy.ALLOW;
                  }

                  // Otherwise, block navigation to external sites and show a message.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('cannot_navigate_to_external_site'.tr())),
                  );
                  return NavigationActionPolicy.CANCEL;
                },
                // This handles links that try to open a new window (e.g., target="_blank").
                onCreateWindow: (controller, createWindowRequest) async {
                  final url = createWindowRequest.request.url;
                  if (url != null) {
                    // Launch the new window's URL externally.
                    _launchUrlExternal(context, url.toString());
                  }
                  // We've handled the request, so don't create a new webview window.
                  return false;
                },
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
        if (!Platform.isIOS) ...[
          const SizedBox(height: 8),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text('reload_site'.tr()),
              onPressed: () {
                _webViewController.loadUrl(
                    urlRequest:
                        URLRequest(url: WebUri(widget.officialWebsite)));
              },
            ),
          ),
        ],
      ],
    );
  }
}
