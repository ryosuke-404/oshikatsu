import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:collection/collection.dart';
// Import Provider
import '../../models/billing_model.dart';
import '../../models/oshi_model.dart'; // Import Oshi model
// Import ThemeProvider
import 'add_billing_screen.dart';
import '../../utils/custom_page_route.dart';
import 'billing_analysis_screen.dart'; // Import new analysis screen
import 'budget_setting_screen.dart'; // Import the new budget setting screen

class BillingManagementScreen extends StatefulWidget {
  const BillingManagementScreen({super.key});

  @override
  State<BillingManagementScreen> createState() =>
      _BillingManagementScreenState();
}

class _BillingManagementScreenState extends State<BillingManagementScreen> {
  final _formatter = NumberFormat.currency(locale: 'ja', symbol: '¥');

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, settingsBox, _) {
        final monthlyBudget = settingsBox.get('monthly_budget') as double?;
        final isLightMode = Theme.of(context).brightness == Brightness.light;

        return Scaffold(
          appBar: AppBar(
            title: Text('billing_management'.tr()),
            foregroundColor: isLightMode ? Colors.black87 : Colors.white,
            actions: [
              Tooltip(
                message: 'analysis_tooltip'.tr(),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor:
                        isLightMode ? Colors.black87 : Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                        CustomPageRoute(child: const BillingAnalysisScreen()));
                  },
                  icon: const Icon(Icons.analytics),
                  label: Text('analysis_button_label'.tr()),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ValueListenableBuilder(
            valueListenable:
                Hive.box<BillingRecord>('billing_records').listenable(),
            builder: (context, box, _) {
              final records = box.values.toList()
                ..sort((a, b) => b.date.compareTo(a.date));
              final groupedRecords = groupBy(
                  records,
                  (record) =>
                      DateFormat('month_format'.tr()).format(record.date));

              // 当月の支出を計算
              final now = DateTime.now();
              final currentMonthRecords = records.where(
                  (r) => r.date.year == now.year && r.date.month == now.month);
              final currentMonthTotal = currentMonthRecords.fold<double>(
                  0, (sum, item) => sum + item.amount);

              return Column(
                children: [
                  _buildBudgetSummaryCard(monthlyBudget, currentMonthTotal),
                  Expanded(
                    child: records.isEmpty
                        ? Center(child: Text('no_billing_records'.tr()))
                        : ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: groupedRecords.length,
                            itemBuilder: (context, index) {
                              final month =
                                  groupedRecords.keys.elementAt(index);
                              final monthRecords = groupedRecords[month];
                              final monthTotal = monthRecords?.fold<double>(
                                      0, (sum, item) => sum + item.amount) ??
                                  0.0;

                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: ExpansionTile(
                                  initiallyExpanded: true,
                                  title: Text(month,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  trailing: Text(_formatter.format(monthTotal),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  children: monthRecords
                                          ?.map((record) =>
                                              _buildBillingRecordTile(record))
                                          .toList() ??
                                      [],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // 予算サマリーカード
  Widget _buildBudgetSummaryCard(double? budget, double currentMonthTotal) {
    final remaining = budget != null ? budget - currentMonthTotal : null;
    final progress = (budget != null && budget > 0)
        ? (currentMonthTotal / budget).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Corrected position
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('current_month_usage_title'.tr(),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Flexible(
                  child: TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.of(context).push<bool>(
                        CustomPageRoute<bool>(
                            child: const BudgetSettingScreen()),
                      );
                      if (result == true && mounted) {
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(
                      budget == null
                          ? 'set_budget_button'.tr()
                          : 'change_budget_button'.tr(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (budget != null) ...[
              Text('budget_label'
                  .tr(namedArgs: {'budget': _formatter.format(budget)})),
              const SizedBox(height: 4),
              Text(
                'remaining_label'.tr(namedArgs: {
                  'remaining': _formatter.format(remaining ?? 0.0)
                }),
                style: TextStyle(
                  color: (remaining ?? 0.0) < 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.8
                      ? Colors.red
                      : (progress > 0.5 ? Colors.orange : Colors.green),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('amount_used_label'.tr(namedArgs: {
                    'amount': _formatter.format(currentMonthTotal)
                  })),
                  Text('${(progress * 100).toStringAsFixed(1)}%'),
                ],
              ),
            ] else ...[
              Center(
                child: Text('no_monthly_budget_set'.tr()),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 課金履歴のタイル
  Widget _buildBillingRecordTile(BillingRecord record) {
    final categoryDetailsMap = billingCategoryDetails[record.category];
    final categoryName = 'billing_category_${record.category.name}'.tr();
    final categoryIcon = categoryDetailsMap?['icon'] as IconData? ?? Icons.help;
    final categoryColor =
        categoryDetailsMap?['color'] as int? ?? Colors.grey.value;

    return ListTile(
      leading: Icon(
        categoryIcon,
        color: Color(categoryColor),
      ),
      title: Text(record.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('date_format_short'.tr()).format(record.date)),
          if (record.oshiId != null)
            ValueListenableBuilder<Box<Oshi>>(
              valueListenable: Hive.box<Oshi>('oshis').listenable(),
              builder: (context, oshiBox, _) {
                final oshi = oshiBox.values.firstWhere(
                  (o) => o.id == record.oshiId,
                  orElse: () => Oshi(
                      id: 'unknown',
                      name: 'unknown_oshi'.tr(),
                      level: OshiLevel.dd,
                      startDate: DateTime.now()),
                );
                return Text('oshi_label'.tr(namedArgs: {'name': oshi.name}));
              },
            ),
        ],
      ),
      trailing: Text(_formatter.format(record.amount)),
      onTap: () async {
        final result = await Navigator.of(context).push(
          CustomPageRoute<bool>(child: AddBillingScreen(record: record)),
        );
        if (result == true && mounted) {
          setState(() {});
        }
      },
    );
  }
}
