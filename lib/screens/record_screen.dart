import 'dart:io' show File, Platform;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/ad_provider.dart';

import '../models/record_model.dart';
import '../models/oshi_model.dart';
import '../services/theme_provider.dart';
import '../services/oshikatsu_level_service.dart';
import 'add_record_screen.dart';
import 'view_record_screen.dart';
import 'oshikatsu_level_info_screen.dart';
import '../utils/custom_page_route.dart';
import '../widgets/ad_banner.dart';
import '../widgets/animated_gradient_app_bar.dart';

// メインのスクリーンウィジェット
class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});
  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _currentIndex = 0;
  double _adBannerHeight = 0; // To store the height of the ad banner

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted && _tabController.index != _currentIndex) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkAndShowFeedbackPrompt() async {
    if (!Platform.isAndroid) return;

    final recordBox = Hive.box<Record>('records');
    final settingsBox = Hive.box('settings');
    final totalRecords = recordBox.length;
    final milestones = [5, 10, 25, 50, 100, 200, 500];

    for (final milestone in milestones) {
      if (totalRecords >= milestone) {
        final feedbackShownKey = 'feedback_prompt_shown_${milestone}_records';
        final bool hasBeenShown =
            settingsBox.get(feedbackShownKey, defaultValue: false);

        if (!hasBeenShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('milestone_feedback_prompt_message'
                      .tr(namedArgs: {'milestone': milestone.toString()})),
                  action: SnackBarAction(
                    label: 'milestone_feedback_prompt_action'.tr(),
                    onPressed: () => _launchGooglePlayStore(context),
                  ),
                  duration: const Duration(seconds: 10),
                ),
              );
            }
          });
          await settingsBox.put(feedbackShownKey, true);
          break;
        }
      }
    }
  }

  void _launchGooglePlayStore(BuildContext context) async {
    const String packageName = 'com.ryosuke.oshikatu';
    final Uri googlePlayUrl =
        Uri.parse('market://details?id=$packageName&showAllReviews=true');
    final Uri googlePlayWebUrl = Uri.parse(
        'https://play.google.com/store/apps/details?id=$packageName&showAllReviews=true');

    if (await canLaunchUrl(googlePlayUrl)) {
      await launchUrl(googlePlayUrl);
    } else if (await canLaunchUrl(googlePlayWebUrl)) {
      await launchUrl(googlePlayWebUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('could_not_launch_google_play'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final adProvider = Provider.of<AdProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isNeonMode ? Colors.black : Colors.white,
      appBar: AnimatedGradientAppBar(
        title: null, // Removed title
        toolbarHeight: 0,
        actions: const [],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.grid_view), text: 'tab_activities'.tr()),
            Tab(
                icon: const Icon(Icons.auto_stories),
                text: 'tab_memories'.tr()),
          ],
        ),
      ),
      body: Column(
        // Wrap body with Column
        children: [
          Expanded(
            // Make TabBarView fill the available space
            child: TabBarView(
              controller: _tabController,
              children: const [
                ActivitiesView(),
                MemoriesView(),
              ],
            ),
          ),
          // Ad banner at the bottom, controlled by AdProvider
          Visibility(
            visible: _currentIndex == 1 && adProvider.shouldShowAds,
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
      floatingActionButton: _currentIndex == 0
          ? Padding(
              // Wrap FAB with Padding
              padding: EdgeInsets.only(
                  bottom: adProvider.shouldShowAds ? _adBannerHeight : 0),
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                      CustomPageRoute<bool>(child: const AddRecordScreen()));
                  if (result == true && mounted) {
                    _checkAndShowFeedbackPrompt();
                  }
                },
                tooltip: 'add_new_record'.tr(),
                child: const Icon(Icons.add),
              ),
            )
          : null,
    );
  }
}

