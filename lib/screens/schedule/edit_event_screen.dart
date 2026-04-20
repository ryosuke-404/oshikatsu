import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // Uuidをインポート
import '../../models/schedule_models.dart';
import '../../models/oshi_model.dart';
import '../../services/theme_provider.dart';

class EditEventScreen extends StatefulWidget {
  final Event? event; // final Event event; から変更
  final DateTime? initialDate;
  const EditEventScreen(
      {super.key, this.event, this.initialDate}); // requiredを削除

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _titleController;
  late DateTime _selectedDate;
  String? _selectedOshiId;
  late EventCategory _selectedCategory;
  late int _priority;
  late bool _isYearlyRecurring;
  late bool _isNewEvent; // 新しいイベントかどうかを判断するフラグ

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _isNewEvent = widget.event == null; // eventがnullなら新しいイベント

    if (_isNewEvent) {
      // 新しいイベントの場合の初期化
      _titleController = TextEditingController();
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedOshiId = null;
      _selectedCategory = EventCategory.other; // デフォルトカテゴリ
      _priority = 3;
      _isYearlyRecurring = false;
    } else {
      // 既存のイベントの場合の初期化
      _titleController = TextEditingController(text: widget.event!.title);
      _selectedDate = widget.event!.date;
      _selectedOshiId = widget.event!.oshiId;
      _selectedCategory = widget.event!.category;
      _priority = widget.event!.priority;
      _isYearlyRecurring = widget.event!.isYearlyRecurring;
    }
  }

  void _saveEvent() {
    // _updateEventから_saveEventに名称変更
    if (_formKey.currentState!.validate()) {
      try {
        final eventBox = Hive.box<Event>('events');
        Event eventToSave;

        if (_isNewEvent) {
          // 新しいイベントを作成
          eventToSave = Event(
            id: const Uuid().v4(), // 新しいユニークなIDを生成
            title: _titleController.text,
            date: _selectedDate,
            memo: null, // メモは別途入力欄があればそこから取得
            oshiId: _selectedOshiId,
            category: _selectedCategory,
            priority: _priority,
            isYearlyRecurring: _isYearlyRecurring,
          );
        } else {
          // 既存のイベントを更新
          eventToSave = widget.event!;
          eventToSave.title = _titleController.text;
          eventToSave.date = _selectedDate;
          eventToSave.oshiId = _selectedOshiId;
          eventToSave.category = _selectedCategory;
          eventToSave.priority = _priority;
          eventToSave.isYearlyRecurring = _isYearlyRecurring;
        }

        eventBox.put(eventToSave.id, eventToSave); // putで追加または更新
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_isNewEvent
                ? 'event_added_message'.tr()
                : 'event_updated_message'.tr()),
            backgroundColor: Colors.green));
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_isNewEvent
                ? 'event_add_failed_message'.tr(args: [e.toString()])
                : 'event_update_failed_message'.tr(args: [e.toString()])),
            backgroundColor: Colors.redAccent));
      }
    }
  }

  void _deleteEvent() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_event_confirm_title'.tr()),
        content: Text('delete_event_confirm_message'.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('cancel'.tr())),
          TextButton(
            onPressed: () {
              try {
                widget.event!.delete(); // 既存イベントのみ削除可能
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('event_deleted_message'.tr()),
                    backgroundColor: Colors.green));
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'event_delete_failed_message'.tr(args: [e.toString()])),
                    backgroundColor: Colors.redAccent));
                Navigator.of(ctx).pop();
              }
            },
            child:
                Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
          title: Text(_isNewEvent
              ? 'add_new_event_title'.tr()
              : 'edit_event_title'.tr()), // タイトルを動的に変更
          actions: [
            if (!_isNewEvent) // 新しいイベントの場合は削除ボタンを表示しない
              IconButton(
                  icon: const Icon(Icons.delete), onPressed: _deleteEvent),
            IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveEvent), // _updateEventから_saveEventに名称変更
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      labelText: 'event_title_label'.tr(),
                      border: const OutlineInputBorder()),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'title_validator_prompt'.tr()
                      : null,
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('date_label'.tr(namedArgs: {
                    'date': DateFormat('y年M月d日').format(_selectedDate)
                  })),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030));
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<Box<Oshi>>(
                  valueListenable: Hive.box<Oshi>('oshis').listenable(),
                  builder: (context, oshiBox, _) {
                    return DropdownButtonFormField<String>(
                      value: _selectedOshiId,
                      hint: Text('which_oshi_event_optional'.tr()),
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
                  children: EventCategory.values
                      .where((cat) => eventCategoryDetails.containsKey(cat))
                      .map((category) {
                    final details = eventCategoryDetails[category];
                    final isSelected = _selectedCategory == category;
                    final color = details?['color'] as Color? ??
                        Colors.grey; // Fallback color
                    return SizedBox(
                      width: 90,
                      height: 80,
                      child: InkWell(
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.2)
                                : (isNeonMode
                                    ? Colors.grey[900]
                                    : Colors.grey[50]),
                            border: Border.all(
                                color: isSelected
                                    ? color
                                    : color.withOpacity(
                                        0.3)), // Use category color for border
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                  details?['icon'] as IconData? ??
                                      Icons.help_outline,
                                  size: 28,
                                  color: isSelected
                                      ? color
                                      : color.withOpacity(
                                          0.6)), // Use category color for icon
                              const SizedBox(height: 4),
                              Text('event_category_${category.name}'.tr(),
                                  style: TextStyle(
                                      fontSize: 10,
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
                const SizedBox(height: 16), // カテゴリと繰り返し設定の間にスペースを追加
                CheckboxListTile(
                  // 追加
                  title: Text('repeat_yearly_label'.tr()),
                  value: _isYearlyRecurring,
                  onChanged: (bool? value) {
                    setState(() {
                      _isYearlyRecurring = value ?? false;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, // チェックボックスを左に配置
                ),
                const SizedBox(height: 24),
                Text('priority_label'.tr(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Slider(
                  value: _priority.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: 'priority_value_label'
                      .tr(namedArgs: {'priority': _priority.toString()}),
                  onChanged: (double value) {
                    setState(() {
                      _priority = value.toInt();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
