import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/record_model.dart';
import '../models/oshi_model.dart';
import '../services/theme_provider.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});
  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _titleController = TextEditingController();
  RecordCategory? _selectedCategory;
  String? _savedImagePath;
  double _rating = 3.0;
  final List<String> _emotionTags = [];
  DateTime _selectedDate = DateTime.now();

  final List<String> _allEmotionTags = [
    '尊い',
    '萌える',
    '沼る',
    '尊死',
    'ときめく',
    'エモい',
    '推せる',
    '優勝',
    '天才',
    '無理',
    '神',
    '愛でる',
    '箱推し',
    '単推し',
    'ガチ恋',
    '解釈違い',
    '供養',
    '推し変',
    '爆死',
    '当選',
    '落選',
    '推ししか勝たん',
    '課金',
    '布教',
    '激エモ',
    'バブい',
    'しんどい',
    'やばい',
    '推し不足',
    '推し疲れ',
    '同担',
    '界隈',
    '現場',
    '刺さる',
    '推し被り',
    'オタク卒業',
    '沸く',
    'マジ推し',
    '推しの笑顔で今日も生きる'
  ];
  String? _selectedOshiId;
  final TextEditingController _setlistItemController =
      TextEditingController(); // セットリスト項目入力用
  final _memoController = TextEditingController();
  final _relatedUrlController = TextEditingController();
  final List<String> _setlist = []; // セットリストを保持するリスト

  @override
  void dispose() {
    _titleController.dispose();
    _setlistItemController.dispose();
    _memoController.dispose();
    _relatedUrlController.dispose();
    super.dispose();
  }

  void _showAddTagDialog() {
    final TextEditingController tagController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('create_original_tag_dialog_title'.tr()),
          content: TextField(
            controller: tagController,
            decoration: InputDecoration(hintText: "enter_tag_name_hint".tr()),
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: Text('cancel'.tr()),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('create_button'.tr()),
              onPressed: () {
                final String newTag = tagController.text.trim();
                if (newTag.isNotEmpty) {
                  final customTagsBox = Hive.box<String>('custom_tags');
                  final settingsBox = Hive.box('settings');

                  // タグが重複していないかチェック
                  if (!customTagsBox.values.contains(newTag) &&
                      !_allEmotionTags.contains(newTag)) {
                    customTagsBox.add(newTag);
                    final rights = settingsBox.get('custom_tag_creation_rights',
                        defaultValue: 0) as int;
                    if (rights > 0) {
                      settingsBox.put('custom_tag_creation_rights', rights - 1);
                    }
                    Navigator.of(context).pop();
                  } else {
                    // ユーザーに重複していることを通知
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('tag_already_exists_message'.tr()),
                          backgroundColor: Colors.redAccent),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveRecord() {
    if (_titleController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('title_and_category_are_required'.tr()),
          backgroundColor: Colors.redAccent));
      return;
    }
    final recordBox = Hive.box<Record>('records');
    try {
      final newRecord = Record(
        id: const Uuid().v4(),
        title: _titleController.text,
        category: _selectedCategory!,
        date: _selectedDate,
        imagePath: _savedImagePath,
        rating: _rating,
        emotionTags: _emotionTags,
        oshiId: _selectedOshiId,
        setlist: _selectedCategory == RecordCategory.liveConcert
            ? _setlist
            : null, // セットリストを保存
        memo: _memoController.text,
        relatedUrl: _relatedUrlController.text.isNotEmpty
            ? _relatedUrlController.text
            : null,
      );
      recordBox.add(newRecord);

      // --- Experience Boost Logic ---
      final settingsBox = Hive.box('settings');
      final bool isBoostActive =
          settingsBox.get('experience_boost_active', defaultValue: false);
      bool bonusApplied = false;
      if (isBoostActive) {
        final int bonusCount =
            settingsBox.get('bonus_record_count', defaultValue: 0);
        settingsBox.put('bonus_record_count', bonusCount + 1);
        settingsBox.put('experience_boost_active', false); // ボーナスを消費
        bonusApplied = true;
      }
      // --- End of Logic ---

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(bonusApplied
              ? 'record_saved_with_bonus_message'.tr()
              : 'record_saved_message'.tr()),
          backgroundColor: Colors.green));
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('record_save_failed_message'.tr(args: [e.toString()])),
          backgroundColor: Colors.redAccent));
    }
  }

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? media =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (media != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(media.path);
      final savedImage =
          await File(media.path).copy('${appDir.path}/$fileName');
      setState(() {
        _savedImagePath = savedImage.path;
      });
    }
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
          );

    return Theme(
      data: customTheme,
      child: Scaffold(
        appBar: AppBar(title: Text('add_new_record_title'.tr()), actions: [
          IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveRecord,
              tooltip: 'save'.tr())
        ]),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: InkWell(
                      onTap: _pickMedia,
                      child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade400)),
                          child: _savedImagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.file(File(_savedImagePath!),
                                      fit: BoxFit.cover))
                              : Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                      const Icon(Icons.add_a_photo,
                                          size: 50, color: Colors.grey),
                                      const SizedBox(height: 8),
                                      Text('tap_to_select_image'.tr(),
                                          style: const TextStyle(
                                              color: Colors.grey))
                                    ]))))),
              const SizedBox(height: 24),
              TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      labelText: 'title_label'.tr(),
                      border: const OutlineInputBorder(),
                      hintText: 'title_hint'.tr())),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text('date_label'.tr(namedArgs: {
                  'date': MaterialLocalizations.of(context)
                      .formatFullDate(_selectedDate)
                })),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<Box<Oshi>>(
                valueListenable: Hive.box<Oshi>('oshis').listenable(),
                builder: (context, oshiBox, _) {
                  return DropdownButtonFormField<String>(
                    value: _selectedOshiId,
                    hint: Text('which_oshi_record_optional'.tr()),
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    items: oshiBox.values
                        .map((oshi) => DropdownMenuItem(
                            value: oshi.id, child: Text(oshi.name)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedOshiId = value),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text('category_label'.tr(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: RecordCategory.values.map((category) {
                  final details = categoryDetails[category]!;
                  final isSelected = _selectedCategory == category;
                  final color = details['color'] as Color;
                  return SizedBox(
                    width: 100,
                    height: 90,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                          if (_selectedCategory != RecordCategory.liveConcert) {
                            _setlist.clear();
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.2)
                              : (isNeonMode
                                  ? Colors.grey[900]
                                  : Colors.grey[50]),
                          border: Border.all(
                              color: isSelected ? color : Colors.grey.shade300,
                              width: isSelected ? 2 : 1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2)
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(details['icon'] as IconData,
                                size: 32,
                                color: isSelected
                                    ? color
                                    : color.withOpacity(0.6)),
                            const SizedBox(height: 4),
                            Text(tr(details['name'] as String),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? color
                                        : (isNeonMode
                                            ? Colors.white70
                                            : Colors.grey[700])),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text('memo_label'.tr(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _memoController,
                decoration: InputDecoration(
                  hintText: 'memo_hint'.tr(),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _relatedUrlController,
                decoration: InputDecoration(
                  labelText: 'related_url_optional_label'.tr(),
                  hintText: 'related_url_hint'.tr(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              if (_selectedCategory == RecordCategory.liveConcert) ...[
                const SizedBox(height: 24),
                Text('setlist_label'.tr(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _setlistItemController,
                        decoration: InputDecoration(
                            hintText: 'enter_song_name_hint'.tr(),
                            border: const OutlineInputBorder()),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              _setlist.add(value);
                              _setlistItemController.clear();
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (_setlistItemController.text.isNotEmpty) {
                          setState(() {
                            _setlist.add(_setlistItemController.text);
                            _setlistItemController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _setlist.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_setlist[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            _setlist.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 24),
              Text('rating_label'.tr(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Center(
                child: RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) => setState(() => _rating = rating),
                ),
              ),
              const SizedBox(height: 24),
              Text('emotion_tags_label'.tr(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              AnimatedBuilder(
                animation: Listenable.merge([
                  Hive.box('settings').listenable(),
                  Hive.box<String>('custom_tags').listenable(),
                ]),
                builder: (context, child) {
                  final settingsBox = Hive.box('settings');
                  final customTagsBox = Hive.box<String>('custom_tags');
                  final customTags = customTagsBox.values.toList();
                  final combinedTags = [..._allEmotionTags, ...customTags];
                  final tagCreationRights = settingsBox.get(
                      'custom_tag_creation_rights',
                      defaultValue: 0) as int;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8.0,
                        children: combinedTags.map((tag) {
                          final isSelected = _emotionTags.contains(tag);
                          return FilterChip(
                            label: Text(
                              tag,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : (isNeonMode
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _emotionTags.add(tag);
                                } else {
                                  _emotionTags.remove(tag);
                                }
                              });
                            },
                            selectedColor: Theme.of(context).primaryColor,
                            backgroundColor: isNeonMode
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            checkmarkColor: Colors.white,
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade400,
                                width: 1.0,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text('add_original_tag_button'.tr(namedArgs: {
                          'count': tagCreationRights.toString()
                        })),
                        onPressed: tagCreationRights > 0
                            ? () => _showAddTagDialog()
                            : null,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
