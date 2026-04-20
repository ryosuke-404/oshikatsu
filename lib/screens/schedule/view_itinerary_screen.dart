import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Hiveをインポート
import '../../models/schedule_models.dart';
import 'edit_itinerary_screen.dart';
import '../../utils/custom_page_route.dart';

class ViewItineraryScreen extends StatefulWidget {
  // StatefulWidgetに変更
  final Itinerary itinerary;
  const ViewItineraryScreen({super.key, required this.itinerary});

  @override
  State<ViewItineraryScreen> createState() => _ViewItineraryScreenState();
}

class _ViewItineraryScreenState extends State<ViewItineraryScreen> {
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
            appBarTheme: originalTheme.appBarTheme.copyWith(
              backgroundColor: Colors.white, // AppBarの背景も白に
              foregroundColor: Colors.black87, // AppBarのテキストやアイコンを黒に
              elevation: 0.5, // 少し影をつける
            ),
            iconTheme: const IconThemeData(color: Colors.black87),
            listTileTheme: const ListTileThemeData(
              iconColor: Colors.black87,
            ),
          );

    return Theme(
      data: newTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.itinerary.title), // widget.itineraryに変更
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                // asyncを追加
                await Navigator.of(context).push<Object?>(
                    CustomPageRoute<Object?>(
                        child: EditItineraryScreen(
                            itinerary:
                                widget.itinerary))); // widget.itineraryに変更
                setState(() {}); // 編集後に画面を更新
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.itinerary.title, // widget.itineraryに変更
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '期間: ${DateFormat('y年M月d日').format(widget.itinerary.startDate)} - ${DateFormat('y年M月d日').format(widget.itinerary.endDate)}', // widget.itineraryに変更
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                widget.itinerary.memoContent, // widget.itineraryに変更
                style: const TextStyle(fontSize: 16),
              ),
              // ToDoリストの表示
              if (widget.itinerary.todoList != null &&
                  widget.itinerary.todoList!.isNotEmpty) // 追加
                Column(
                  // 追加
                  crossAxisAlignment: CrossAxisAlignment.start, // 追加
                  children: [
                    // 追加
                    const SizedBox(height: 20), // 追加
                    Text('ToDoリスト',
                        style: Theme.of(context).textTheme.titleMedium), // 追加
                    const SizedBox(height: 8), // 追加
                    ListView.builder(
                      // 追加
                      shrinkWrap: true, // 追加
                      physics: const NeverScrollableScrollPhysics(), // 追加
                      itemCount: widget.itinerary.todoList!.length, // 追加
                      itemBuilder: (context, index) {
                        // 追加
                        final todo = widget.itinerary.todoList![index]; // 追加
                        return CheckboxListTile(
                          // 追加
                          title: Text(
                            // 追加
                            todo.description, // 追加
                            style: TextStyle(
                              // 追加
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null, // 追加
                              color:
                                  todo.isCompleted ? Colors.grey : null, // 追加
                            ), // 追加
                          ), // 追加
                          value: todo.isCompleted, // 追加
                          onChanged: (bool? newValue) {
                            // 追加
                            setState(() {
                              // 追加
                              todo.isCompleted = newValue ?? false; // 追加
                              widget.itinerary.save(); // 親のItineraryを保存
                            }); // 追加
                          }, // 追加
                        ); // 追加
                      }, // 追加
                    ), // 追加
                  ], // 追加
                ), // 追加
            ],
          ),
        ),
      ),
    );
  }
}
