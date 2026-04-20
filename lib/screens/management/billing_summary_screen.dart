import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/billing_model.dart';
import '../../models/oshi_model.dart';

class BillingSummaryScreen extends StatefulWidget {
  const BillingSummaryScreen({super.key});

  @override
  State<BillingSummaryScreen> createState() => _BillingSummaryScreenState();
}

class _BillingSummaryScreenState extends State<BillingSummaryScreen> {
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    // Determine the foreground color based on theme brightness
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final appBarForegroundColor = isLightMode ? Colors.black87 : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('yearly_summary_title'.tr(args: [_selectedYear.toString()])),
        // Add foregroundColor for better visibility in light/dark modes
        foregroundColor: appBarForegroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(_selectedYear),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (picked != null) {
                setState(() {
                  _selectedYear = picked.year;
                });
              }
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<BillingRecord>>(
        valueListenable:
            Hive.box<BillingRecord>('billing_records').listenable(),
        builder: (context, box, _) {
          final records =
              box.values.where((r) => r.date.year == _selectedYear).toList();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('monthly_spending_title'.tr()),
                SizedBox(height: 200, child: _buildMonthlyBarChart(records)),
                const SizedBox(height: 24),
                _buildSectionTitle('category_spending_title'.tr()),
                SizedBox(height: 200, child: _buildCategoryPieChart(records)),
                const SizedBox(height: 24),
                _buildSectionTitle('oshi_spending_title'.tr()),
                _buildOshiSpendingList(records),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthlyBarChart(List<BillingRecord> records) {
    final monthlySpending = List.generate(12, (index) => 0.0);
    for (var record in records) {
      monthlySpending[record.date.month - 1] += record.amount;
    }

    return BarChart(
      BarChartData(
        barGroups: List.generate(12, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: monthlySpending[index],
                color: Theme.of(context).colorScheme.primary, // Use theme color
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4.0,
                  child: Text(
                      'month_label'.tr(args: [(value.toInt() + 1).toString()]),
                      style: const TextStyle(fontSize: 10)),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('');
                return Text(NumberFormat.compact(locale: 'ja').format(value),
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
      ),
    );
  }

  Widget _buildCategoryPieChart(List<BillingRecord> records) {
    Map<BillingCategory, double> categorySpending = {};
    for (var record in records) {
      categorySpending.update(record.category, (value) => value + record.amount,
          ifAbsent: () => record.amount.toDouble());
    }

    if (categorySpending.isEmpty) {
      return Center(child: Text('no_data'.tr()));
    }

    return PieChart(
      PieChartData(
        sections: categorySpending.entries.map((entry) {
          final details = billingCategoryDetails[entry.key];
          return PieChartSectionData(
              value: entry.value,
              title:
                  '${tr('billing_category_${entry.key.name}')}\n${NumberFormat.compact(locale: 'ja').format(entry.value)}',
              color: Color(details?['color'] as int? ?? Colors.grey.value),
              radius: 80,
              titlePositionPercentageOffset: 0.6,
              titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 2)]));
        }).toList(),
        centerSpaceRadius: 0,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildOshiSpendingList(List<BillingRecord> records) {
    final oshiBox = Hive.box<Oshi>('oshis');
    final oshiMap = {for (var oshi in oshiBox.values) oshi.id: oshi.name};

    Map<String, double> oshiSpending = {};
    for (var record in records) {
      if (record.oshiId != null && record.oshiId!.isNotEmpty) {
        oshiSpending.update(record.oshiId!, (value) => value + record.amount,
            ifAbsent: () => record.amount.toDouble());
      }
    }

    if (oshiSpending.isEmpty) {
      return Card(
        child: ListTile(
          title: Center(child: Text('no_data'.tr())),
        ),
      );
    }

    final currencyFormatter = NumberFormat.currency(locale: 'ja', symbol: '¥');

    List<Widget> oshiTiles = [];
    oshiSpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..forEach((entry) {
        final oshiName = oshiMap[entry.key] ?? 'unknown_oshi'.tr();
        oshiTiles.add(ListTile(
          title: Text(oshiName),
          trailing: Text(
            currencyFormatter.format(entry.value),
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold),
          ),
        ));
      });

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: oshiTiles,
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      );
}
