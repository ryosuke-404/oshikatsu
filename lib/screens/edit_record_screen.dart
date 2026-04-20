import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../models/record_model.dart';
import '../../models/oshi_model.dart';
import '../../services/theme_provider.dart';

class EditRecordScreen extends StatefulWidget {
  final Record record;
  const EditRecordScreen({super.key, required this.record});

  @override
  State<EditRecordScreen> createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  late final TextEditingController _titleController;
  late RecordCategory _selectedCategory;
  String? _savedImagePath;
  late double _rating;
  late List<String> _emotionTags;
  late DateTime _selectedDate;

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
  late List<String> _setlist; // セットリストを保持するリスト
  late final TextEditingController _memoController; // メモ入力用
  late final TextEditingController _relatedUrlController; // 関連URL入力用

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.record.title);
    _selectedCategory = widget.record.category;
    _savedImagePath = widget.record.imagePath;
    _rating = widget.record.rating;
    _emotionTags = List<String>.from(widget.record.emotionTags);
    _selectedDate = widget.record.date;
    _setlist = List<String>.from(widget.record.setlist ?? []); // 既存のセットリストをロード
    _memoController =
        TextEditingController(text: widget.record.memo ?? ''); // メモをロード
    _relatedUrlController = TextEditingController(
        text: widget.record.relatedUrl ?? ''); // 関連URLをロード

    // エラー修正: widget.record.oshiIdがnullでないこと、かつそのIDがoshiBoxに存在することを確認
    final oshiBox = Hive.box<Oshi>('oshis');
    if (widget.record.oshiId != null &&
        oshiBox.containsKey(widget.record.oshiId)) {
      _selectedOshiId = widget.record.oshiId;
    } else {
      _selectedOshiId = null; // 該当しない場合はnullを設定
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _setlistItemController.dispose();
    _memoController.dispose(); // Dispose memo controller
    _relatedUrlController.dispose();
    super.dispose();
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
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

  Future<void> _updateRecord() async {
    try {
      widget.record.title = _titleController.text;
      widget.record.category = _selectedCategory;
      widget.record.date = _selectedDate;
      widget.record.imagePath = _savedImagePath;
      widget.record.rating = _rating;
      widget.record.emotionTags = _emotionTags;
      widget.record.oshiId = _selectedOshiId;
      widget.record.setlist = _selectedCategory == RecordCategory.liveConcert
          ? _setlist
          : null; // セットリストを保存
      widget.record.memo = _memoController.text; // Save memo content
      widget.record.relatedUrl = _relatedUrlController.text.isNotEmpty
          ? _relatedUrlController.text
          : null;
      await widget.record.save(); // 変更を保存
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('record_updated_message'.tr()),
          backgroundColor: Colors.green));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const App(initialIndex: 2)), // RecordScreen のインデックスは 2
        (Route<dynamic> route) => false, // 全てのルートを削除して新しい App をプッシュ
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('record_update_failed_message'.tr(args: [e.toString()])),
          backgroundColor: Colors.redAccent));
    }
  }

  void _deleteRecord() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text('delete_record_confirm_title'.tr()),
                content: Text('delete_record_confirm_message'.tr()),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('cancel'.tr())),
                  TextButton(
                      onPressed: () {
                        try {
                          widget.record.delete();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('record_deleted_message'.tr()),
                              backgroundColor: Colors.green));
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('record_delete_failed_message'
                                  .tr(args: [e.toString()])),
                              backgroundColor: Colors.redAccent));
                          Navigator.of(ctx).pop();
                        }
                      },
                      child: Text('delete'.tr(),
                          style: const TextStyle(color: Colors.red)))
                ]));
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
        appBar: AppBar(title: Text('edit_record_title'.tr()), actions: [
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteRecord,
              tooltip: 'delete'.tr()),
          IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateRecord,
              tooltip: 'save'.tr())
        ]),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade400)),
                          child: _savedImagePath != null &&
                                  _savedImagePath!.isNotEmpty
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
                      border: const OutlineInputBorder())),
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
                runSpacing: 8.0, // Add runSpacing for better layout
                children: RecordCategory.values.map((category) {
                  final details = categoryDetails[category];
                  final isSelected = _selectedCategory == category;
                  final color = details?['color'] as Color? ??
                      Colors.grey; // Fallback color
                  return SizedBox(
                    width: 100, // Consistent width with AddEventScreen
                    height: 90, // Consistent height with AddEventScreen
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
                            Icon(
                                details?['icon'] as IconData? ??
                                    Icons.help_outline,
                                size: 32,
                                color: isSelected
                                    ? color
                                    : color.withOpacity(0.6)),
                            const SizedBox(height: 4),
                            Text(
                                tr(details?['name'] as String? ??
                                    'unknown_category_name'),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? color
                                        : (isNeonMode
                                            ? Colors.white70
                                            : color.withOpacity(0.6))),
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
              Wrap(
                spacing: 8.0,
                children: _allEmotionTags.map((tag) {
                  final isSelected = _emotionTags.contains(tag);
                  return FilterChip(
                    label: Text(
                      tag,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isNeonMode ? Colors.white : Colors.black),
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
                    backgroundColor:
                        isNeonMode ? Colors.grey[800] : Colors.grey[200],
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
            ],
          ),
        ),
      ),
    );
  }
}
