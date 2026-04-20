import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oshikatu/providers/ad_provider.dart';
import 'package:oshikatu/widgets/ad_banner.dart';
import 'package:provider/provider.dart';
import '../../models/goods_model.dart';
import '../../models/series_model.dart';

class SeriesManagementScreen extends StatefulWidget {
  const SeriesManagementScreen({super.key});

  @override
  State<SeriesManagementScreen> createState() => _SeriesManagementScreenState();
}

class _SeriesManagementScreenState extends State<SeriesManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final appBarForegroundColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.black87 // ライトモードでは黒系の色
            : Colors.white; // ダークモードでは白
    final adProvider = Provider.of<AdProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('series_management_title'.tr()),
        foregroundColor: appBarForegroundColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Series>('series').listenable(),
              builder: (context, Box<Series> seriesBox, _) {
                final seriesList = seriesBox.values.toList()
                  ..sort((a, b) => a.order.compareTo(b.order));

                if (seriesList.isEmpty) {
                  return Center(
                    child: Text('no_series_registered'.tr()),
                  );
                }

                return ReorderableListView.builder(
                  itemCount: seriesList.length,
                  itemBuilder: (context, index) {
                    final series = seriesList[index];
                    final goodsInSeriesCount = Hive.box<Goods>('goods')
                        .values
                        .where((g) => g.series == series.name)
                        .length;

                    return Card(
                      key: ValueKey(series.key),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(series.name),
                        subtitle: Text('goods_count_subtitle'.tr(namedArgs: {
                          'count': goodsInSeriesCount.toString()
                        })),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _showEditSeriesDialog(context, series),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteSeriesDialog(
                                  context, series, goodsInSeriesCount),
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final series = seriesList.removeAt(oldIndex);
                      seriesList.insert(newIndex, series);

                      for (int i = 0; i < seriesList.length; i++) {
                        seriesList[i].order = i;
                        seriesList[i].save();
                      }
                    });
                  },
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

  void _showEditSeriesDialog(BuildContext context, Series series) {
    final TextEditingController controller =
        TextEditingController(text: series.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('edit_series_dialog_title'.tr()),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'new_series_name_hint'.tr()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                final newSeriesName = controller.text.trim();
                if (newSeriesName.isNotEmpty && newSeriesName != series.name) {
                  _renameSeries(series, newSeriesName);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('invalid_new_series_name_message'.tr())),
                  );
                }
              },
              child: Text('save_button'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _renameSeries(Series series, String newSeriesName) {
    final goodsBox = Hive.box<Goods>('goods');
    final goodsToUpdate =
        goodsBox.values.where((g) => g.series == series.name).toList();
    for (var goods in goodsToUpdate) {
      goods.series = newSeriesName;
      goods.save();
    }
    series.name = newSeriesName;
    series.save();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('series_name_changed_message'.tr())),
    );
  }

  void _showDeleteSeriesDialog(
      BuildContext context, Series series, int goodsCount) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('delete_series_dialog_title'.tr()),
          content: Text('delete_series_dialog_content'.tr(namedArgs: {
            'seriesName': series.name,
            'goodsCount': goodsCount.toString(),
          })),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                _deleteSeries(series);
                Navigator.pop(context);
              },
              child: Text('delete'.tr(),
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteSeries(Series series) {
    final goodsBox = Hive.box<Goods>('goods');
    final goodsToUpdate =
        goodsBox.values.where((g) => g.series == series.name).toList();
    for (var goods in goodsToUpdate) {
      goods.series = null; // Set series to null
      goods.save();
    }
    final seriesName = series.name;
    series.delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('series_deleted_message'
              .tr(namedArgs: {'seriesName': seriesName}))),
    );
  }
}
