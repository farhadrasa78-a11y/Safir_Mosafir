import 'package:flutter/material.dart';
import 'package:safir_passengers/global/global_var.dart';

// -------------------------------------------------------------
// مشخصات راننده پذیرنده درخواست سفر
// -------------------------------------------------------------
String nameDriver = '';
String photoDriver = '';
String phoneNumberDriver = '';
String carDetailsDriver = '';

// مدت زمان انتظار جهت پذیرش سفر توسط راننده (بر حسب ثانیه)
int requestTimeoutDriver = 40; 

// کد وضعیت سفر دریافتی از دیتابیس (مانند: 'accepted', 'arrived', 'ontrip', 'ended')
String status = '';

// -------------------------------------------------------------
// متد دریافت متنی پویا و چندزبانه برای وضعیت سفر
// -------------------------------------------------------------
String getTripStatusDisplay(BuildContext context) {
  switch (status) {
    case 'accepted':
      return getTranslation(context, "status_driver_accepted");
    case 'arrived':
      return getTranslation(context, "status_driver_arrived");
    case 'ontrip':
      return getTranslation(context, "status_on_trip");
    case 'ended':
      return getTranslation(context, "status_trip_ended");
    default:
      return getTranslation(context, "status_driver_coming");
  }
}

// -------------------------------------------------------------
// رنگ اختصاصی نشانگر وضعیت سفر متناسب با برند سفیر
// -------------------------------------------------------------
Color getTripStatusColor() {
  switch (status) {
    case 'accepted':
      return const Color(0xFF145A41); // رنگ برند اصلی سفیر (سبز زمردی)
    case 'arrived':
      return Colors.orange.shade700;   // رنگ هشدار رسیدن راننده به مبدأ
    case 'ontrip':
      return const Color(0xFF22C55E); // رنگ سبز روشن در حال سفر
    case 'ended':
      return Colors.blue.shade700;    // رنگ پایان سفر
    default:
      return const Color(0xFF145A41); // رنگ پیش‌فرض سفیر
  }
}
