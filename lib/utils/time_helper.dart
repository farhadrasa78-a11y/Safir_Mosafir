import 'package:easy_localization/easy_localization.dart';

class TimeHelper {
  /// ۱. تبدیل ثانیه OSRM به متن خوانا (مثلاً: "کمتر از ۱ دقیقه"، "۵ دقیقه" یا "۱ ساعت و ۱۵ دقیقه")
  static String formatDuration(double durationInSeconds) {
    if (durationInSeconds <= 0) return "کمتر از ۱ دقیقه";

    int minutes = (durationInSeconds / 60).round();

    if (minutes < 1) {
      return "کمتر از ۱ دقیقه";
    } else if (minutes < 60) {
      return "$minutes دقیقه";
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return "$hours ساعت";
      }
      return "$hours ساعت و $remainingMinutes دقیقه";
    }
  }

  /// ۲. محاسبه ساعت دقیق رسیدن به مقصد (ETA) به فرمت 24 ساعته (مثلاً 14:35)
  static String getArrivalTime(double durationInSeconds) {
    if (durationInSeconds <= 0) {
      DateTime now = DateTime.now();
      return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    }

    int totalMinutes = (durationInSeconds / 60).round();
    if (totalMinutes < 1) totalMinutes = 1;

    // اضافه کردن دقیقه‌ها به زمان فعلی
    DateTime arrivalTime = DateTime.now().add(Duration(minutes: totalMinutes));

    String hour = arrivalTime.hour.toString().padLeft(2, '0');
    String minute = arrivalTime.minute.toString().padLeft(2, '0');

    return "$hour:$minute";
  }
}
