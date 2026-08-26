import 'package:flutter/material.dart';

// اصلاح ایمپورت قدیمی اوبر به مسیر محلی و نسبی جدید سفیر
import '../models/address_models.dart';

class AppInfoClass extends ChangeNotifier {
  AddressModel? pickUpLocation;  // ذخیره موقعیت مبدأ مسافر
  AddressModel? dropOffLocation; // ذخیره موقعیت مقصد مسافر

  // به‌روزرسانی مبدأ و باخبر کردن تمام بخش‌های برنامه (مثل نقشه سفیر)
  void updatePickUpLocation(AddressModel pickUpModel) {
    pickUpLocation = pickUpModel;
    notifyListeners();  
  }

  // به‌روزرسانی مقصد و باخبر کردن لایه‌های مختلف برنامه
  void updateDropOffLocation(AddressModel dropOffModel) {
    dropOffLocation = dropOffModel;
    notifyListeners();
  }
}
