import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/mission_model.dart';
import '../../services/theme_provider.dart';
import '../../widgets/icon_picker_dialog.dart';

class AddMissionScreen extends StatefulWidget {
  final Mission? mission;
  const AddMissionScreen({super.key, this.mission});

  @override
  State<AddMissionScreen> createState() => _AddMissionScreenState();
}

class _AddMissionScreenState extends State<AddMissionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _goalAmountController;

  late DateTime _deadline;
  late IconData _selectedIcon;

  bool get _isEditing => widget.mission != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.mission?.title ?? '');
    _goalAmountController = TextEditingController(
        text: widget.mission?.goalAmount.toString() ?? '');

    _deadline = widget.mission?.deadline ??
        DateTime.now().add(const Duration(days: 30));
    _selectedIcon = widget.mission?.icon ?? Icons.flag;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _goalAmountController.dispose();

    super.dispose();
  }

  void _saveMission() {
    if (_formKey.currentState!.validate()) {
      final box = Hive.box<Mission>('missions');
      final mission = Mission(
        id: widget.mission?.id ?? const Uuid().v4(),
        title: _titleController.text,
        goalAmount: int.parse(_goalAmountController.text),
        deadline: _deadline,
        icon: _selectedIcon,
        currentAmount: widget.mission?.currentAmount ?? 0,
        deposits: widget.mission?.deposits ?? [],
      );
      box.put(mission.id, mission);
      Navigator.of(context).pop(true);
    }
  }

  void _selectIcon() async {
    final IconData? pickedIcon = await showDialog<IconData>(
      context: context,
      builder: (BuildContext context) {
        return const IconPickerDialog();
      },
    );
    if (pickedIcon != null) {
      setState(() {
        _selectedIcon = pickedIcon;
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
          title: Text(_isEditing
              ? 'edit_mission_title'.tr()
              : 'add_mission_title'.tr()),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveMission,
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'mission_name_label'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'mission_name_validator_prompt'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _goalAmountController,
                  decoration: InputDecoration(
                    labelText: 'goal_amount_label'.tr(),
                    border: const OutlineInputBorder(),
                    prefixText: '¥',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'goal_amount_validator_prompt'.tr();
                    }
                    if (int.tryParse(value) == null) {
                      return 'amount_validator_invalid'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text('icon_label'.tr(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListTile(
                  leading: Icon(_selectedIcon, size: 36),
                  title: Text('select_icon_label'.tr()),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selectIcon,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[400] ?? Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),
                Text('deadline_label'.tr(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(DateFormat('date_format'.tr()).format(_deadline)),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _deadline,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null) {
                          setState(() {
                            _deadline = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
