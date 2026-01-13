import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppFont {
  system,
  openDyslexic,
}

enum FontSizeOption {
  small,
  medium,
  large,
}

class AccessibilityProvider extends ChangeNotifier {
  static const _fontKey = 'app_font';
  static const _fontSizeKey = 'font_size';

  AppFont _font = AppFont.system;
  FontSizeOption _fontSize = FontSizeOption.medium;

  AppFont get font => _font;
  FontSizeOption get fontSize => _fontSize;

  double get textScale {
    switch (_fontSize) {
      case FontSizeOption.small:
        return 0.9;
      case FontSizeOption.medium:
        return 1.0;
      case FontSizeOption.large:
        return 1.3;
    }
  }


  String? get fontFamily {
    switch (_font) {
      case AppFont.system:
        return null;
      case AppFont.openDyslexic:
        return 'OpenDyslexic';
    }
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _font = AppFont.values[prefs.getInt(_fontKey) ?? 0];
    _fontSize = FontSizeOption.values[prefs.getInt(_fontSizeKey) ?? 1];
    notifyListeners();
  }

  Future<void> setFont(AppFont font) async {
    _font = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fontKey, font.index);
    notifyListeners();
  }

  Future<void> setFontSize(FontSizeOption size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fontSizeKey, size.index);
    notifyListeners();
  }
}
