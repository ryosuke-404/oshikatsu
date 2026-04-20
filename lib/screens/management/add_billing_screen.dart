import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/billing_model.dart';
import '../../models/oshi_model.dart'; // Import Oshi model
import '../../services/theme_provider.dart';

class AddBillingScreen extends StatefulWidget {
  final BillingRecord? record;
  const AddBillingScreen({super.key, this.record});

  @override
  State<AddBillingScreen> createState() => _AddBillingScreenState();
}

class _AddBillingScreenState extends State<AddBillingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  BillingCategory? _selectedCategory;
  PaymentMethod? _selectedPaymentMethod; // Changed to nullable
  DateTime _selectedDate = DateTime.now();
  String? _selectedOshiId; // New: For Oshi selection
  bool _isRepeating = false; // New: For repeat setting
  bool _isCancelled = false; // New: For cancellation

  bool get _isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.record?.title ?? '');
    _amountController =
        TextEditingController(text: widget.record?.amount.toString() ?? '');
    _selectedCategory = widget.record?.category;
    _selectedPaymentMethod =
        widget.record?.paymentMethod; // Initialize with nullable
    _selectedDate = widget.record?.date ?? DateTime.now();
    _selectedOshiId = widget.record?.oshiId; // Initialize Oshi ID
    _isRepeating =
        widget.record?.isRepeating ?? false; // Initialize repeat setting
    _isCancelled =
        widget.record?.isCancelled ?? false; // Initialize cancellation status
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('select_category_message'.tr()),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (_selectedPaymentMethod == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('select_payment_method_message'.tr()),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final box = Hive.box<BillingRecord>('billing_records');
      try {
        final record = BillingRecord(
          id: widget.record?.id ?? const Uuid().v4(),
          title: _titleController.text,
          amount: int.parse(_amountController.text),
          category: _selectedCategory!,
          date: _selectedDate,
          paymentMethod: _selectedPaymentMethod,
          oshiId: _selectedOshiId, // Use selected Oshi ID
          isRepeating: _isRepeating, // Save repeat setting
          isCancelled: _isCancelled, // Save cancellation status
        );
        box.put(record.id, record);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'billing_record_updated_message'.tr()
                : 'billing_record_saved_message'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'billing_record_update_failed_message'
                    .tr(args: [e.toString()])
                : 'billing_record_save_failed_message'
                    .tr(args: [e.toString()])),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
              ? 'edit_billing_title'.tr()
              : 'add_billing_title'.tr()),
          actions: [
            // Delete button (only in edit mode)
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmDialog(context),
                tooltip: 'delete_tooltip'.tr(),
              ),
            // Save button
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveForm,
              tooltip: 'save_tooltip'.tr(),
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
                    labelText: 'content_label'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'content_validator'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    // Changed to InputDecoration
                    labelText: _isRepeating &&
                            _selectedCategory ==
                                BillingCategory.fanClubSubscription
                        ? 'monthly_amount_label'
                            .tr() // Label for recurring amount
                        : 'amount_label'.tr(), // Original label
                    border: const OutlineInputBorder(),
                    prefixText: '¥',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'amount_validator_empty'.tr();
                    }
                    if (int.tryParse(value) == null) {
                      return 'amount_validator_invalid'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Oshi Selection
                Text(
                  'which_oshi_label'.tr(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<Box<Oshi>>(
                  valueListenable: Hive.box<Oshi>('oshis').listenable(),
                  builder: (context, oshiBox, _) {
                    final oshis = oshiBox.values.toList();
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildOshiChoiceChip(null, isNeonMode),
                          ...oshis.map((oshi) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: _buildOshiChoiceChip(oshi, isNeonMode),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Category Selection (Cards)
                Text(
                  'category_label'.tr(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true, // Important to prevent unbounded height
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columns as requested
                    crossAxisSpacing: 8.0, // Horizontal space between items
                    mainAxisSpacing: 8.0, // Vertical space between items
                    childAspectRatio:
                        3.5, // Adjusted aspect ratio for 2 columns
                  ),
                  itemCount: BillingCategory.values.length,
                  itemBuilder: (context, index) {
                    final category = BillingCategory.values[index];
                    final details = billingCategoryDetails[category];
                    final isSelected = _selectedCategory == category;
                    final categoryColor =
                        Color(details?['color'] as int? ?? Colors.grey.value);

                    return ChoiceChip(
                      label: Row(
                        children: [
                          Icon(
                            details?['icon'] as IconData? ?? Icons.help,
                            color: isSelected ? Colors.white : categoryColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'billing_category_${category.name}'.tr(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: isSelected ? Colors.white : null),
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                      },
                      selectedColor: categoryColor,
                      backgroundColor: categoryColor.withOpacity(0.1),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Conditional Repeat Setting for Fan Club/Subscription
                if (_selectedCategory ==
                    BillingCategory.fanClubSubscription) ...[
                  SwitchListTile(
                    title: Text('repeat_setting_title'.tr()),
                    subtitle: Text('repeat_setting_subtitle'.tr()),
                    value: _isRepeating,
                    onChanged: (value) {
                      setState(() {
                        _isRepeating = value;
                      });
                    },
                  ),
                  // Cancellation button (visible only for editing recurring records that are not yet cancelled)
                  if (_isEditing && _isRepeating && !_isCancelled)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                  'cancel_repeat_setting_dialog_title'.tr()),
                              content: Text(
                                  'cancel_repeat_setting_dialog_content'.tr()),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text('cancel'.tr()),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(
                                      'cancel_repeat_setting_button'.tr(),
                                      style:
                                          const TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            setState(() {
                              _isCancelled = true;
                            });
                            _saveForm(); // Save the updated cancellation status
                          }
                        },
                        icon: const Icon(Icons.cancel),
                        label: Text('cancel_repeat_setting_action_button'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Background color
                          foregroundColor: Colors.white, // Text color
                          minimumSize:
                              const Size(double.infinity, 48), // Full width
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
                // Payment Method Selection (Buttons)
                Text(
                  'payment_method_label'.tr(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: PaymentMethod.values.map((method) {
                      final isSelected = _selectedPaymentMethod == method;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text('payment_method_${method.name}'.tr()),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedPaymentMethod = selected ? method : null;
                            });
                          },
                          selectedColor: Theme.of(context).colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? (isNeonMode ? Colors.black : Colors.white)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                // Date Selection
                Text(
                  'date_label'.tr().split(':').first,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(DateFormat('date_format'.tr()).format(_selectedDate)),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100), // Allow future dates
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
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

  // Helper widget for Oshi choice chips to reduce code duplication
  Widget _buildOshiChoiceChip(Oshi? oshi, bool isNeonMode) {
    final isSelected = _selectedOshiId == oshi?.id;
    final label = oshi?.name ?? 'no_oshi_specified'.tr();
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedOshiId = selected ? oshi?.id : null;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? (isNeonMode ? Colors.black : Colors.white) : null,
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('confirm'.tr()),
        content: Text('delete_billing_confirm_message'
            .tr(namedArgs: {'title': widget.record!.title})),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('cancel'.tr())),
          TextButton(
            onPressed: () {
              try {
                widget.record!.delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('billing_record_deleted_message'.tr()),
                      backgroundColor: Colors.green),
                );
                Navigator.of(ctx).pop(); // Close the dialog
                Navigator.of(context).pop(); // Pop the AddBillingScreen
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('billing_record_delete_failed_message'
                          .tr(args: [e.toString()])),
                      backgroundColor: Colors.redAccent),
                );
                Navigator.of(ctx).pop(); // Close the dialog
              }
            },
            child:
                Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
