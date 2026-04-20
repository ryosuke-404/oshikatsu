import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';
// fl_chartをインポート
import 'package:provider/provider.dart'; // Providerをインポート
import 'package:intl/intl.dart'; // DateFormatのために追加
import '../../models/record_model.dart';
import '../../models/oshi_model.dart'; // Oshiモデルをインポート
import '../../services/theme_provider.dart'; // ThemeProviderをインポート
import '../../utils/custom_page_route.dart'; // CustomPageRouteをインポート
import '../view_record_screen.dart'; // ViewRecordScreenをインポート

class ActivitiesView extends StatefulWidget {
  const ActivitiesView({super.key});

  @override
  State<ActivitiesView> createState() => _ActivitiesViewState();
}

class _ActivitiesViewState extends State<ActivitiesView> {
  String? _selectedOshiId; // 選択された推しのID

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Record>>(
      valueListenable: Hive.box<Record>('records').listenable(),
      builder: (context, recordBox, _) {
        final allRecords = recordBox.values.toList();

        return ValueListenableBuilder<Box<Oshi>>(
          valueListenable: Hive.box<Oshi>('oshis').listenable(),
          builder: (context, oshiBox, _) {
            final oshis = oshiBox.values.toList();
            final filteredRecords = _selectedOshiId == null
                ? allRecords
                : allRecords.where((r) => r.oshiId == _selectedOshiId).toList();

            return Column(
              mainAxisSize: MainAxisSize.min, // 追加: Columnのサイズを内容に合わせる
              children: [
                _buildOshiSelector(oshis), // 推し選択セレクター
                const Divider(height: 1, thickness: 1),
                _buildRecordGrid(filteredRecords, oshis),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildOshiSelector(List<Oshi> oshis) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('すべて'),
            selected: _selectedOshiId == null,
            onSelected: (selected) => setState(() => _selectedOshiId = null),
          ),
          ...oshis.map((oshi) {
            final isSelected = _selectedOshiId == oshi.id;
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ChoiceChip(
                // label: Text(oshi.name), // 変更前
                label: Row(
                  // 変更
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12, // アイコンのサイズに合わせて調整
                      backgroundImage:
                          (oshi.imagePath != null && oshi.imagePath!.isNotEmpty)
                              ? FileImage(File(oshi.imagePath!))
                              : null,
                      child: (oshi.imagePath == null || oshi.imagePath!.isEmpty)
                          ? const Icon(Icons.person, size: 16) // デフォルトアイコン
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(oshi.name),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedOshiId = selected ? oshi.id : null;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecordGrid(List<Record> records, List<Oshi> oshis) {
    if (records.isEmpty) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sentiment_dissatisfied,
                  size: 80, color: Color(0xFFBDBDBD)),
              SizedBox(height: 16),
              Text(
                '''まだ活動記録がありません。
新しい記録を追加してみましょう！''',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
              ),
            ],
          ),
        ),
      );
    }
    final themeProvider =
        Provider.of<ThemeProvider>(context); // ThemeProviderを取得
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.75),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          final oshi = oshis.firstWhere((o) => o.id == record.oshiId,
              orElse: () => Oshi(
                  id: 'unknown',
                  name: '不明な推し',
                  level: OshiLevel.dd,
                  startDate: DateTime.now()));

          return InkWell(
            onTap: () => Navigator.of(context)
                .push(CustomPageRoute(child: ViewRecordScreen(record: record))),
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 4.0, // 影を強調
              shadowColor: themeProvider.themeData.primaryColor
                  .withOpacity(0.5), // テーマカラーを影に適用
              color: themeProvider.isNeonMode ? Colors.grey[900] : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image/Category Display
                  Expanded(
                    child: Container(
                      color: themeProvider.isNeonMode
                          ? Colors.black
                          : Colors.grey[200],
                      child: record.imagePath != null &&
                              record.imagePath!.isNotEmpty
                          ? Image.file(File(record.imagePath!),
                              fit: BoxFit.cover)
                          : Center(
                              child: Text(
                                  categoryDetails[record.category]!['name']
                                      as String,
                                  style: TextStyle(color: Colors.grey[600]))),
                    ),
                  ),
                  // Details Section (simplified for grid view)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(DateFormat('yyyy/MM/dd').format(record.date),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                        const SizedBox(height: 4),
                        RatingBarIndicator(
                          rating: record.rating,
                          itemBuilder: (context, index) =>
                              const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 14.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // _buildRatingTrendChart メソッドを削除
}
