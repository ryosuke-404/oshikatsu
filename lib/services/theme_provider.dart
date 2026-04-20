import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/oshi_model.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;
  bool _isNeonMode = false;
  final Box<Oshi> _oshiBox = Hive.box<Oshi>('oshis');
  final Box _settingsBox = Hive.box('settings');

  Color _mainColor = const Color(0xFFD9C2F0);
  Color? _subColor;
  LinearGradient? appBarGradient;

  ThemeProvider()
      : _themeData = _createThemeData(const Color(0xFFD9C2F0), false) {
    loadTheme();
  }

  ThemeData get themeData => _themeData;
  Color get mainColor => _mainColor;
  Color? get subColor => _subColor;
  bool get isNeonMode => _isNeonMode;

  void loadTheme() {
    Color mainColor = const Color(0xFFD9C2F0);
    Color? subColor;

    final savedMainColorValue = _settingsBox.get('mainColor');
    if (savedMainColorValue is int) {
      mainColor = Color(savedMainColorValue);
    }
    final savedSubColorValue = _settingsBox.get('subColor');
    if (savedSubColorValue is int) {
      subColor = Color(savedSubColorValue);
    }

    _isNeonMode = _settingsBox.get('isNeonMode') ?? false;

    try {
      final saiOshi =
          _oshiBox.values.firstWhere((oshi) => oshi.level == OshiLevel.saiOshi);
      if (saiOshi.mainColorValue != null) {
        mainColor = Color(saiOshi.mainColorValue!);
      }
      if (saiOshi.subColorValue != null) {
        subColor = Color(saiOshi.subColorValue!);
      }
    } catch (e) {
      // 最推しがいない場合は何もしない
    }

    updateTheme(mainColor: mainColor, subColor: subColor);
  }

  void updateTheme({required Color mainColor, Color? subColor}) {
    _mainColor = mainColor;
    _subColor = subColor;

    if (subColor != null) {
      appBarGradient = LinearGradient(
        colors: [mainColor, subColor, mainColor],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      appBarGradient = null;
    }

    _themeData = _createThemeData(mainColor, _isNeonMode);
    _settingsBox.put('mainColor', mainColor.value);
    if (subColor != null) {
      _settingsBox.put('subColor', subColor.value);
    } else {
      _settingsBox.delete('subColor');
    }
    notifyListeners();
  }

  void toggleNeonMode() {
    _isNeonMode = !_isNeonMode;
    _settingsBox.put('isNeonMode', _isNeonMode);
    loadTheme();
  }

  static ThemeData _createThemeData(Color color, bool isNeonMode) {
    final brightness = color.computeLuminance();
    final textColor = brightness > 0.5 ? Colors.black : Colors.white;
    final materialColor = _createMaterialColor(color);
    const String font = 'NotoSansJP';

    if (isNeonMode) {
      final baseTheme = ThemeData.dark();
      return baseTheme.copyWith(
        primaryColor: color,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent, // グラデーションのために透明にする
          foregroundColor: color,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: font,
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: color.withOpacity(0.5), blurRadius: 5),
              Shadow(color: color.withOpacity(0.5), blurRadius: 10),
            ],
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: color,
          foregroundColor: textColor,
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: color,
          unselectedLabelColor: color.withOpacity(0.7),
          indicatorColor: color,
        ),
        textTheme: baseTheme.textTheme.apply(fontFamily: font).copyWith(
              bodyLarge: TextStyle(
                color: Colors.white,
                shadows: [
                  Shadow(color: color.withOpacity(0.5), blurRadius: 3),
                ],
              ),
              bodyMedium: TextStyle(
                color: Colors.white,
                shadows: [
                  Shadow(color: color.withOpacity(0.5), blurRadius: 3),
                ],
              ),
              titleLarge: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: color.withOpacity(0.7), blurRadius: 5),
                  Shadow(color: color.withOpacity(0.7), blurRadius: 10),
                ],
              ),
            ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
          ),
        ),
        iconTheme: IconThemeData(color: color),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return color;
            }
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return color.withOpacity(0.5);
            }
            return null;
          }),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: color.withOpacity(0.1),
          selectedColor: color,
          labelStyle: TextStyle(color: color),
          secondaryLabelStyle: TextStyle(color: textColor),
          secondarySelectedColor: color,
          checkmarkColor: textColor,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );
    } else {
      return ThemeData(
        primarySwatch: materialColor,
        fontFamily: font,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent, // グラデーションのために透明にする
          foregroundColor: textColor,
          elevation: 0, // Elevationを0に
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: color,
          foregroundColor: textColor,
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: textColor,
          unselectedLabelColor: textColor.withOpacity(0.8),
          indicatorColor: textColor,
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: Colors.grey[800],
              displayColor: Colors.grey[800],
            ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
          ),
        ),
        iconTheme: IconThemeData(color: color),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return color;
            }
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return color.withOpacity(0.5);
            }
            return null;
          }),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: color.withOpacity(0.1),
          selectedColor: color,
          labelStyle: TextStyle(color: color),
          secondaryLabelStyle: TextStyle(color: textColor),
          secondarySelectedColor: color,
          checkmarkColor: textColor,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );
    }
  }

  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
