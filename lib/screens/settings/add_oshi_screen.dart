import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../app.dart';
import '../../models/oshi_model.dart';
import '../../services/theme_provider.dart';

class AddOshiScreen extends StatefulWidget {
  final bool fromOnboarding;
  const AddOshiScreen({super.key, this.fromOnboarding = false});
  @override
  State<AddOshiScreen> createState() => _AddOshiScreenState();
}

class _AddOshiScreenState extends State<AddOshiScreen> {
  final _nameController = TextEditingController();
  final _officialWebsiteController = TextEditingController();
  final _twitterController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _spotifyController = TextEditingController();
  final _appleMusicController = TextEditingController();
  final _pinterestController = TextEditingController();
  final _threadsController = TextEditingController();
  final _weverseController = TextEditingController();
  OshiLevel? _selectedLevel;
  DateTime _startDate = DateTime.now();
  String? _savedImagePath;
  Color? _mainColor;
  Color? _subColor;

  @override
  void initState() {
    super.initState();
    if (widget.fromOnboarding) {
      _selectedLevel = OshiLevel.saiOshi;
    }
  }

  void _showColorPicker({required bool isMainColor}) {
    Color pickerColor = (isMainColor ? _mainColor : _subColor) ?? Colors.blue;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isMainColor
            ? 'select_main_color_title'.tr()
            : 'select_sub_color_title'.tr()),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('cancel'.tr()),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('ok_button'.tr()),
            onPressed: () {
              setState(() {
                if (isMainColor) {
                  _mainColor = pickerColor;
                } else {
                  _subColor = pickerColor;
                }
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
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

  void _saveOshi() {
    if (_nameController.text.isEmpty || _selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('name_and_classification_required'.tr()),
          backgroundColor: Colors.redAccent));
      return;
    }
    final oshiBox = Hive.box<Oshi>('oshis');
    try {
      final newOshi = Oshi(
        id: const Uuid().v4(),
        name: _nameController.text,
        level: _selectedLevel!,
        startDate: _startDate,
        imagePath: _savedImagePath,
        mainColorValue: _mainColor?.value,
        subColorValue: _subColor?.value,
        officialWebsite: _officialWebsiteController.text.isNotEmpty
            ? _officialWebsiteController.text
            : null,
        twitterUrl:
            _twitterController.text.isNotEmpty ? _twitterController.text : null,
        instagramUrl: _instagramController.text.isNotEmpty
            ? _instagramController.text
            : null,
        facebookUrl: _facebookController.text.isNotEmpty
            ? _facebookController.text
            : null,
        tiktokUrl:
            _tiktokController.text.isNotEmpty ? _tiktokController.text : null,
        youtubeUrl:
            _youtubeController.text.isNotEmpty ? _youtubeController.text : null,
        spotifyUrl:
            _spotifyController.text.isNotEmpty ? _spotifyController.text : null,
        appleMusicUrl: _appleMusicController.text.isNotEmpty
            ? _appleMusicController.text
            : null,
        pinterestUrl: _pinterestController.text.isNotEmpty
            ? _pinterestController.text
            : null,
        threadsUrl:
            _threadsController.text.isNotEmpty ? _threadsController.text : null,
        weverseUrl:
            _weverseController.text.isNotEmpty ? _weverseController.text : null,
      );

      if (newOshi.level == OshiLevel.saiOshi) {
        for (var oshi in oshiBox.values) {
          if (oshi.level == OshiLevel.saiOshi) {
            oshi.level = OshiLevel.oshi;
            oshi.save();
          }
        }
        if (newOshi.mainColorValue != null) {
          Provider.of<ThemeProvider>(context, listen: false).updateTheme(
              mainColor: Color(newOshi.mainColorValue!),
              subColor: newOshi.subColorValue != null
                  ? Color(newOshi.subColorValue!)
                  : null);
        }
        Hive.box('settings').put('mainOshiId', newOshi.id);
      }

      oshiBox.put(newOshi.id, newOshi);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('oshi_saved_message'.tr()),
          backgroundColor: Colors.green));

      if (widget.fromOnboarding) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const App()),
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('oshi_save_failed_message'.tr(args: [e.toString()])),
          backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    // テーマの明るさに応じて、AppBarの文字色やアイコン色を決定
    final appBarForegroundColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.black87 // ライトモードでは黒系の色
            : Colors.white; // ダークモードでは白

