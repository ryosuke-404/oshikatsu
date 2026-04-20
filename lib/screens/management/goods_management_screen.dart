import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:collection/collection.dart'; // For firstWhereOrNull
import '../../models/goods_model.dart';
import '../../models/oshi_model.dart';
import 'view_goods_screen.dart';
import '../../utils/custom_page_route.dart';
import 'series_management_screen.dart';
import '../../models/series_model.dart';

class GoodsManagementScreen extends StatefulWidget {
  const GoodsManagementScreen({super.key});
  @override
  State<GoodsManagementScreen> createState() => _GoodsManagementScreenState();
}

class _GoodsManagementScreenState extends State<GoodsManagementScreen> {
  String? _selectedCategory;
  final Map<String, bool> _reorderMode = {};

  @override
  Widget build(BuildContext context) {
    final goodsBox = Hive.box<Goods>('goods');
    final oshiBox = Hive.box<Oshi>('oshis');
    final appBarForegroundColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.black87
            : Colors.white;

    return ValueListenableBuilder(
      valueListenable: Hive.box<Series>('series').listenable(),
      builder: (context, Box<Series> seriesBox, _) {
        return ValueListenableBuilder(
          valueListenable: Hive.box<Goods>('goods').listenable(),
          builder: (context, Box<Goods> box, _) {
            final allGoods = box.values.where((g) => g.isOwned).toList();

            final filteredGoods = allGoods.where((goods) {
              final categoryMatch = _selectedCategory == null ||
                  goods.category == _selectedCategory;
              return categoryMatch;
            }).toList();

            final groupedGoods = groupBy(filteredGoods,
                (goods) => goods.series ?? 'no_series_label'.tr());

            return Scaffold(
              appBar: AppBar(
                title: Text('goods_management'.tr()),
                foregroundColor: appBarForegroundColor,
                actions: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(CustomPageRoute(
                          child: const SeriesManagementScreen()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'edit_series_button'.tr(),
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(width: 4.0),
                          const Icon(Icons.category_outlined),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              body: Column(
                children: [
                  _buildCategorySelector(),
                  const Divider(height: 1),
                  Expanded(
                      child: _buildGoodsGrid(groupedGoods, oshiBox, seriesBox)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategorySelector() {
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
          ...goodsCategoryKeys.map((categoryKey) {
            final details = goodsCategoryDetails[categoryKey]!;
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ChoiceChip(
                avatar: Icon(
                  details['icon'],
                  color: _selectedCategory == categoryKey
                      ? Colors.white
                      : Colors.black87,
                ),
                label: Text('goods_category_$categoryKey'.tr()),
                selected: _selectedCategory == categoryKey,
                onSelected: (selected) => setState(
                    () => _selectedCategory = selected ? categoryKey : null),
                selectedColor: details['accentColor'],
                backgroundColor: details['mainColor'].withOpacity(0.4),
                labelStyle: TextStyle(
                  color: _selectedCategory == categoryKey
                      ? Colors.white
                      : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: _selectedCategory == categoryKey
                        ? details['accentColor']
                        : Colors.grey.shade300,
                    width: _selectedCategory == categoryKey ? 2 : 1,
                  ),
                ),
                elevation: _selectedCategory == categoryKey ? 4 : 0,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGoodsGrid(Map<String, List<Goods>> groupedGoods,
      Box<Oshi> oshiBox, Box<Series> seriesBox) {
    if (groupedGoods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.widgets_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'no_collection_message'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final noSeriesLabel = 'no_series_label'.tr();
    final seriesInGoods = groupedGoods.keys.toList();

    // "シリーズなし" をリストから一旦削除
    final hasNoSeries = seriesInGoods.remove(noSeriesLabel);

    // seriesBoxの順序に基づいてソート
    seriesInGoods.sort((a, b) {
      final seriesA = seriesBox.values.firstWhereOrNull((s) => s.name == a);
      final seriesB = seriesBox.values.firstWhereOrNull((s) => s.name == b);
      final orderA = seriesA?.order ?? 9999;
      final orderB = seriesB?.order ?? 9999;
      if (orderA != orderB) {
        return orderA.compareTo(orderB);
      }
      return a.compareTo(b); // orderが同じ場合は名前でソート
    });

    // 最終的なリストを作成
    final sortedSeriesNames = seriesInGoods;
    if (hasNoSeries) {
      sortedSeriesNames.add(noSeriesLabel); // "シリーズなし" を末尾に追加
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: sortedSeriesNames.length,
      itemBuilder: (context, index) {
        final seriesName = sortedSeriesNames[index];
        final goodsInSeries = groupedGoods[seriesName]!;
        goodsInSeries.sort((a, b) => a.order.compareTo(b.order));

        final isReorderMode = _reorderMode[seriesName] ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ExpansionTile(
            title: Text(
              seriesName == 'no_series_label'.tr()
                  ? 'no_series_label'.tr()
                  : seriesName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: Icon(isReorderMode ? Icons.grid_view : Icons.reorder),
              onPressed: () {
                setState(() {
                  _reorderMode[seriesName] = !isReorderMode;
                });
              },
            ),
            initiallyExpanded:
                true, // You can change this to false if you want them collapsed by default
            children: [
              if (isReorderMode)
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: goodsInSeries.length,
                  itemBuilder: (context, idx) {
                    final item = goodsInSeries[idx];
                    return ListTile(
                      key: ValueKey(item.id),
                      leading: SizedBox(
                        width: 50,
                        height: 50,
                        child: Hero(
                          tag: 'goods_image_${item.id}',
                          child:
                              item.imagePath == null || item.imagePath!.isEmpty
                                  ? const Icon(Icons.image_not_supported,
                                      size: 50, color: Colors.grey)
                                  : Image.file(File(item.imagePath!),
                                      fit: BoxFit.cover),
                        ),
                      ),
                      title: Text(item.name),
                      subtitle: Text('goods_category_${item.category}'.tr()),
                      trailing: ReorderableDragStartListener(
                        index: idx,
                        child: const Icon(Icons.drag_handle),
                      ),
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = goodsInSeries.removeAt(oldIndex);
                      goodsInSeries.insert(newIndex, item);

                      for (int i = 0; i < goodsInSeries.length; i++) {
                        final good = goodsInSeries[i];
                        good.order = i;
                        good.save();
                      }
                    });
                  },
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio:
                        0.7, // Adjust aspect ratio for better layout
                  ),
                  itemCount: goodsInSeries.length,
                  itemBuilder: (context, idx) {
                    final item = goodsInSeries[idx];
                    return InkWell(
                      onTap: () async {
                        await Navigator.of(context).push(
                          CustomPageRoute(child: ViewGoodsScreen(goods: item)),
                        );
                        // No result check needed as ValueListenableBuilder handles refresh
                      },
                      onLongPress: () => _showDeleteConfirmDialog(item),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Hero(
                                tag: 'goods_image_${item.id}',
                                child: Container(
                                  color: Colors.grey[200],
                                  child: item.imagePath != null &&
                                          item.imagePath!.isNotEmpty
                                      ? Image.file(File(item.imagePath!),
                                          fit: BoxFit.cover)
                                      : const Icon(Icons.image_not_supported,
                                          size: 40, color: Colors.grey),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(Goods goods) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('confirm'.tr()),
        content: Text(
            'delete_goods_confirm_message'.tr(namedArgs: {'name': goods.name})),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('cancel'.tr())),
          TextButton(
            onPressed: () {
              try {
                goods.delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('goods_deleted_message'.tr()),
                      backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('goods_delete_failed_message'
                          .tr(args: [e.toString()])),
                      backgroundColor: Colors.redAccent),
                );
              }
              Navigator.of(ctx).pop();
            },
            child:
                Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
