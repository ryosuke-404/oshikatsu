import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../models/goods_model.dart';
import '../../models/oshi_model.dart';
import '../../models/series_model.dart';
import '../../services/theme_provider.dart';

class AddGoodsScreen extends StatefulWidget {
  const AddGoodsScreen({super.key});

  @override
  State<AddGoodsScreen> createState() => _AddGoodsScreenState();
}

class _AddGoodsScreenState extends State<AddGoodsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _memoController = TextEditingController(); // New: Controller for memo
  final _seriesController =
      TextEditingController(); // New: Controller for series
  final FocusNode _seriesFocusNode =
      FocusNode(); // New: FocusNode for series input
  String? _selectedCategory;
  String? _selectedOshiId;
  String? _savedImagePath;

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(image.path);
      final savedImage =
          await File(image.path).copy('${appDir.path}/$fileName');
      setState(() {
        _savedImagePath = savedImage.path;
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('gallery_option'.tr()),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text('camera_option'.tr()),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('select_category_prompt'.tr()),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (_selectedOshiId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('select_oshi_prompt'.tr()),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      try {
        final goodsBox = Hive.box<Goods>('goods');
        final seriesBox = Hive.box<Series>('series');
        final newId = const Uuid().v4();
        // Get the number of goods in the same series to set the order
        final seriesName =
            _seriesController.text.isEmpty ? null : _seriesController.text;

        // Create a new series if it doesn't exist
        if (seriesName != null &&
            seriesBox.values.where((s) => s.name == seriesName).isEmpty) {
          final newSeries = Series(name: seriesName, order: seriesBox.length);
          seriesBox.add(newSeries);
        }

        final goodsInSeries =
            goodsBox.values.where((g) => g.series == seriesName).length;

        final newGoods = Goods(
          id: newId,
          name: _nameController.text,
          category: _selectedCategory!,
          oshiId: _selectedOshiId!,
          imagePath: _savedImagePath,
          isOwned: true, // Always owned when adding to collection
          series: seriesName,
          order: goodsInSeries, // Set the order
          memo: _memoController.text, // Add this line
        );
        goodsBox.put(newId, newGoods);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('collection_added_message'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Pop with result to refresh list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('save_failed_message'.tr(args: [e.toString()])),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildCategorySelector(bool isNeonMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('category_label'.tr(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0, // Horizontal space between chips
          runSpacing: 8.0, // Vertical space between rows
          children: goodsCategoryKeys.map((categoryKey) {
            final details = goodsCategoryDetails[categoryKey]!;
            final isSelected = _selectedCategory == categoryKey;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = categoryKey;
                });
              },
              child: Chip(
                avatar: Icon(
                  details['icon'],
                  color: isSelected
                      ? Colors.white
                      : (isNeonMode ? Colors.white70 : Colors.black87),
                ),
                label: Text('goods_category_$categoryKey'.tr()),
                backgroundColor: isSelected
                    ? details['accentColor']
                    : (isNeonMode
                        ? Colors.grey[800]
                        : details['mainColor'].withOpacity(0.4)),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isNeonMode ? Colors.white70 : Colors.black87),
                  fontWeight: FontWeight.bold,
                ),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: isSelected
                        ? details['accentColor']
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                elevation: isSelected ? 4 : 0,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isNeonMode = themeProvider.isNeonMode;

    final customTheme = isNeonMode
        ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
            ),
            textTheme: ThemeData.dark()
                .textTheme
                .apply(bodyColor: Colors.white, displayColor: Colors.white),
            colorScheme: const ColorScheme.dark(
                primary: Colors.white, secondary: Colors.white),
          )
        : ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0.5,
            ),
            textTheme: ThemeData.light()
                .textTheme
                .apply(bodyColor: Colors.black, displayColor: Colors.black),
            colorScheme: const ColorScheme.light(
                primary: Colors.black, secondary: Colors.black),
          );

    return Theme(
      data: customTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text('add_to_collection_title'.tr()),
          foregroundColor: isNeonMode ? Colors.white : Colors.black87,
          actions: [
            IconButton(icon: const Icon(Icons.save), onPressed: _saveForm)
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: InkWell(
                    onTap: () => _showImageSourceActionSheet(context),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: _savedImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.file(File(_savedImagePath!),
                                  fit: BoxFit.cover),
                            )
                          : const Center(
                              child: Icon(Icons.add_a_photo,
                                  size: 50, color: Colors.grey),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'goods_name_label'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'name_validator_prompt'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<Box<Goods>>(
                  valueListenable: Hive.box<Goods>('goods').listenable(),
                  builder: (context, box, child) {
                    final allSeries = box.values
                        .map((goods) => goods.series)
                        .where((series) => series != null && series.isNotEmpty)
                        .map((series) => series!) // Convert String? to String
                        .toSet()
                        .toList();

                    return Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return Future.value(
                              allSeries); // Return all series as a Future
                        }
                        return allSeries.where((String option) {
                          return option.contains(textEditingValue.text);
                        });
                      },
                      onSelected: (String selection) {
                        _seriesController.text = selection;
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) {
                        return TextFormField(
                          controller: _seriesController,
                          focusNode: _seriesFocusNode,
                          decoration: InputDecoration(
                            labelText: 'series_label_optional'.tr(),
                            border: const OutlineInputBorder(),
                          ),
                          onFieldSubmitted: (String value) {
                            onFieldSubmitted();
                          },
                        );
                      },
                      optionsViewBuilder: (BuildContext context,
                          AutocompleteOnSelected<String> onSelected,
                          Iterable<String> options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            child: SizedBox(
                              height: 200.0, // Adjust height as needed
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option =
                                      options.elementAt(index);
                                  return GestureDetector(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: ListTile(
                                      title: Text(option),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                // --- New Category Card Selector UI ---
                _buildCategorySelector(isNeonMode),
                const SizedBox(height: 16),
                ValueListenableBuilder<Box<Oshi>>(
                  valueListenable: Hive.box<Oshi>('oshis').listenable(),
                  builder: (context, box, _) {
                    final oshis = box.values.toList();
                    return DropdownButtonFormField<String>(
                      value: _selectedOshiId,
                      hint: Text('oshi_member_hint'.tr()),
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      items: oshis
                          .map((oshi) => DropdownMenuItem(
                                value: oshi.id,
                                child: Text(oshi.name),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedOshiId = value),
                      validator: (value) => value == null
                          ? 'select_oshi_validator_prompt'.tr()
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _memoController,
                  decoration: InputDecoration(
                    labelText: 'memo_label_optional'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
