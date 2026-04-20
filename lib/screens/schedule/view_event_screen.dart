import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/schedule_models.dart';
import '../../models/oshi_model.dart';
import 'edit_event_screen.dart'; // EditEventScreenをインポート

class ViewEventScreen extends StatefulWidget {
  final Event event;
  const ViewEventScreen({super.key, required this.event});

  @override
  State<ViewEventScreen> createState() => _ViewEventScreenState();
}

class _ViewEventScreenState extends State<ViewEventScreen> {
  // イベントが更新された際に画面を再描画するためのメソッド
  void _refreshEvent() {
    setState(() {
      // setStateを呼ぶことで、Hiveの更新をリッスンしているValueListenableBuilderなどが再評価され、
      // 画面が最新の状態に更新されます。
    });
  }

  @override
  Widget build(BuildContext context) {
    final oshiBox = Hive.box<Oshi>('oshis');
    final oshi =
        widget.event.oshiId != null && oshiBox.containsKey(widget.event.oshiId)
            ? oshiBox.get(widget.event.oshiId)
            : null;
    final categoryDetails = eventCategoryDetails[widget.event.category];
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: Text('view_event_title'.tr()),
        foregroundColor: isLightMode ? Colors.black87 : Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditEventScreen(event: widget.event),
                ),
              );
              _refreshEvent(); // 編集画面から戻ってきたら画面を更新
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'date_label'.tr().split(':').first,
              value: DateFormat('y年M月d日').format(widget.event.date),
            ),
            if (oshi != null)
              _buildDetailRow(
                icon: Icons.person,
                label: 'oshi_label'.tr().split(':').first,
                value: oshi.name,
              ),
            _buildDetailRow(
              icon: categoryDetails?['icon'] as IconData? ?? Icons.category,
              label: 'category_label'.tr(),
              value: 'event_category_${widget.event.category.name}'.tr(),
              color: categoryDetails?['color'] as Color?,
            ),
            _buildDetailRow(
              icon: Icons.star,
              label: 'priority_label'.tr(),
              value: '★' * widget.event.priority,
              color: Colors.amber,
            ),
            // isYearlyRecurring の表示を追加
            if (widget.event.isYearlyRecurring)
              _buildDetailRow(
                icon: Icons.repeat,
                label: 'repeat_label'.tr(),
                value: 'repeat_yearly_value'.tr(),
              ),
            // メモの表示を追加
            if (widget.event.memo != null && widget.event.memo!.isNotEmpty)
              _buildDetailRow(
                icon: Icons.notes,
                label: 'memo_label'.tr(),
                value: widget.event.memo!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              color: color ??
                  Theme.of(context).colorScheme.primary.withOpacity(0.7)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
