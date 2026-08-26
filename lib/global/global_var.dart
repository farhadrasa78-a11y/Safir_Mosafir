import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:easy_localization/easy_localization.dart';

// -------------------------------------------------------------
// 1. مشخصات عمومی کاربر متصل‌شده به حساب سفیر
// -------------------------------------------------------------
String userName = "";
String userPhone = "";
String userEmail = "";
String userID = "";

// وضعیت جاری سفر (جهت نمایش در شیث‌های نقشه)
String tripStatusDisplay = "";

// -------------------------------------------------------------
// 2. تنظیمات کلیدهای سرویس‌ها
// -------------------------------------------------------------
String stripePublishedKey = "YOUR_STRIPE_KEY";

// -------------------------------------------------------------
// 3. موقعیت پیش‌فرض نقشه (کابل - افغانستان)
// -------------------------------------------------------------
final LatLng initialPosition = const LatLng(34.5553, 69.2075);

// -------------------------------------------------------------
// 4. پالت رنگی مرجع پروژه مسافر سفیر
// -------------------------------------------------------------
const Color safirBrandColor = Color(0xFF145A41); // سبز زمردی اختصاصی سفیر
const Color safirSuccessColor = Color(0xFF22C55E); // سبز روشن وضعیت موفقیت

// -------------------------------------------------------------
// 5. متد مرجع ترجمه پویای کلمات (متصل به Easy Localization)
// -------------------------------------------------------------
String getTranslation(BuildContext context, String key) {
  try {
    return key.tr(); // خواندن مستقیم از فایل‌های assets/lang/*.json
  } catch (e) {
    return key;
  }
}

// -------------------------------------------------------------
// 6. توابع تبدیل اعداد (فارسی / انگلیسی)
// -------------------------------------------------------------

/// ۱. تبدیل اعداد انگلیسی به فارسی/دری (برای نمایش در UI)
String toPersianDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const farsi   = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], farsi[i]);
  }
  return input;
}

/// ۲. تبدیل اعداد فارسی/دری به انگلیسی (برای ذخیره‌سازی استاندارد در دیتابیس)
String toEnglishDigits(String input) {
  const farsi   = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  for (int i = 0; i < farsi.length; i++) {
    input = input.replaceAll(farsi[i], english[i]);
  }
  return input;
}

/// ۳. تابع هوشمند: تبدیل اعداد فقط در صورتی که زبان برنامه فارسی/دری باشد
String formatNumberByLocale(BuildContext context, String input) {
  Locale currentLocale = Localizations.localeOf(context);
  if (['fa', 'prs', 'ps'].contains(currentLocale.languageCode) || 
      currentLocale.toString().contains('fa')) {
    return toPersianDigits(input);
  }
  return input;
}
