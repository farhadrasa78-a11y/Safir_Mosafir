class PredictionModel {
  String? place_id;       // آی‌دی مکان (هماهنگ با UI)
  String? main_text;      // نام اصلی مکان (مانند: "چوک ده افغانان")
  String? secondary_text; // آدرس فرعی/شهر (مانند: "کابل، افغانستان")
  String? lat;            // عرض جغرافیایی (Latitude)
  String? lng;            // طول جغرافیایی (Longitude)

  PredictionModel({
    this.place_id,
    this.main_text,
    this.secondary_text,
    this.lat,
    this.lng,
  });

  // دریافت اطلاعات از JSON و تبدیل امن به مدل
  PredictionModel.fromJson(Map<String, dynamic> json) {
    place_id = json["place_id"]?.toString() ?? json["osm_id"]?.toString();

    // استخراج نام اصلی مکان
    main_text = json["name"] ?? json["display_name"]?.toString().split(',').first.trim();

    // استخراج آدرس فرعی (بدون تکرار نام اصلی)
    if (json["display_name"] != null) {
      List<String> parts = json["display_name"].toString().split(',');
      if (parts.length > 1) {
        secondary_text = parts.sublist(1).join(',').trim();
      } else {
        secondary_text = json["display_name"].toString().trim();
      }
    } else {
      secondary_text = json["secondary_text"]?.toString();
    }

    // گرفتن مستقیم مختصات از پاسخ OpenStreetMap (Nominatim)
    lat = json["lat"]?.toString();
    lng = json["lon"]?.toString() ?? json["lng"]?.toString();
  }

  // تبدیل مدل به Map/JSON جهت ذخیره‌سازی یا انتقال
  Map<String, dynamic> toJson() {
    return {
      'place_id': place_id,
      'main_text': main_text,
      'secondary_text': secondary_text,
      'lat': lat,
      'lng': lng,
    };
  }
}