    return Scaffold(
      appBar: AppBar(
        title: Text('add_new_oshi_title'.tr()),
        automaticallyImplyLeading: !widget.fromOnboarding,
        // foregroundColorを設定して、タイトルとアイコンの色をまとめて変更
        foregroundColor: appBarForegroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveOshi,
            tooltip: 'save'.tr(),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: InkWell(
                    onTap: _pickImage,
                    child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _savedImagePath != null
                            ? FileImage(File(_savedImagePath!))
                            : null,
                        child: _savedImagePath == null
                            ? const Icon(Icons.add_a_photo, size: 40)
                            : null))),
            const SizedBox(height: 24),
            TextField(
                controller: _nameController,
                decoration: InputDecoration(
                    labelText: 'name_label'.tr(),
                    border: const OutlineInputBorder())),
            const SizedBox(height: 24),
            Text('start_date_label'.tr(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(children: [
              Text(DateFormat('date_format'.tr()).format(_startDate)),
              IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        locale: context.locale);
                    if (picked != null) setState(() => _startDate = picked);
                  })
            ]),
            const SizedBox(height: 24),
            Text('classification_label'.tr(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: OshiLevel.values.map((level) {
                final details = oshiLevelDetails[level];
                final isSelected = _selectedLevel == level;
                return ChoiceChip(
                  label: Text('oshi_level_${level.name}'.tr()),
                  avatar: Icon(details?['icon'] as IconData? ?? Icons.help,
                      color: isSelected ? Colors.white : Colors.black54),
                  selected: isSelected,
                  onSelected: (selected) =>
                      setState(() => _selectedLevel = selected ? level : null),
                  selectedColor:
                      Color(details?['color'] as int? ?? Colors.grey.value),
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('theme_color_label'.tr(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: _mainColor ?? Colors.transparent,
                child: _mainColor == null
                    ? const Icon(Icons.format_color_reset)
                    : null,
              ),
              title: Text('main_color_label'.tr()),
              onTap: () => _showColorPicker(isMainColor: true),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: _subColor ?? Colors.transparent,
                child: _subColor == null
                    ? const Icon(Icons.format_color_reset)
                    : null,
              ),
              title: Text('sub_color_label'.tr()),
              onTap: () => _showColorPicker(isMainColor: false),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            const SizedBox(height: 24),
            TextField(
                controller: _officialWebsiteController,
                decoration: InputDecoration(
                    labelText: 'official_website_optional_label'.tr(),
                    border: const OutlineInputBorder())),
            const SizedBox(height: 24),
            TextField(
                controller: _twitterController,
                decoration: InputDecoration(
                    labelText: 'twitter_x_url_optional_label'.tr(),
                    border: const OutlineInputBorder())),
            const SizedBox(height: 24),
            TextField(
                controller: _instagramController,
                decoration: InputDecoration(
                    labelText: 'instagram_url_optional_label'.tr(),
                    border: const OutlineInputBorder())),
            const SizedBox(height: 24),
            TextField(
                controller: _facebookController,
                decoration: InputDecoration(
                    labelText: 'facebook_url_optional_label'.tr(),
                    border: const OutlineInputBorder())),
            const SizedBox(height: 24),
            TextField(
                controller: _tiktokController,
                decoration: InputDecoration(
                    labelText: 'tiktok_url_optional_label'.tr(),
                    border: const OutlineInputBorder())),
            const SizedBox(height: 24),
            TextField(
                controller: _youtubeController,
                decoration: InputDecoration(
                    labelText: 'youtube_url_optional_label'.tr(),
                    border: const OutlineInputBorder())),
            const SizedBox(height: 24),
            TextField(
                controller: _spotifyController,
                decoration: InputDecoration(
                    labelText: 'spotify_url_optional_label'.tr(),
                    border: const OutlineInputBorder())),
            const SizedBox(height: 24),
            TextField(
                controller: _appleMusicController,
                decoration: InputDecoration(
                    labelText: 'apple_music_url_optional_label'.tr(),
                    border: const OutlineInputBorder())),
            const SizedBox(height: 24),
            TextField(
                controller: _pinterestController,
                decoration: InputDecoration(
                    labelText: 'pinterest_url_optional_label'.tr(),
                    border: const OutlineInputBorder())),
            const SizedBox(height: 24),
            TextField(
                controller: _threadsController,
                decoration: InputDecoration(
                    labelText: 'threads_url_optional_label'.tr(),
                    border: const OutlineInputBorder())),
            const SizedBox(height: 24),
            TextField(
                controller: _weverseController,
                decoration: InputDecoration(
                    labelText: 'weverse_url_optional_label'.tr(),
                    border: const OutlineInputBorder())),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
