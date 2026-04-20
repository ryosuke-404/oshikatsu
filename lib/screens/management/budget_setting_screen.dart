import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class BudgetSettingScreen extends StatefulWidget {
  const BudgetSettingScreen({super.key});

  @override
  State<BudgetSettingScreen> createState() => _BudgetSettingScreenState();
}

class _BudgetSettingScreenState extends State<BudgetSettingScreen> {
  final _settingsBox = Hive.box('settings');
  late final TextEditingController _controller;
  double? _currentBudget;

  @override
  void initState() {
    super.initState();
    _currentBudget = _settingsBox.get('monthly_budget') as double?;
    _controller = TextEditingController(
      text: _currentBudget != null ? _currentBudget!.toInt().toString() : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveBudget() async {
    final value = double.tryParse(_controller.text);
    if (value != null && value >= 0) {
      await _settingsBox.put('monthly_budget', value);
      if (mounted) {
        Navigator.of(context).pop(true); // Indicate that the budget was updated
      }
    } else {
      // Show an error message if the input is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('invalid_budget_amount'.tr())),
      );
    }
  }

  void _deleteBudget() async {
    await _settingsBox.delete('monthly_budget');
    if (mounted) {
      Navigator.of(context).pop(true); // Indicate that the budget was updated
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('set_monthly_budget_dialog_title'.tr()),
        foregroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.black87
            : Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'amount_label'.tr(),
                hintText: 'enter_budget_hint'.tr(),
                prefixText: '¥ ',
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // 背景色を緑に
                foregroundColor: Colors.white, // 文字色を白に
              ),
              child: Text('save_button'.tr()),
            ),
            const SizedBox(height: 16),
            if (_currentBudget != null)
              TextButton(
                onPressed: _deleteBudget,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: Text('delete_budget_button'.tr()),
              ),
          ],
        ),
      ),
    );
  }
}
