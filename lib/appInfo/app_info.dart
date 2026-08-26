import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safir_passengers/models/address_models.dart';

class AppInfo extends ChangeNotifier {
  AddressModel? pickUpLocation;
  AddressModel? dropOffLocation;

  String _currentLang = 'fa'; // کد زبان پیش‌فرض (fa, ps, en)
  Map<String, String> _localizedStrings = {};

  String get currentLang => _currentLang;

  AppInfo() {
    // بارگذاری زبان پیش‌فرض هنگام اجرا
    loadLanguage(_currentLang);
  }

  /// بارگذاری فایل JSON مربوط به زبان انتخاب‌شده
  Future<void> loadLanguage(String langCode) async {
    _currentLang = langCode;
    try {
      String jsonString = await rootBundle.loadString('assets/lang/$langCode.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });
    } catch (e) {
      debugPrint("خطا در بارگذاری زبان $langCode: $e");
    }
    notifyListeners();
  }

  /// دریافت متن ترجمه‌شده براساس کلید
  /// با قابلیت دریافت پارامترهای پویا مانند: getLocaleText('welcome', {'name': 'علی'})
  String getLocaleText(String key, [Map<String, String>? args]) {
    String text = _localizedStrings[key] ?? key;
    
    if (args != null) {
      args.forEach((placeholder, value) {
        text = text.replaceAll('{$placeholder}', value);
      });
    }
    
    return text;
  }

  /// بهینه‌سازی و به‌روزرسانی مبدأ
  void updatePickUpLocation(AddressModel pickUpModel) {
    pickUpLocation = pickUpModel;
    notifyListeners();
  }

  /// بهینه‌سازی و به‌روزرسانی مقصد
  void updateDropOffLocation(AddressModel dropOffModel) {
    dropOffLocation = dropOffModel;
    notifyListeners();
  }

  /// پاک‌سازی مبدأ و مقصد
  void clearLocations() {
    pickUpLocation = null;
    dropOffLocation = null;
    notifyListeners();
  }
}

typedef AppInfoClass = AppInfo;
