import 'package:flutter/material.dart';

// ایمپورت مدل رانندگان آنلاین اطراف
import '../models/online_nearby_drivers.dart';

class ManageDriversMethods {
  // لیست رانندگان آنلاین سفیر در نزدیکی مسافر
  static List<OnlineNearbyDrivers> nearbyOnlineDriversList = [];

  // حذف راننده از لیست (مثلاً وقتی آفلاین شده یا سفری را پذیرفته است)
  static void removeDriverFromList(String driverId) {
    int index = nearbyOnlineDriversList
        .indexWhere((driver) => driver.uidDriver == driverId);

    if (index != -1) {
      nearbyOnlineDriversList.removeAt(index);
    } else {
      debugPrint("Driver with ID $driverId was not found in the active nearby list.");
    }
  }

  // به‌روزرسانی لحظه‌ای موقعیت مکانی رانندگان روی نقشه سفیر
  static void updateOnlineNearbyDriversLocation(
      OnlineNearbyDrivers nearbyOnlineDriverInformation) {
    int index = nearbyOnlineDriversList.indexWhere((driver) =>
        driver.uidDriver == nearbyOnlineDriverInformation.uidDriver);

    if (index != -1) {
      nearbyOnlineDriversList[index].latDriver =
          nearbyOnlineDriverInformation.latDriver;
      nearbyOnlineDriversList[index].lngDriver =
          nearbyOnlineDriverInformation.lngDriver;
    } else {
      debugPrint(
          "Driver with ID ${nearbyOnlineDriverInformation.uidDriver} was not found for coordinate update.");
    }
  }

  // پاک‌سازی کامل لیست رانندگان آنلاین (هنگام لغو یا اتمام جستجوی سفر)
  static void clearNearbyDriversList() {
    nearbyOnlineDriversList.clear();
  }
}
