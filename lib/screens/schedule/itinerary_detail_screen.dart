import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../models/schedule_models.dart';
import '../../widgets/animated_gradient_app_bar.dart';

class ItineraryDetailScreen extends StatefulWidget {
  final Itinerary itinerary;
  final bool isNewItinerary;

  const ItineraryDetailScreen({
    super.key,
    required this.itinerary,
    this.isNewItinerary = false,
  });

  @override
  State<ItineraryDetailScreen> createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends State<ItineraryDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Itinerary _currentItinerary; // Use a mutable copy for editing

  // Controllers for Memo Tab
  late TextEditingController _memoController;

  // Controllers for Budget Tab
  late TextEditingController _transportationCostController;
  late TextEditingController _accommodationCostController;
  late TextEditingController _ticketCostController;
  late TextEditingController _localCostController;

  // Controllers for Belongings Tab
  late TextEditingController _checklistItemController;

  // Controllers for Schedule Tab
  final TextEditingController _scheduleTitleController =
      TextEditingController();
  final TextEditingController _scheduleLocationController =
      TextEditingController();
  final TextEditingController _scheduleMemoController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // A flag to track if any changes have been made.
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Create a deep copy of the itinerary. This prevents accidental modifications
    // to the original object until the user explicitly saves their changes.
    _currentItinerary = widget.itinerary.copyWith(
      scheduleItems: List<ScheduleItem>.from(
          widget.itinerary.scheduleItems.map((item) => item.copyWith())),
      checklist: List<ChecklistItem>.from(
          widget.itinerary.checklist.map((item) => item.copyWith())),
    );

    // Initialize controllers with data from the copied itinerary
    _memoController =
        TextEditingController(text: _currentItinerary.memoContent);
    _transportationCostController = TextEditingController(
        text: _currentItinerary.transportationCost?.toStringAsFixed(0) ?? '');
    _accommodationCostController = TextEditingController(
        text: _currentItinerary.accommodationCost?.toStringAsFixed(0) ?? '');
    _ticketCostController = TextEditingController(
        text: _currentItinerary.ticketCost?.toStringAsFixed(0) ?? '');
    _localCostController = TextEditingController(
        text: _currentItinerary.localCost?.toStringAsFixed(0) ?? '');
    _checklistItemController = TextEditingController();

    // Add listeners to all controllers to detect user edits
    _memoController.addListener(_markDirty);
    _transportationCostController.addListener(_markDirty);
    _accommodationCostController.addListener(_markDirty);
    _ticketCostController.addListener(_markDirty);
    _localCostController.addListener(_markDirty);
    _scheduleTitleController.addListener(_markDirty);
    _scheduleLocationController.addListener(_markDirty);
    _scheduleMemoController.addListener(_markDirty);

