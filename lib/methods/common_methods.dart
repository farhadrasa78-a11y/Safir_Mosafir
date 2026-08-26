import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// ایمپورت‌های هماهنگ با ساختار پروژه سفیر
import '../global/global_var.dart';
import '../appInfo/app_info.dart'; 
import '../models/address_models.dart';
import '../models/direction_details.dart';

class CommonMethods {
  
  // بررسی زنده بودن اتصال اینترنت کاربر (سازگار با نسخه جدید connectivity_plus)
  checkConnectivity(BuildContext context) async {
    var connectionResult = await Connectivity().checkConnectivity();

    if (connectionResult.contains(ConnectivityResult.none) || connectionResult.isEmpty) {
      if (!context.mounted) return;
      displaySnackBar(
        getTranslation(context, "no_internet_connection"),
        context,
      );
    }
  }

  // نمایش پیام‌های سیستم به صورت هوشمند متناسب با زبان انتخابی
  displaySnackBar(String messageText, BuildContext context) {
    var snackBar = SnackBar(
      content: Text(
        messageText,
        style: const TextStyle(fontSize: 14),
      ),
      backgroundColor: safirBrandColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // متد عمومی ارسال درخواست به وب‌سرویس‌ها
  static sendRequestToAPI(String apiUrl) async {
    try {
      http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));
      if (responseFromAPI.statusCode == 200) {
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      } else {
        return "error";
      }
    } catch (errorMsg) {
      return "error";
    }
  }

  /// تبدیل مختصات به آدرس متنی (Reverse GeoCoding) بر اساس OpenStreetMap
  static Future<String> convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
      Position position, BuildContext context) async {
    String humanReadableAddress = "";
    
    String apiGeoCodingUrl =
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&accept-language=fa,fa-AF";

    var responseFromAPI = await sendRequestToAPI(apiGeoCodingUrl);

    if (responseFromAPI != "error" && responseFromAPI["display_name"] != null) {
      humanReadableAddress = responseFromAPI["display_name"];

      AddressModel model = AddressModel();
      model.humanReadableAddress = humanReadableAddress;
      model.placeName = shortenAddress(humanReadableAddress);
      model.longitudePosition = position.longitude;
      model.latitudePosition = position.latitude;

      if (context.mounted) {
        Provider.of<AppInfo>(context, listen: false).updatePickUpLocation(model);
      }
    }

    return humanReadableAddress;
  }

  /// کوتاه‌سازی آدرس‌های بسیار طولانی OpenStreetMap
  static String shortenAddress(String fullAddress) {
    List<String> parts = fullAddress.split(',');
    if (parts.length >= 3) {
      return "${parts[0].trim()}، ${parts[1].trim()}";
    }
    return fullAddress;
  }

  /// دریافت اطلاعات کامل مسیر (فاصله و زمان) از OSRM با پشتیبانی چندزبانه
  static Future<DirectionDetails?> getDirectionDetailsFromAPI(
      dynamic source, dynamic destination, BuildContext context) async {
    
    String urlDirectionAPI =
        "https://router.project-osrm.org/route/v1/driving/${source.longitude},${source.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson";

    var responseFromDirectionAPI = await sendRequestToAPI(urlDirectionAPI);

    if (responseFromDirectionAPI == "error" || 
        responseFromDirectionAPI["routes"] == null || 
        responseFromDirectionAPI["routes"].isEmpty) {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();
    try {
      double distanceInMeters = responseFromDirectionAPI["routes"][0]["distance"].toDouble();
      double durationInSeconds = responseFromDirectionAPI["routes"][0]["duration"].toDouble();

      double distanceInKm = distanceInMeters / 1000;
      double durationInMinutes = durationInSeconds / 60;

      String kmUnit = getTranslation(context, "unit_km");
      String minUnit = getTranslation(context, "unit_min");

      directionDetails.distanceTextString = "${distanceInKm.toStringAsFixed(1)} $kmUnit";
      directionDetails.distanceValueDigit = distanceInMeters.toInt();
      
      directionDetails.durationTextString = "${durationInMinutes.toStringAsFixed(0)} $minUnit";
      directionDetails.durationValueDigit = durationInSeconds.toInt();
      
      directionDetails.encodedPoints = responseFromDirectionAPI["routes"][0]["geometry"]["coordinates"].toString();
    } catch (e) {
      return null;
    }
    return directionDetails;
  }

  /// محاسبه قیمت نهایی بر اساس سیستم مالی سفیر به افغانی (AFN)
  calculateFareAmountInAFN(DirectionDetails directionDetails,
      {double surgeMultiplier = 1.0}) {
    double distancePerKmAmountAFN = 10; // ۱۰ افغانی به ازای هر کیلومتر
    double durationPerMinuteAmountAFN = 2; // ۲ افغانی به ازای هر دقیقه
    double baseFareAmountAFN = 30; // قیمت پایه ۳۰ افغانی
    double bookingFeeAFN = 10; // کمیسیون خدمات ۱۰ افغانی
    double minimumFareAFN = 40; // حداقل کرایه ۴۰ افغانی

    double totalDistanceTravelledFareAmountAFN =
        (directionDetails.distanceValueDigit! / 1000) * distancePerKmAmountAFN;
    double totalDurationSpendFareAmountAFN =
        (directionDetails.durationValueDigit! / 60) * durationPerMinuteAmountAFN;

    double totalFareBeforeSurgeAFN = baseFareAmountAFN +
        totalDistanceTravelledFareAmountAFN +
        totalDurationSpendFareAmountAFN +
        bookingFeeAFN;

    double overAllTotalFareAmountAFN = totalFareBeforeSurgeAFN * surgeMultiplier;

    if (overAllTotalFareAmountAFN < minimumFareAFN) {
      overAllTotalFareAmountAFN = minimumFareAFN;
    }

    return overAllTotalFareAmountAFN.toStringAsFixed(0);
  }

  // تبدیل فرمت زمان به ساعت و دقیقه چندزبانه
  String formatTime(int totalMinutes, BuildContext context) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    
    String hrUnit = getTranslation(context, "unit_hr");
    String minUnit = getTranslation(context, "unit_min");
    String andText = getTranslation(context, "word_and");

    if (hours > 0) {
      return "$hours $hrUnit $andText $minutes $minUnit";
    } else {
      return "$minutes $minUnit";
    }
  }
}
