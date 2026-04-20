import 'package:flutter/material.dart';
import 'package:oshikatu/utils/app_icons.dart';

class IconPickerDialog extends StatelessWidget {
  const IconPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // ダイアログに表示するアイコンのリスト
    final icons = AppIcons.iconMap.values.toList();

    return AlertDialog(
      title: const Text('アイコンを選択'),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, // 1行に表示するアイコンの数
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: icons.length,
          itemBuilder: (context, index) {
            final icon = icons[index];
            return InkWell(
              onTap: () {
                // アイコンがタップされたら、そのIconDataを返してダイアログを閉じる
                Navigator.of(context).pop(icon);
              },
              borderRadius: BorderRadius.circular(50),
              child: Icon(
                icon,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // キャンセルボタン
          },
          child: const Text('キャンセル'),
        ),
      ],
    );
  }
}
