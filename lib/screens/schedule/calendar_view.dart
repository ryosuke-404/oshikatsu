import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; // For firstWhereOrNull
import '../../services/theme_provider.dart';
import '../../models/schedule_models.dart';
import '../../models/oshi_model.dart'; // Import Oshi model
import '../../utils/custom_page_route.dart';
import 'view_event_screen.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => CalendarViewState();
}

class CalendarViewState extends State<CalendarView> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  EventCategory? _selectedCategory;
  final Set<String> _selectedOshiIds = {};

  DateTime? get selectedDay => _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day, List<Event> allEvents) {
    final List<Event> eventsForDay = [];

    // 既存のイベントをフィルタリング
    for (final event in allEvents) {
      final isMatchingCategory =
          _selectedCategory == null || event.category == _selectedCategory;
      final isMatchingOshi = _selectedOshiIds.isEmpty ||
          (event.oshiId != null && _selectedOshiIds.contains(event.oshiId!));

      if (event.isYearlyRecurring) {
        // 毎年の繰り返しイベントの場合、月日のみを比較
        if (event.date.month == day.month &&
            event.date.day == day.day &&
            isMatchingCategory &&
            isMatchingOshi) {
          // 仮想イベントとして新しいIDで追加
          eventsForDay.add(Event(
            id: '${event.id}-${day.year}', // ユニークなIDを生成
            title: event.title,
            date: day, // 表示する日付に設定
            memo: event.memo,
            oshiId: event.oshiId,
            category: event.category,
            priority: event.priority,
            isYearlyRecurring: true, // 仮想イベントも繰り返し設定を持つ
          ));
        }
      } else {
        // 通常のイベントの場合、日付全体を比較
        if (isSameDay(event.date, day) &&
            isMatchingCategory &&
            isMatchingOshi) {
          eventsForDay.add(event);
        }
      }
    }

    return eventsForDay;
  }

  void _onDaySelected(
      DateTime selectedDay, DateTime focusedDay, List<Event> allEvents) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay, allEvents);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isNeonMode = themeProvider.isNeonMode;

    return ValueListenableBuilder<Box<Event>>(
      valueListenable: Hive.box<Event>('events').listenable(),
      builder: (context, eventBox, _) {
        final allEvents = eventBox.values.toList();
        // Reintroduce Oshi box listener here
        return ValueListenableBuilder<Box<Oshi>>(
          valueListenable: Hive.box<Oshi>('oshis').listenable(),
          builder: (context, oshiBox, _) {
            final allOshis =
                oshiBox.values.toList(); // allOshis is available here

            _selectedEvents.value = _getEventsForDay(_selectedDay!, allEvents);

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildCategorySelector(),
                  _buildOshiFilter(allOshis, isNeonMode, allEvents),
                  TableCalendar<Event>(
                    locale: context.locale.toString(),
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: _calendarFormat,
                    availableCalendarFormats: {
                      CalendarFormat.month: 'calendar_format_month'.tr(),
                      CalendarFormat.twoWeeks: 'calendar_format_two_weeks'.tr(),
                    },
                    eventLoader: (day) => _getEventsForDay(day, allEvents),
                    onDaySelected: (selectedDay, focusedDay) =>
                        _onDaySelected(selectedDay, focusedDay, allEvents),
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleTextStyle: TextStyle(
                          color: isNeonMode ? Colors.white : Colors.black,
                          fontSize: 18),
                      leftChevronIcon: Icon(Icons.chevron_left,
                          color: isNeonMode ? Colors.white : Colors.black),
                      rightChevronIcon: Icon(Icons.chevron_right,
                          color: isNeonMode ? Colors.white : Colors.black),
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: TextStyle(
                          color: isNeonMode ? Colors.white70 : Colors.black87),
                      weekendTextStyle: TextStyle(
                          color:
                              isNeonMode ? Colors.white70 : Colors.redAccent),
                      outsideTextStyle: TextStyle(
                          color: isNeonMode ? Colors.white30 : Colors.grey),
                      todayDecoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          final uniqueCategories =
                              events.map((e) => e.category).toSet();
                          return Positioned(
                            bottom: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: uniqueCategories.map((category) {
                                final details = eventCategoryDetails[category];
                                if (details == null) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 1.0),
                                    child: Icon(Icons.help_outline,
                                        size: 16.0, color: Colors.grey),
                                  );
                                }

                                Color iconColor = details['color']
                                    as Color; // Default to category color

                                if (category == EventCategory.birthday) {
                                  // Find a birthday event for this category to get the Oshi's color
                                  final birthdayEvent = events.firstWhereOrNull(
                                    (e) =>
                                        e.category == EventCategory.birthday &&
                                        e.oshiId != null,
                                  );
                                  if (birthdayEvent != null &&
                                      birthdayEvent.oshiId != null) {
                                    final oshi = allOshis.firstWhereOrNull(
                                        (o) => o.id == birthdayEvent.oshiId);
                                    if (oshi != null &&
                                        oshi.mainColorValue != null) {
                                      iconColor = Color(oshi.mainColorValue!);
                                    }
                                  }
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1.0),
                                  child: Icon(
                                    details['icon'] as IconData,
                                    size: 16.0,
                                    color: iconColor,
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                  const Divider(),
                  ValueListenableBuilder<List<Event>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      if (value.isEmpty) {
                        return Center(child: Text('no_events_for_day'.tr()));
                      }
                      value.sort((a, b) => a.date.compareTo(b.date));
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          final event = value[index];
                          final details = eventCategoryDetails[event.category];
                          return ListTile(
                            leading: Icon(
                                details?['icon'] as IconData? ??
                                    Icons.help_outline,
                                color:
                                    details?['color'] as Color? ?? Colors.grey),
                            title: Text(event.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DateFormat('yyyy/MM/dd')
                                    .format(event.date)),
                                if (event.oshiId != null)
                                  Text(allOshis
                                      .firstWhere(
                                          (oshi) => oshi.id == event.oshiId!,
                                          orElse: () => Oshi(
                                              id: '',
                                              name: '',
                                              startDate: DateTime.now(),
                                              level: OshiLevel.kininaru))
                                      .name),
                              ],
                            ),
                            onTap: () => Navigator.of(context).push(
                                CustomPageRoute(
                                    child: ViewEventScreen(event: event))),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategorySelector() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isNeonMode = themeProvider.isNeonMode;
    final defaultTextColor = isNeonMode ? Colors.white : Colors.black;
    const selectedTextColor = Colors.white;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: Text('all'.tr()),
            selected: _selectedCategory == null,
            selectedColor: Theme.of(context).primaryColor,
            labelStyle: TextStyle(
                color: _selectedCategory == null
                    ? selectedTextColor
                    : defaultTextColor),
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedCategory = null);
              }
            },
          ),
          ...EventCategory.values
              .where((cat) => eventCategoryDetails.containsKey(cat))
              .map((category) {
            final details = eventCategoryDetails[category]!;
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: ChoiceChip(
                avatar: Icon(details['icon'] as IconData,
                    size: 16,
                    color: isSelected
                        ? selectedTextColor
                        : details['color'] as Color),
                label: Text('event_category_${category.name}'.tr()),
                selected: isSelected,
                selectedColor: details['color'] as Color,
                labelStyle: TextStyle(
                    color: isSelected ? selectedTextColor : defaultTextColor),
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOshiFilter(
      List<Oshi> allOshis, bool isNeonMode, List<Event> allEvents) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: allOshis.map((oshi) {
            final isSelected = _selectedOshiIds.contains(oshi.id);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: FilterChip(
                avatar: CircleAvatar(
                  backgroundImage:
                      (oshi.imagePath != null && oshi.imagePath!.isNotEmpty)
                          ? FileImage(File(oshi.imagePath!))
                          : null,
                  child: (oshi.imagePath == null || oshi.imagePath!.isEmpty)
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
                label: Text(oshi.name),
                selected: isSelected,
                selectedColor: oshi.mainColorValue != null
                    ? Color(oshi.mainColorValue!)
                    : Theme.of(context).primaryColor,
                labelStyle: TextStyle(
                  color: isSelected
                      ? (ThemeData.estimateBrightnessForColor(
                                  oshi.mainColorValue != null
                                      ? Color(oshi.mainColorValue!)
                                      : Theme.of(context).primaryColor) ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      : (isNeonMode ? Colors.white : Colors.black),
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedOshiIds.add(oshi.id);
                    } else {
                      _selectedOshiIds.remove(oshi.id);
                    }
                    // Refresh events when Oshi filter changes
                    _selectedEvents.value =
                        _getEventsForDay(_selectedDay!, allEvents);
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
