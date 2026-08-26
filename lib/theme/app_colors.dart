import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 🟢 رنگ اصلی برند (برگرفته از هویت بصری سفیر - وقار و امنیت)
  static const Color primaryBrand = Color(0xFF1B7A57);

  // 🟩 دکمه اصلی (ثبت سفر، درخواست، ادامه - پرانرژی و جذاب)
  static const Color primaryButton = Color(0xFF169365);

  // 👆 دکمه هنگام لمس (Pressed)
  static const Color primaryButtonPressed = Color(0xFF0F4A35);
  static const Color primaryPressed = Color(0xFF0F4A35); // جهت رفع ارور map_bottom_sheets
  static const Color buttonPressed = Color(0xFF0F4A35);  // جهت همخوانی با کدهای قبلی

  // 📦 پس‌زمینه کارت‌ها و شیت‌ها
  static const Color cardBackground = Color(0xFFEAF6F1);
  static const Color cardLightBg = Color(0xFFEAF6F1);
  static const Color cardBgLight = Color(0xFFFFFFFF);     // جهت رفع ارور map_bottom_sheets

  // 🎨 پس‌زمینه‌ها و کادرهای عمومی
  static const Color backgroundLight = Color(0xFFF8F9FA); // جهت رفع ارور smart_location_sheet
  static const Color borderLight = Color(0xFFE0E0E0);     // جهت رفع ارور smart_location_sheet

  // ✅ وضعیت‌ها (موفقیت، خطا)
  static const Color success = Color(0xFF22C55E);

  // 📝 متن‌ها و آیکون‌ها
  static const Color buttonText = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color iconSecondary = Color(0xFF757575);   // جهت رفع ارور smart_location_sheet

  // 📍 نقشه و پین‌ها
  static const Color originBlue = Color(0xFF2563EB);
}
