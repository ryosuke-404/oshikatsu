import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
// For groupBy
import 'package:fl_chart/fl_chart.dart'; // For charts
import 'package:oshikatu/providers/ad_provider.dart';
import 'package:oshikatu/widgets/ad_banner.dart';
import 'package:provider/provider.dart'; // For ThemeProvider
import '../../models/billing_model.dart';
import '../../models/oshi_model.dart'; // For Oshi model
import '../../services/theme_provider.dart'; // For ThemeProvider

class BillingAnalysisScreen extends StatefulWidget {
  const BillingAnalysisScreen({super.key});

  @override
  State<BillingAnalysisScreen> createState() => _BillingAnalysisScreenState();
}

class _BillingAnalysisScreenState extends State<BillingAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formatter = NumberFormat.currency(locale: 'ja', symbol: '¥');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this); // 3 tabs: Oshi, Category, Overall
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final adProvider = Provider.of<AdProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('billing_analysis_title'.tr()),
        foregroundColor: isLightMode ? Colors.black87 : Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor:
              isLightMode ? Theme.of(context).primaryColor : Colors.white,
          unselectedLabelColor: isLightMode ? Colors.black54 : Colors.white70,
          indicatorColor:
              isLightMode ? Theme.of(context).primaryColor : Colors.white,
          tabs: [
            Tab(text: 'oshi_tab'.tr()),
            Tab(text: 'category_tab'.tr()),
            Tab(text: 'overall_tab'.tr()),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<Box<BillingRecord>>(
              valueListenable:
                  Hive.box<BillingRecord>('billing_records').listenable(),
              builder: (context, box, _) {
                final allRecords = box.values.toList();
                final now = DateTime.now();
                final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

                // Filter records for the last 12 months for monthly analysis
                final recentRecords = allRecords
                    .where((r) => r.date.isAfter(oneYearAgo))
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOshiAnalysis(recentRecords),
                    _buildCategoryBarChart(
                        recentRecords), // New bar chart for category
                    _buildOverallAnalysis(
                        allRecords), // Restore overall analysis
                  ],
                );
              },
            ),
          ),
          Visibility(
            visible: adProvider.shouldShowAds,
            child: const AdBanner(),
          ),
        ],
      ),
    );
  }

  Widget _buildOshiAnalysis(List<BillingRecord> records) {
    final monthlyOshiTotals =
        <String, Map<String, double>>{}; // Month -> OshiId -> Total
    final sortedMonths = <String>[];

    // Populate monthlyOshiTotals and sortedMonths
    for (var i = 0; i < 12; i++) {
      final month = DateTime(DateTime.now().year, DateTime.now().month - i, 1);
      final monthKey = DateFormat('month_format'.tr()).format(month);
      sortedMonths.insert(0, monthKey); // Add to front to sort ascending
      monthlyOshiTotals[monthKey] = {};
    }

    for (var record in records) {
      final monthKey = DateFormat('month_format'.tr()).format(record.date);
      final oshiId = record.oshiId ?? 'unknown';
      // Ensure the monthKey exists in the map before accessing it
      monthlyOshiTotals.putIfAbsent(monthKey, () => {});
      monthlyOshiTotals[monthKey]![oshiId] =
          (monthlyOshiTotals[monthKey]![oshiId] ?? 0.0) + record.amount;
    }

    return ValueListenableBuilder<Box<Oshi>>(
      valueListenable: Hive.box<Oshi>('oshis').listenable(),
      builder: (context, oshiBox, _) {
        final oshis = oshiBox.values.toList();
        final oshiMap = {for (var o in oshis) o.id: o.name};

        // Calculate overall Oshi totals for the pie chart
        final oshiOverallTotals = <String, double>{};
        for (var record in records) {
          // Use 'records' which are recentRecords
          final oshiId = record.oshiId ?? 'unknown';
          oshiOverallTotals[oshiId] =
              (oshiOverallTotals[oshiId] ?? 0.0) + record.amount;
        }

        final pieChartSections = oshiOverallTotals.entries.map((entry) {
          final oshiName = oshiMap[entry.key] ?? 'unknown_oshi'.tr();
          final value = entry.value;
          final totalAmount =
              oshiOverallTotals.values.fold(0.0, (sum, e) => sum + e);
          final percentage = totalAmount > 0 ? (value / totalAmount) * 100 : 0;

          // Assign a random color for now, or use a predefined palette
          final color =
              Colors.primaries[entry.key.hashCode % Colors.primaries.length];

          return PieChartSectionData(
            color: color,
            value: value,
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            badgeWidget: Builder(
              // Use Builder to access context for Provider
              builder: (context) {
                final themeProvider = Provider.of<ThemeProvider>(context);
                return Text(
                  oshiName,
                  style: TextStyle(
                    fontSize: 10,
                    color: themeProvider.isNeonMode
                        ? Colors.white
                        : Colors.black, // Dynamic color
                  ),
                );
              },
            ),
            badgePositionPercentageOffset: 1.4, // Adjust position
          );
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'oshi_spending_percentage_title'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200, // Height for the pie chart
              child: pieChartSections.isNotEmpty
                  ? PieChart(
                      PieChartData(
                        sections: pieChartSections,
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        pieTouchData: PieTouchData(touchCallback:
                            (FlTouchEvent event, pieTouchResponse) {
                          // Handle touch events if needed
                        }),
                      ),
                    )
                  : Center(child: Text('no_data'.tr())),
            ),
            const SizedBox(height: 24),
            Text(
              'monthly_oshi_spending_title'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true, // Important for nested ListView
              physics:
                  const NeverScrollableScrollPhysics(), // Important for nested ListView
              itemCount: sortedMonths.length,
              itemBuilder: (context, index) {
                final monthKey = sortedMonths[index];
                final oshiTotals = monthlyOshiTotals[monthKey] ?? {};
                final monthTotal =
                    oshiTotals.values.fold(0.0, (sum, amount) => sum + amount);

                if (oshiTotals.isEmpty) {
                  return const SizedBox
                      .shrink(); // Hide if no records for the month
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ExpansionTile(
                    title: Text('total_for_month'.tr(namedArgs: {
                      'month': monthKey,
                      'total': _formatter.format(monthTotal)
                    })),
                    children: oshiTotals.entries.map((entry) {
                      final oshiName =
                          oshiMap[entry.key] ?? 'unknown_oshi'.tr();
                      return ListTile(
                        title: Text(oshiName),
                        trailing: Text(_formatter.format(entry.value)),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryBarChart(List<BillingRecord> records) {
    final monthlyCategoryTotals =
        <String, Map<BillingCategory, double>>{}; // Month -> Category -> Total
    final sortedMonths = <String>[];

    // Populate monthlyCategoryTotals and sortedMonths
    for (var i = 0; i < 12; i++) {
      final month = DateTime(DateTime.now().year, DateTime.now().month - i, 1);
      final monthKey = DateFormat('month_format'.tr()).format(month);
      sortedMonths.insert(0, monthKey); // Add to front to sort ascending
      monthlyCategoryTotals[monthKey] = {};
    }

    for (var record in records) {
      final monthKey = DateFormat('month_format'.tr()).format(record.date);
      monthlyCategoryTotals.putIfAbsent(
          monthKey, () => {}); // Ensure monthKey exists
      monthlyCategoryTotals[monthKey]![record.category] =
          (monthlyCategoryTotals[monthKey]![record.category] ?? 0.0) +
              record.amount;
    }

    // Prepare BarChartGroupData
    final barGroups = <BarChartGroupData>[];
    for (var i = 0; i < sortedMonths.length; i++) {
      final monthKey = sortedMonths[i];
      final categoryTotals = monthlyCategoryTotals[monthKey] ?? {};

      double totalMonthAmount = 0;
      final rodStackItems = <BarChartRodStackItem>[];

      // Sort categories for consistent stacking order
      final sortedCategories = categoryTotals.keys.toList()
        ..sort((a, b) => 'billing_category_${a.name}'
            .tr()
            .compareTo('billing_category_${b.name}'.tr()));

      for (var category in sortedCategories) {
        final amount = categoryTotals[category] ?? 0.0;
        final categoryColor = Color(
            billingCategoryDetails[category]?['color'] as int? ??
                Colors.grey.value);

        rodStackItems.add(
          BarChartRodStackItem(
            totalMonthAmount,
            totalMonthAmount + amount,
            categoryColor,
          ),
        );
        totalMonthAmount += amount;
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: totalMonthAmount,
              color: Colors.transparent, // Transparent to show only stack items
              width: 16,
              borderRadius: BorderRadius.circular(4),
              rodStackItems: rodStackItems,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'monthly_category_spending_graph_title'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250, // Height for the bar chart
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(
                            DateFormat('month_format_short'.tr()).format(
                                DateFormat('month_format'.tr())
                                    .parse(sortedMonths[value.toInt()])),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.max) return Container();
                        return Text(
                          _formatter.format(value).replaceAll('¥', ''),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Colors.grey,
                    strokeWidth: 0.5,
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final monthKey = sortedMonths[group.x.toInt()];
                      final categoryTotals =
                          monthlyCategoryTotals[monthKey] ?? {};
                      final sortedCategories = categoryTotals.keys.toList()
                        ..sort((a, b) => 'billing_category_${a.name}'
                            .tr()
                            .compareTo('billing_category_${b.name}'.tr()));

                      if (rodIndex >= sortedCategories.length) {
                        return null; // Avoid index out of bounds
                      }

                      final category = sortedCategories[rodIndex];
                      final categoryName =
                          'billing_category_${category.name}'.tr();
                      final amount = categoryTotals[category] ?? 0.0;

                      return BarTooltipItem(
                        '$categoryName\n',
                        const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        children: <TextSpan>[
                          TextSpan(
                            text: _formatter.format(amount),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Legend for categories
          Text(
            'category_legend_title'.tr(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: BillingCategory.values.map((category) {
              final details = billingCategoryDetails[category];
              final categoryName = 'billing_category_${category.name}'.tr();
              final categoryColor =
                  Color(details?['color'] as int? ?? Colors.grey.value);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: categoryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(categoryName, style: const TextStyle(fontSize: 12)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallAnalysis(List<BillingRecord> records) {
    final overallTotal =
        records.fold(0.0, (sum, record) => sum + record.amount);

    final oshiOverallTotals = <String, double>{};
    for (var record in records) {
      final oshiId = record.oshiId ?? 'unknown';
      oshiOverallTotals[oshiId] =
          (oshiOverallTotals[oshiId] ?? 0.0) + record.amount;
    }

    final categoryOverallTotals = <BillingCategory, double>{};
    for (var record in records) {
      categoryOverallTotals[record.category] =
          (categoryOverallTotals[record.category] ?? 0.0) + record.amount;
    }

    return ValueListenableBuilder<Box<Oshi>>(
      valueListenable: Hive.box<Oshi>('oshis').listenable(),
      builder: (context, oshiBox, _) {
        final oshis = oshiBox.values.toList();
        final oshiMap = {for (var o in oshis) o.id: o.name};

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('overall_total_title'.tr(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_formatter.format(overallTotal),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: Text('overall_total_by_oshi_title'.tr()),
              children: oshiOverallTotals.entries.map((entry) {
                final oshiName = oshiMap[entry.key] ?? 'unknown_oshi'.tr();
                return ListTile(
                  title: Text(oshiName),
                  trailing: Text(_formatter.format(entry.value)),
                );
              }).toList(),
            ),
            ExpansionTile(
              title: Text('overall_total_by_category_title'.tr()),
              children: categoryOverallTotals.entries.map((entry) {
                final categoryDetail = billingCategoryDetails[entry.key];
                final categoryName = 'billing_category_${entry.key.name}'.tr();
                final categoryIcon =
                    categoryDetail?['icon'] as IconData? ?? Icons.help;
                final categoryColor =
                    categoryDetail?['color'] as int? ?? Colors.grey.value;

                return ListTile(
                  leading: Icon(
                    categoryIcon,
                    color: Color(categoryColor),
                  ),
                  title: Text(categoryName),
                  trailing: Text(_formatter.format(entry.value)),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
