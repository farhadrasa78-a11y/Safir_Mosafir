class PredictedPlaces {
  String? placeId;       // آی‌دی منحصر به فرد مکان
  String? mainText;      // نام اصلی مکان (مثلاً: "چوک ده افغانان")
  String? secondaryText; // آدرس تکمیلی/شهر (مثلاً: "کابل، افغانستان")
  double? lat;           // عرض جغرافیایی
  double? lng;           // طول جغرافیایی

  PredictedPlaces({
    this.placeId,
    this.mainText,
    this.secondaryText,
    this.lat,
    this.lng,
  });

  // تبدیل داده‌های JSON به مدل (سازگار با OpenStreetMap و سایر APIهای نقشه)
  factory PredictedPlaces.fromJson(Map<String, dynamic> json) {
    String? main;
    String? secondary;

    // ۱. بررسی ساختار پاسخ گوگل مپ (در صورت استفاده از گوگل)
    if (json["structured_formatting"] != null) {
      main = json["structured_formatting"]["main_text"];
      secondary = json["structured_formatting"]["secondary_text"];
    } 
    // ۲. بررسی ساختار پاسخ OpenStreetMap / Nominatim (پاسخ‌های رایگان)
    else if (json["display_name"] != null) {
      List<String> parts = (json["display_name"] as String).split(',');
      main = parts.isNotEmpty ? parts[0].trim() : json["display_name"];
      secondary = parts.length > 1 ? parts.sublist(1).join(',').trim() : '';
    } 
    // ۳. کلیدهای مستقیم پیش‌فرض
    else {
      main = json["main_text"] ?? json["name"];
      secondary = json["secondary_text"] ?? json["address"];
    }

    // استخراج مختصات جغرافیایی (سازگار با double یا String)
    double? latitude = json["lat"] != null ? double.tryParse(json["lat"].toString()) : null;
    double? longitude = (json["lng"] ?? json["lon"]) != null 
        ? double.tryParse((json["lng"] ?? json["lon"]).toString()) 
        : null;

    return PredictedPlaces(
      placeId: json["place_id"]?.toString() ?? json["osm_id"]?.toString(),
      mainText: main,
      secondaryText: secondary,
      lat: latitude,
      lng: longitude,
    );
  }

  // تبدیل مدل به Map/JSON جهت ذخیره‌سازی یا ارسال
  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'main_text': mainText,
      'secondary_text': secondaryText,
      'lat': lat,
      'lng': lng,
    };
  }
}
