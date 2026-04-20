import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/record_model.dart';
import '../../models/oshi_model.dart';
import '../../services/theme_provider.dart';
import '../../services/oshikatsu_level_service.dart'; // Import OshikatsuLevelService
import '../oshikatsu_level_info_screen.dart'; // Import OshikatsuLevelInfoScreen
import '../../utils/custom_page_route.dart'; // Import CustomPageRoute

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
              final levelService = OshikatsuLevelService(
                  recordBox); // Instantiate levelService here
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
                        _buildOshikatsuLevelCard(
                            levelService), // Always display Oshikatsu Level Card
                        const SizedBox(height: 24),
                        if (records.isEmpty)
                          const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sentiment_neutral,
                                    size: 80, color: Color(0xFFBDBDBD)),
                                SizedBox(height: 16),
                                Text(
                                  '''まだ思い出がありません。
活動記録を追加して、思い出を振り返りましょう！''',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
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
      title: Text('思い出サマリー', style: Theme.of(context).textTheme.titleLarge),
      initiallyExpanded: true,
      children: [
        ListTile(
          leading: const Icon(Icons.format_list_numbered),
          title: const Text('合計記録数'),
          trailing:
              Text('$totalRecords 件', style: const TextStyle(fontSize: 16)),
        ),
        ListTile(
          leading: const Icon(Icons.category),
          title: const Text('一番多いカテゴリ'),
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
                      categoryDetails[mostFrequentCategory]!['name'] as String,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                )
              : const Text('なし', style: TextStyle(fontSize: 16)),
        ),
        ListTile(
          leading: const Icon(Icons.star_half),
          title: const Text('平均評価'),
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
        Text('推しごとタイムライン', style: Theme.of(context).textTheme.titleLarge),
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
            title: Text(oshi?.name ?? '推し未分類'),
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
