import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; // Import Hive
import 'package:provider/provider.dart';
import '../../models/schedule_models.dart';
import '../../models/oshi_model.dart'; // Import Oshi model
import '../../services/theme_provider.dart';

class EditItineraryScreen extends StatefulWidget {
  final Itinerary itinerary;
  const EditItineraryScreen({super.key, required this.itinerary});

  @override
  State<EditItineraryScreen> createState() => _EditItineraryScreenState();
}

class _EditItineraryScreenState extends State<EditItineraryScreen> {
  late final TextEditingController _titleController;
  late DateTime _startDate;
  late DateTime _endDate;
  late final TextEditingController _memoContentController;
  String? _selectedOshiId; // To store selected Oshi ID
  List<Oshi> _oshis = []; // To store fetched Oshi objects
  final List<TextEditingController> _todoControllers = []; // ToDoリストのコントローラー

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.itinerary.title);
    _startDate = widget.itinerary.startDate;
    _endDate = widget.itinerary.endDate;
    _memoContentController =
        TextEditingController(text: widget.itinerary.memoContent);
    _selectedOshiId =
        widget.itinerary.oshiId; // Initialize with current Oshi ID
    _loadOshis();

    // 既存のToDoリストを読み込み
    if (widget.itinerary.todoList != null &&
        widget.itinerary.todoList!.isNotEmpty) {
      for (var todoItem in widget.itinerary.todoList!) {
        _todoControllers.add(TextEditingController(text: todoItem.description));
      }
    } else {
      _addTodoItem(); // ToDoがない場合は初期状態で1つの入力欄を追加
    }
  }

  Future<void> _loadOshis() async {
    final oshiBox = Hive.box<Oshi>('oshis');
    setState(() {
      _oshis = oshiBox.values.toList();
    });
  }

  void _addTodoItem() {
    setState(() {
      _todoControllers.add(TextEditingController());
    });
  }

  void _removeTodoItem(int index) {
    setState(() {
      _todoControllers[index].dispose();
      _todoControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoContentController.dispose();
    for (var controller in _todoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateItinerary() {
    try {
      widget.itinerary.title = _titleController.text;
      widget.itinerary.startDate = _startDate;
      widget.itinerary.endDate = _endDate;
      widget.itinerary.memoContent = _memoContentController.text;
      widget.itinerary.oshiId = _selectedOshiId; // Update Oshi ID

      // ToDoリストを更新
      widget.itinerary.todoList = _todoControllers
          .where((c) => c.text.isNotEmpty)
          .map((c) => TodoItem(description: c.text))
          .toList();

      widget.itinerary.save();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('itinerary_updated_message'.tr()),
          backgroundColor: Colors.green));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('itinerary_update_failed_message'.tr(args: [e.toString()])),
          backgroundColor: Colors.redAccent));
    }
  }

  void _deleteItinerary() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('confirm'.tr()),
              content: Text('delete_itinerary_confirm_message'.tr()),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('cancel'.tr())),
                TextButton(
                    onPressed: () {
                      try {
                        widget.itinerary.delete();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('itinerary_deleted_message'.tr()),
                            backgroundColor: Colors.green));
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('itinerary_delete_failed_message'
                                .tr(args: [e.toString()])),
                            backgroundColor: Colors.redAccent));
                        Navigator.of(ctx).pop();
                      }
                    },
                    child: Text('delete'.tr(),
                        style: const TextStyle(color: Colors.red))),
              ],
            ));
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
          title: Text('edit_itinerary_title'.tr()),
          actions: [
            IconButton(
                icon: const Icon(Icons.delete), onPressed: _deleteItinerary),
            IconButton(
                icon: const Icon(Icons.save), onPressed: _updateItinerary),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'title_label'.tr())),
              const SizedBox(height: 20),
              ListTile(
                title: Text('period_label'.tr(namedArgs: {
                  'start_date':
                      DateFormat('date_format_long'.tr()).format(_startDate),
                  'end_date':
                      DateFormat('date_format_long'.tr()).format(_endDate)
                })),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    initialDateRange:
                        DateTimeRange(start: _startDate, end: _endDate),
                  );
                  if (picked != null) {
                    setState(() {
                      _startDate = picked.start;
                      _endDate = picked.end;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              // Oshi Selection Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'select_oshi_label'.tr(),
                  icon: const Icon(Icons.person),
                ),
                value: _selectedOshiId,
                items: _oshis.map((oshi) {
                  return DropdownMenuItem<String>(
                    value: oshi.id,
                    child: Text(oshi.name),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedOshiId = newValue;
                  });
                },
                hint: Text('select_oshi_hint'.tr()),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _memoContentController,
                decoration: InputDecoration(
                  labelText: 'memo_content_label'.tr(),
                  hintText: 'memo_content_hint'.tr(),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),
              // ToDoリストセクション
              Align(
                alignment: Alignment.centerLeft,
                child: Text('todo_list_label'.tr(),
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _todoControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _todoControllers[index],
                          decoration: InputDecoration(
                            hintText: 'todo_item_hint'.tr(
                                namedArgs: {'index': (index + 1).toString()}),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removeTodoItem(index),
                      ),
                    ],
                  );
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text('add_todo_item_button'.tr()),
                  onPressed: _addTodoItem,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