/// 記録削除の確認ダイアログを表示するヘルパー関数
void _showDeleteConfirmDialog(BuildContext context, Record record) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('confirm'.tr()),
      content:
          Text('delete_confirm_message'.tr(namedArgs: {'title': record.title})),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () {
            try {
              record.delete();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('record_deleted'.tr()),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'delete_failed'.tr(namedArgs: {'error': e.toString()})),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          child: Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

/// 「活動」タブのグリッドビュー
class ActivitiesView extends StatefulWidget {
  const ActivitiesView({super.key});

  @override
  State<ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<ActivitiesView> {
  RecordCategory? _selectedCategory;
  String? _selectedOshiId;

  Widget _buildCategorySelector() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isNeonMode = themeProvider.isNeonMode;
    const categories = RecordCategory.values;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: Text('all'.tr()),
            selected: _selectedCategory == null,
            onSelected: (selected) => setState(() => _selectedCategory = null),
          ),
          ...categories.map((categoryKey) {
            final details = categoryDetails[categoryKey]!;
            final isSelected = _selectedCategory == categoryKey;
            final color = details['color'] as Color;
            final selectedTextColor =
                ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                    ? Colors.white
                    : Colors.black;
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ChoiceChip(
                avatar: Icon(
                  details['icon'] as IconData,
                  color: isSelected
                      ? selectedTextColor
                      : (isNeonMode ? Colors.white70 : Colors.black87),
                ),
                label: Text((details['name'] as String).tr()),
                selected: isSelected,
                onSelected: (selected) => setState(
                    () => _selectedCategory = selected ? categoryKey : null),
                selectedColor: color,
                labelStyle: TextStyle(
                  color: isSelected
                      ? selectedTextColor
                      : (isNeonMode ? Colors.white70 : Colors.black87),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOshiSelector() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isNeonMode = themeProvider.isNeonMode;

    return ValueListenableBuilder<Box<Oshi>>(
      valueListenable: Hive.box<Oshi>('oshis').listenable(),
      builder: (context, oshiBox, _) {
        final oshis = oshiBox.values.toList();
        if (oshis.isEmpty) {
          return const SizedBox.shrink();
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Row(
            children: [
              ChoiceChip(
                label: Text('all'.tr()),
                selected: _selectedOshiId == null,
                onSelected: (selected) =>
                    setState(() => _selectedOshiId = null),
              ),
              ...oshis.map((oshi) {
                final isSelected = _selectedOshiId == oshi.id;
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ChoiceChip(
                    avatar: oshi.imagePath != null && oshi.imagePath!.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: FileImage(File(oshi.imagePath!)),
                          )
                        : null,
                    label: Text(oshi.name),
                    selected: isSelected,
                    onSelected: (selected) => setState(
                        () => _selectedOshiId = selected ? oshi.id : null),
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isNeonMode ? Colors.white70 : Colors.black87),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCategorySelector(),
        _buildOshiSelector(),
        const Divider(height: 1),
        Expanded(
          child: ValueListenableBuilder<Box<Record>>(
            valueListenable: Hive.box<Record>('records').listenable(),
            builder: (context, box, _) {
              final records = box.values.where((record) {
                final categoryMatch = _selectedCategory == null ||
                    record.category == _selectedCategory;
                final oshiMatch =
                    _selectedOshiId == null || record.oshiId == _selectedOshiId;
                return categoryMatch && oshiMatch;
              }).toList()
                ..sort((a, b) => b.date.compareTo(a.date));

              if (records.isEmpty) {
                return Center(
                    child: Text(
                        _selectedCategory == null && _selectedOshiId == null
                            ? 'no_records_prompt'.tr()
                            : 'no_records_for_filter'.tr()));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(CustomPageRoute(
                          child: ViewRecordScreen(record: record)));
                    },
                    onLongPress: () {
                      _showDeleteConfirmDialog(context, record);
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              color: Colors.grey[200],
                              child: record.imagePath != null &&
                                      record.imagePath!.isNotEmpty
                                  ? Image.file(File(record.imagePath!),
                                      fit: BoxFit.cover)
                                  : Icon(
                                      categoryDetails[record.category]?['icon']
                                              as IconData? ??
                                          Icons.event,
                                      size: 50,
                                      color: Colors.grey[400],
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  record.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('yyyy/MM/dd').format(record.date),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 「思い出」タブの新しいビュー
class MemoriesView extends StatefulWidget {
  const MemoriesView({super.key});

  @override
  State<MemoriesView> createState() => _MemoriesViewState();
}

class _MemoriesViewState extends State<MemoriesView> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      children: [
        Expanded(
          child: ValueListenableBuilder<Box<Record>>(
            valueListenable: Hive.box<Record>('records').listenable(),
            builder: (context, recordBox, _) {
              final levelService = OshikatsuLevelService(recordBox);
              final records = recordBox.values.toList();

              return ValueListenableBuilder<Box<Oshi>>(
                valueListenable: Hive.box<Oshi>('oshis').listenable(),
                builder: (context, oshiBox, _) {
                  return Container(
                    color:
                        themeProvider.isNeonMode ? Colors.black : Colors.white,
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        _buildOshikatsuLevelCard(levelService),
                        const SizedBox(height: 24),
                        if (records.isEmpty)
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.sentiment_neutral,
                                    size: 80, color: Color(0xFFBDBDBD)),
                                const SizedBox(height: 16),
                                Text(
                                  'no_memories_prompt'.tr(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 16, color: Color(0xFF757575)),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          _buildSummarySection(context, records),
                          const SizedBox(height: 24),
                          _buildTimelineSection(
                              context, records, oshiBox.values.toList()),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOshikatsuLevelCard(OshikatsuLevelService levelService) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onLongPress: () {
        Navigator.of(context).push(
          CustomPageRoute(
            child: const OshikatsuLevelInfoScreen(),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(16.0),
        elevation: 4,
        color: themeProvider.isNeonMode ? Colors.grey[900] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(levelService.levelData.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      Navigator.of(context).push(
                        CustomPageRoute(
                          child: const OshikatsuLevelInfoScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(levelService.levelData.description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Lv. ${levelService.currentLevel}'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: levelService.progressToNextLevel,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, List<Record> records) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final totalRecords = records.length;
    final averageRating = records.isNotEmpty
        ? records.map((r) => r.rating).reduce((a, b) => a + b) / totalRecords
        : 0.0;
    Map<RecordCategory, int> categoryCounts = {};
    for (var record in records) {
      categoryCounts.update(record.category, (value) => value + 1,
          ifAbsent: () => 1);
    }
    RecordCategory? mostFrequentCategory;
    if (categoryCounts.isNotEmpty) {
      mostFrequentCategory = categoryCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }
    return ExpansionTile(
      backgroundColor:
          themeProvider.isNeonMode ? Colors.grey[900] : Colors.white,
      title: Text('memories_summary'.tr(),
          style: Theme.of(context).textTheme.titleLarge),
      initiallyExpanded: true,
      children: [
        ListTile(
          leading: const Icon(Icons.format_list_numbered),
          title: Text('total_records'.tr()),
          trailing: Text('$totalRecords ${'records_unit'.tr()}',
              style: const TextStyle(fontSize: 16)),
        ),
        ListTile(
          leading: const Icon(Icons.category),
          title: Text('most_frequent_category'.tr()),
          trailing: mostFrequentCategory != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      categoryDetails[mostFrequentCategory]!['icon']
                          as IconData,
                      color: categoryDetails[mostFrequentCategory]!['color']
                          as Color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (categoryDetails[mostFrequentCategory]!['name'] as String)
                          .tr(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                )
              : Text('none'.tr(), style: const TextStyle(fontSize: 16)),
        ),
        ListTile(
          leading: const Icon(Icons.star_half),
          title: Text('average_rating'.tr()),
          trailing: Text(averageRating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(
      BuildContext context, List<Record> records, List<Oshi> oshis) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Map<String, List<Record>> recordsByOshi = {};
    for (var record in records) {
      final oshiId = record.oshiId ?? 'unknown';
      if (recordsByOshi[oshiId] == null) {
        recordsByOshi[oshiId] = [];
      }
      recordsByOshi[oshiId]!.add(record);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('oshi_goto_timeline'.tr(),
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...recordsByOshi.entries.map((entry) {
          Oshi? oshi;
          try {
            oshi = oshis.firstWhere((o) => o.id == entry.key);
          } catch (e) {
            oshi = null;
          }
          return ExpansionTile(
            backgroundColor:
                themeProvider.isNeonMode ? Colors.grey[900] : Colors.white,
            title: Text(oshi?.name ?? 'oshi_unclassified'.tr()),
            children: entry.value.map((record) {
              return ListTile(
                leading: Text(DateFormat('M/d').format(record.date)),
                title: Text(record.title),
                subtitle: Text(record.emotionTags.join(', ')),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