    // Add listeners for budget fields to update total in real-time
    _transportationCostController.addListener(_updateTotal);
    _accommodationCostController.addListener(_updateTotal);
    _ticketCostController.addListener(_updateTotal);
    _localCostController.addListener(_updateTotal);
  }

  @override
  void dispose() {
    // Dispose all controllers to free up resources
    _tabController.dispose();
    _memoController.dispose();
    _transportationCostController.dispose();
    _accommodationCostController.dispose();
    _ticketCostController.dispose();
    _localCostController.dispose();
    _checklistItemController.dispose();
    _scheduleTitleController.dispose();
    _scheduleLocationController.dispose();
    _scheduleMemoController.dispose();
    super.dispose();
  }

  // Sets the dirty flag to true, indicating that there are unsaved changes.
  // This also triggers a UI rebuild to update the save icon.
  void _markDirty() {
    if (!_isDirty) {
      setState(() {
        _isDirty = true;
      });
    }
  }

  void _updateTotal() {
    setState(() {});
  }

  // Saves the changes from the controllers and lists back to the original Hive object.
  void _saveItinerary() {
    // Update the original itinerary object with the edited data
    widget.itinerary.memoContent = _memoController.text;
    widget.itinerary.transportationCost =
        double.tryParse(_transportationCostController.text);
    widget.itinerary.accommodationCost =
        double.tryParse(_accommodationCostController.text);
    widget.itinerary.ticketCost = double.tryParse(_ticketCostController.text);
    widget.itinerary.localCost = double.tryParse(_localCostController.text);
    widget.itinerary.scheduleItems = _currentItinerary.scheduleItems;
    widget.itinerary.checklist = _currentItinerary.checklist;

    try {
      if (widget.isNewItinerary) {
        Hive.box<Itinerary>('itineraries').add(widget.itinerary);
      } else {
        widget.itinerary.save();
      }

      // Set dirty flag to false after saving to allow popping without a dialog.
      setState(() {
        _isDirty = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('itinerary_saved_message'.tr()),
          backgroundColor: Colors.green));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('itinerary_save_failed_message'.tr(args: [e.toString()])),
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
                Navigator.of(ctx).pop(); // Close dialog
                Navigator.of(context).pop(); // Pop ItineraryDetailScreen
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('itinerary_delete_failed_message'
                        .tr(args: [e.toString()])),
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

  // Checklist methods
  void _addChecklistItem() {
    if (_checklistItemController.text.isNotEmpty) {
      setState(() {
        _currentItinerary.checklist
            .add(ChecklistItem(title: _checklistItemController.text));
        _checklistItemController.clear();
        _markDirty(); // Mark changes
      });
    }
  }

  void _toggleChecklistItem(int index, bool? value) {
    setState(() {
      _currentItinerary.checklist[index].isChecked = value ?? false;
      _markDirty(); // Mark changes
    });
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _currentItinerary.checklist.removeAt(index);
      _markDirty(); // Mark changes
    });
  }

  // Schedule methods
  void _addScheduleItem() {
    if (_scheduleTitleController.text.isNotEmpty) {
      final newScheduleItem = ScheduleItem(
        time: DateTime(
          _currentItinerary.startDate.year,
          _currentItinerary.startDate.month,
          _currentItinerary.startDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        title: _scheduleTitleController.text,
        location: _scheduleLocationController.text.isEmpty
            ? null
            : _scheduleLocationController.text,
        memo: _scheduleMemoController.text.isEmpty
            ? null
            : _scheduleMemoController.text,
      );
      setState(() {
        _currentItinerary.scheduleItems.add(newScheduleItem);
        _currentItinerary.scheduleItems
            .sort((a, b) => a.time.compareTo(b.time));
        _scheduleTitleController.clear();
        _scheduleLocationController.clear();
        _scheduleMemoController.clear();
        _markDirty(); // Mark changes
      });
    }
  }

  void _removeScheduleItem(int index) {
    setState(() {
      _currentItinerary.scheduleItems.removeAt(index);
      _markDirty(); // Mark changes
    });
  }

  Future<void> _editScheduleItem(int index, ScheduleItem currentItem) async {
    final titleController = TextEditingController(text: currentItem.title);
    final locationController =
        TextEditingController(text: currentItem.location ?? '');
    final memoController = TextEditingController(text: currentItem.memo ?? '');
    var selectedTime = TimeOfDay.fromDateTime(currentItem.time);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('edit_schedule_item_title'.tr()),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text('time_label'.tr(
                          namedArgs: {'time': selectedTime.format(context)})),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                            context: context, initialTime: selectedTime);
                        if (pickedTime != null) {
                          setDialogState(() {
                            selectedTime = pickedTime;
                          });
                        }
                      },
                    ),
                    TextField(
                        controller: titleController,
                        decoration:
                            InputDecoration(labelText: 'content_label'.tr())),
                    TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                            labelText: 'location_optional_label'.tr())),
                    TextField(
                        controller: memoController,
                        decoration: InputDecoration(
                            labelText: 'memo_optional_label'.tr())),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text('cancel'.tr())),
                TextButton(
                  onPressed: () {
                    setState(() {
                      final newItem = currentItem.copyWith(
                        time: DateTime(
                            currentItem.time.year,
                            currentItem.time.month,
                            currentItem.time.day,
                            selectedTime.hour,
                            selectedTime.minute),
                        title: titleController.text,
                        location: locationController.text.isEmpty
                            ? null
                            : locationController.text,
                        memo: memoController.text.isEmpty
                            ? null
                            : memoController.text,
                      );
                      _currentItinerary.scheduleItems[index] = newItem;
                      _currentItinerary.scheduleItems
                          .sort((a, b) => a.time.compareTo(b.time));
                      _markDirty(); // Mark changes
                    });
                    Navigator.of(ctx).pop(true);
                  },
                  child: Text('update_button'.tr()),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('timeline_schedule_updated_message'.tr()),
          backgroundColor: Colors.green));
    }
  }

  // Shows a confirmation dialog if there are unsaved changes.
  Future<bool> _onWillPop() async {
    if (!_isDirty) {
      return true; // If no changes, allow pop.
    }
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('discard_changes_dialog_title'.tr()),
        content: Text('discard_changes_dialog_content'.tr()),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Stay on page
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Leave page
            child: Text('discard_button'.tr(),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final originalTheme = Theme.of(context);
    final newTheme = originalTheme.brightness == Brightness.dark
        ? originalTheme // ダークモードの場合は何もしない
        : originalTheme.copyWith(
            scaffoldBackgroundColor: Colors.white,
            textTheme: originalTheme.textTheme.apply(
              bodyColor: Colors.black87,
              displayColor: Colors.black87,
            ),
            iconTheme: const IconThemeData(color: Colors.black87),
            listTileTheme: const ListTileThemeData(
              iconColor: Colors.black87,
            ),
            inputDecorationTheme: originalTheme.inputDecorationTheme.copyWith(
              labelStyle: const TextStyle(color: Colors.black54),
              iconColor: Colors.black54,
            ),
          );
    // Intercepts the back button press to show the confirmation dialog if needed.
    return Theme(
      data: newTheme,
      child: PopScope(
        canPop: !_isDirty,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          final shouldPop = await _onWillPop();
          if (context.mounted && shouldPop) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AnimatedGradientAppBar(
            title: Text(widget.isNewItinerary
                ? 'new_itinerary_title'.tr()
                : _currentItinerary.title),
            // Ensure icons and text are visible against the gradient background.
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true, // Allows tabs to scroll on smaller screens
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'memo_tab'.tr(), icon: const Icon(Icons.notes)),
                Tab(
                    text: 'schedule_tab'.tr(),
                    icon: const Icon(Icons.calendar_today)),
                Tab(
                    text: 'budget_tab'.tr(),
                    icon: const Icon(Icons.account_balance_wallet)),
                Tab(
                    text: 'belongings_tab'.tr(),
                    icon: const Icon(Icons.backpack)),
              ],
            ),
            actions: [
              if (!widget.isNewItinerary)
                IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'delete'.tr(),
                    onPressed: _deleteItinerary),
              // The icon changes to provide a visual cue when there are unsaved changes.
              IconButton(
                  icon: Icon(_isDirty ? Icons.check_circle : Icons.check),
                  tooltip: 'save'.tr(),
                  onPressed: _saveItinerary),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: しおり (Memo)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _memoController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'memo_hint'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),

              // Tab 2: スケジュール (Schedule)
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('timeline_schedule_title'.tr(),
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text('time_label'.tr(
                          namedArgs: {'time': _selectedTime.format(context)})),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                            context: context, initialTime: _selectedTime);
                        if (pickedTime != null) {
                          setState(() {
                            _selectedTime = pickedTime;
                            _markDirty();
                          });
                        }
                      },
                    ),
                    TextField(
                        controller: _scheduleTitleController,
                        decoration:
                            InputDecoration(labelText: 'content_label'.tr())),
                    const SizedBox(height: 16),
                    TextField(
                        controller: _scheduleLocationController,
                        decoration: InputDecoration(
                            labelText: 'location_optional_label'.tr())),
                    const SizedBox(height: 16),
                    TextField(
                        controller: _scheduleMemoController,
                        decoration: InputDecoration(
                            labelText: 'memo_optional_label'.tr())),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _addScheduleItem,
                        icon: const Icon(Icons.add),
                        label: Text('add_item_button'.tr()),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _currentItinerary.scheduleItems.length,
                      itemBuilder: (context, index) {
                        final item = _currentItinerary.scheduleItems[index];
                        final subtitleParts = [
                          if (item.location != null &&
                              item.location!.isNotEmpty)
                            'location_subtitle'
                                .tr(namedArgs: {'location': item.location!}),
                          if (item.memo != null && item.memo!.isNotEmpty)
                            'memo_subtitle'.tr(namedArgs: {'memo': item.memo!}),
                        ];
                        final subtitle = subtitleParts.join('\n');

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Text(DateFormat.Hm().format(item.time)),
                            title: Text(item.title),
                            subtitle:
                                subtitle.isNotEmpty ? Text(subtitle) : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit),
                                    tooltip: 'edit'.tr(),
                                    onPressed: () =>
                                        _editScheduleItem(index, item)),
                                IconButton(
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'delete'.tr(),
                                    onPressed: () =>
                                        _removeScheduleItem(index)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Tab 3: 予算 (Budget)
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _transportationCostController,
                      decoration: InputDecoration(
                          labelText: 'transportation_cost_label'.tr(),
                          icon: const Icon(Icons.directions_bus),
                          prefixText: '¥'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    TextFormField(
                      controller: _accommodationCostController,
                      decoration: InputDecoration(
                          labelText: 'accommodation_cost_label'.tr(),
                          icon: const Icon(Icons.hotel),
                          prefixText: '¥'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    TextFormField(
                      controller: _ticketCostController,
                      decoration: InputDecoration(
                          labelText: 'ticket_cost_label'.tr(),
                          icon: const Icon(Icons.confirmation_number),
                          prefixText: '¥'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    TextFormField(
                      controller: _localCostController,
                      decoration: InputDecoration(
                          labelText: 'local_cost_label'.tr(),
                          icon: const Icon(Icons.shopping_cart),
                          prefixText: '¥'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'total_label'.tr(namedArgs: {
                          'total': ((double.tryParse(
                                          _transportationCostController.text) ??
                                      0) +
                                  (double.tryParse(
                                          _accommodationCostController.text) ??
                                      0) +
                                  (double.tryParse(
                                          _ticketCostController.text) ??
                                      0) +
                                  (double.tryParse(_localCostController.text) ??
                                      0))
                              .toStringAsFixed(0)
                        }),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),

              // Tab 4: 持ち物 (Belongings)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: TextField(
                                controller: _checklistItemController,
                                decoration: InputDecoration(
                                    hintText: 'add_belonging_hint'.tr()))),
                        IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addChecklistItem),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _currentItinerary.checklist.length,
                        itemBuilder: (context, index) {
                          final item = _currentItinerary.checklist[index];
                          return CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(item.title),
                            value: item.isChecked,
                            onChanged: (bool? value) =>
                                _toggleChecklistItem(index, value),
                            secondary: IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'delete'.tr(),
                              onPressed: () => _removeChecklistItem(index),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
