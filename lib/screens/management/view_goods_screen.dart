import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/goods_model.dart';
import '../../models/oshi_model.dart';
import '../../utils/custom_page_route.dart';
import 'edit_goods_screen.dart'; // Import for navigation to edit screen

class ViewGoodsScreen extends StatefulWidget {
  final Goods goods;
  const ViewGoodsScreen({super.key, required this.goods});

  @override
  State<ViewGoodsScreen> createState() => _ViewGoodsScreenState();
}

class _ViewGoodsScreenState extends State<ViewGoodsScreen> {
  late Goods _goods;

  @override
  void initState() {
    super.initState();
    _goods = widget.goods;
  }

  @override
  Widget build(BuildContext context) {
    final oshiBox = Hive.box<Oshi>('oshis');
    final oshi = oshiBox.get(_goods.oshiId);
    final appBarForegroundColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.black87
            : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(_goods.name),
        foregroundColor: appBarForegroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Navigate to EditGoodsScreen and await result
              await Navigator.of(context).push(
                CustomPageRoute(child: EditGoodsScreen(goods: _goods)),
              );
              // After returning from edit, refresh the goods object from the box
              if (mounted) {
                setState(() {
                  _goods = Hive.box<Goods>('goods').get(widget.goods.key)!;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'goods_image_${_goods.id}',
                child: _goods.imagePath != null && _goods.imagePath!.isNotEmpty
                    ? Image.file(File(_goods.imagePath!),
                        height: 200, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported,
                        size: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('goods_name_label'.tr(), _goods.name),
            _buildInfoRow('category_label'.tr(),
                'goods_category_${_goods.category}'.tr()),
            _buildInfoRow(
                'oshi_member_label'.tr(), oshi?.name ?? 'unknown_oshi'.tr()),
            if (_goods.series != null && _goods.series!.isNotEmpty)
              _buildInfoRow('series_label'.tr(), _goods.series!),
            if (_goods.memo != null && _goods.memo!.isNotEmpty)
              _buildInfoRow('memo_label'.tr(), _goods.memo!),
            // Add more details as needed
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
