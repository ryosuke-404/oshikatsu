import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/schedule_models.dart';
import '../../utils/custom_page_route.dart'; // CustomPageRouteをインポート
import 'view_itinerary_screen.dart';

class ItineraryView extends StatelessWidget {
  const ItineraryView({super.key});

  // Define colors for each month (border colors)
  static const Map<int, Color> monthBorderColors = {
    1: Color(0xFFD4AF37), // January - ゴールド（お正月）
    2: Color(0xFFFFB6C1), // February - ライトピンク（梅・バレンタイン）
    3: Color(0xFFFFE4E1), // March - 桜ピンク（桜・春の始まり）
    4: Color(0xFF90EE90), // April - ライトグリーン（新緑・新生活）
    5: Color(0xFF98FB98), // May - ペールグリーン（花畑・こどもの日）
    6: Color(0xFF9370DB), // June - ミディアムパープル（紫陽花・梅雨）
    7: Color(0xFF00BFFF), // July - ディープスカイブルー（海・夏祭り）
    8: Color(0xFFFF4500), // August - オレンジレッド（夏の盛り・お盆）
    9: Color(0xFFDDA0DD), // September - プラム（コスモス・お月見）
    10: Color(0xFFFF8C00), // October - ダークオレンジ（紅葉・ハロウィン）
    11: Color(0xFFFFD700), // November - ゴールド（銀杏・晩秋）
    12: Color(0xFF4169E1), // December - ロイヤルブルー（冬の夜空・クリスマス）
  };

  // Define icons for each month
  static const Map<int, IconData> monthIcons = {
    1: Icons.temple_buddhist, // お正月・神社仏閣
    2: Icons.favorite, // バレンタイン・梅（ハート）
    3: Icons.local_florist, // 桜・春の花
    4: Icons.eco, // 新緑・新芽
    5: Icons.child_friendly, // こどもの日・花畑
    6: Icons.umbrella, // 梅雨・紫陽花
    7: Icons.waves, // 海・夏
    8: Icons.wb_sunny, // 夏の盛り・太陽
    9: Icons.nights_stay, // お月見・コスモス
    10: Icons.forest, // 紅葉・秋の森
    11: Icons.nature, // 銀杏・晩秋の自然
    12: Icons.celebration, // 雪・冬
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ValueListenableBuilder<Box<Itinerary>>(
            valueListenable: Hive.box<Itinerary>('itineraries').listenable(),
            builder: (context, box, _) {
              final itineraries = box.values.toList();
              if (itineraries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.book_outlined,
                          size: 80, color: Color(0xFFBDBDBD)),
                      const SizedBox(height: 16),
                      Text(
                        'no_itineraries_message'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, color: Color(0xFF757575)),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: itineraries.length,
                itemBuilder: (context, index) {
                  final itinerary = itineraries[index];
                  return _buildItineraryCard(context, itinerary);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItineraryCard(BuildContext context, Itinerary itinerary) {
    final formatter = DateFormat('date_format_long'.tr());
    final dateString =
        '${formatter.format(itinerary.startDate)} - ${formatter.format(itinerary.endDate)}';

    // Get month color and icon based on start date
    final int startMonth = itinerary.startDate.month;
    final Color borderColor =
        monthBorderColors[startMonth] ?? Colors.grey; // Default to grey
    final IconData monthIcon =
        monthIcons[startMonth] ?? Icons.event; // Default to generic event icon

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        // Define shape for border
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: borderColor, width: 2.0), // Apply border color
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
            CustomPageRoute(child: ViewItineraryScreen(itinerary: itinerary))),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(monthIcon,
                      size: 20, color: borderColor), // Display month icon
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(itinerary.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.date_range, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(dateString, style: const TextStyle(color: Colors.grey)),
              ]),
              const SizedBox(height: 8),
              Text(
                itinerary.memoContent,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
