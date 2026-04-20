import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../models/oshi_model.dart';
import '../../services/theme_provider.dart';

class EditOshiScreen extends StatefulWidget {
  final Oshi oshi;
  const EditOshiScreen({super.key, required this.oshi});

  @override
  State<EditOshiScreen> createState() => _EditOshiScreenState();
}

class _EditOshiScreenState extends State<EditOshiScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _officialWebsiteController;
  late final TextEditingController _twitterController;
  late final TextEditingController _instagramController;
  late final TextEditingController _facebookController;
  late final TextEditingController _tiktokController;
  late final TextEditingController _youtubeController;
  late final TextEditingController _spotifyController;
  late final TextEditingController _appleMusicController;
  late final TextEditingController _pinterestController;
  late final TextEditingController _threadsController;
  late final TextEditingController _weverseController;
  late OshiLevel _selectedLevel;
  late DateTime _startDate;
  String? _savedImagePath;
  Color? _mainColor;
  Color? _subColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.oshi.name);
    _officialWebsiteController =
        TextEditingController(text: widget.oshi.officialWebsite);
    _twitterController = TextEditingController(text: widget.oshi.twitterUrl);
    _instagramController =
        TextEditingController(text: widget.oshi.instagramUrl);
    _facebookController = TextEditingController(text: widget.oshi.facebookUrl);
    _tiktokController = TextEditingController(text: widget.oshi.tiktokUrl);
    _youtubeController = TextEditingController(text: widget.oshi.youtubeUrl);
    _spotifyController = TextEditingController(text: widget.oshi.spotifyUrl);
    _appleMusicController =
        TextEditingController(text: widget.oshi.appleMusicUrl);
    _pinterestController =
        TextEditingController(text: widget.oshi.pinterestUrl);
    _threadsController = TextEditingController(text: widget.oshi.threadsUrl);
    _weverseController = TextEditingController(text: widget.oshi.weverseUrl);
    _selectedLevel = widget.oshi.level;
    _startDate = widget.oshi.startDate;
    _savedImagePath = widget.oshi.imagePath;
    if (widget.oshi.mainColorValue != null) {
      _mainColor = Color(widget.oshi.mainColorValue!);
    }
    if (widget.oshi.subColorValue != null) {
      _subColor = Color(widget.oshi.subColorValue!);
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

  void _updateOshi() {
    try {
      widget.oshi.name = _nameController.text;
      widget.oshi.level = _selectedLevel;
      widget.oshi.startDate = _startDate;
      widget.oshi.imagePath = _savedImagePath;
      widget.oshi.mainColorValue = _mainColor?.value;
      widget.oshi.subColorValue = _subColor?.value;
      widget.oshi.officialWebsite = _officialWebsiteController.text.isNotEmpty
          ? _officialWebsiteController.text
          : null;
      widget.oshi.twitterUrl =
          _twitterController.text.isNotEmpty ? _twitterController.text : null;
      widget.oshi.instagramUrl = _instagramController.text.isNotEmpty
          ? _instagramController.text
          : null;
      widget.oshi.facebookUrl =
          _facebookController.text.isNotEmpty ? _facebookController.text : null;
      widget.oshi.tiktokUrl =
          _tiktokController.text.isNotEmpty ? _tiktokController.text : null;
      widget.oshi.youtubeUrl =
          _youtubeController.text.isNotEmpty ? _youtubeController.text : null;
      widget.oshi.spotifyUrl =
          _spotifyController.text.isNotEmpty ? _spotifyController.text : null;
      widget.oshi.appleMusicUrl = _appleMusicController.text.isNotEmpty
          ? _appleMusicController.text
          : null;
      widget.oshi.pinterestUrl = _pinterestController.text.isNotEmpty
          ? _pinterestController.text
          : null;
      widget.oshi.threadsUrl =
          _threadsController.text.isNotEmpty ? _threadsController.text : null;
      widget.oshi.weverseUrl =
          _weverseController.text.isNotEmpty ? _weverseController.text : null;

      if (widget.oshi.level == OshiLevel.saiOshi) {
        final oshiBox = Hive.box<Oshi>('oshis');
        for (var oshi in oshiBox.values) {
          if (oshi.id != widget.oshi.id && oshi.level == OshiLevel.saiOshi) {
            oshi.level = OshiLevel.oshi;
            oshi.save();
          }
        }
        if (_mainColor != null) {
          Provider.of<ThemeProvider>(context, listen: false)
              .updateTheme(mainColor: _mainColor!, subColor: _subColor);
        }
        Hive.box('settings').put('mainOshiId', widget.oshi.id);
      }

      widget.oshi.save();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('oshi_updated_message'.tr()),
          backgroundColor: Colors.green));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const App(initialIndex: 4)),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('oshi_update_failed_message'.tr(args: [e.toString()])),
          backgroundColor: Colors.redAccent));
    }
  }

  void _deleteOshi() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text('delete'.tr()),
                content: Text('delete_oshi_confirm_message'.tr()),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('cancel'.tr())),
                  TextButton(
                      onPressed: () {
                        try {
                          widget.oshi.delete();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('oshi_deleted_message'.tr()),
                              backgroundColor: Colors.green));
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('oshi_delete_failed_message'
                                  .tr(args: [e.toString()])),
                              backgroundColor: Colors.redAccent));
                          Navigator.of(ctx).pop();
                        }
                      },
                      child: Text('delete'.tr(),
                          style: const TextStyle(color: Colors.red)))
                ]));
  }

  @override
  Widget build(BuildContext context) {
    final appBarForegroundColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.black87 // ライトモードでは黒系の色
            : Colors.white; // ダークモードでは白

    return Scaffold(
      appBar: AppBar(
        title: Text('edit_oshi_title'.tr()),
        foregroundColor: appBarForegroundColor,
        actions: [
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteOshi,
              tooltip: 'delete'.tr()),
          IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateOshi,
              tooltip: 'save'.tr())
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
                        backgroundImage: _savedImagePath != null &&
                                _savedImagePath!.isNotEmpty
                            ? FileImage(File(_savedImagePath!))
                            : null,
                        child:
                            _savedImagePath == null || _savedImagePath!.isEmpty
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
                final themeProvider =
                    Provider.of<ThemeProvider>(context, listen: false);
                final isNeonMode = themeProvider.isNeonMode;
                final details = oshiLevelDetails[level];
                final isSelected = _selectedLevel == level;

                const Color selectedTextColor = Colors.white;
                final Color unselectedTextColor = isNeonMode
                    ? Colors.white.withOpacity(0.8)
                    : Colors.black.withOpacity(0.8);
                const Color selectedIconColor = Colors.white;
                final Color unselectedIconColor = isNeonMode
                    ? Colors.white.withOpacity(0.8)
                    : Colors.black.withOpacity(0.6);
                final Color unselectedChipColor =
                    isNeonMode ? Colors.grey[850]! : Colors.grey[200]!;

                return ChoiceChip(
                  label: Text('oshi_level_${level.name}'.tr()),
                  avatar: Icon(
                    details?['icon'] as IconData? ?? Icons.help,
                    color: isSelected ? selectedIconColor : unselectedIconColor,
                  ),
                  selected: isSelected,
                  onSelected: (selected) =>
                      setState(() => _selectedLevel = level),
                  selectedColor:
                      Color(details?['color'] as int? ?? Colors.grey.value),
                  backgroundColor: unselectedChipColor,
                  labelStyle: TextStyle(
                    color: isSelected ? selectedTextColor : unselectedTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                  showCheckmark: false,
                  pressElevation: 0,
                  elevation: isSelected ? 4 : 1,
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
