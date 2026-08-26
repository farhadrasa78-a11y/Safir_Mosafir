class DirectionDetails {
  String? distanceTextString; // متن مسافت (مثلاً: "۵.۴ کیلومتر")
  String? durationTextString; // متن زمان سفر (مثلاً: "۱۲ دقیقه")
  int? distanceValueDigit;    // مقدار دقیق مسافت به متر (برای محاسبات قیمت)
  int? durationValueDigit;    // مقدار دقیق زمان به ثانیه
  String? encodedPoints;      // مختصات هندسی مسیر جهت رسم روی نقشه سفیر

  DirectionDetails({
    this.distanceTextString,
    this.durationTextString,
    this.distanceValueDigit,
    this.durationValueDigit,
    this.encodedPoints,
  });

  // تبدیل داده‌های دریافتی از Map/JSON به مدل DirectionDetails
  factory DirectionDetails.fromJson(Map<String, dynamic> json) {
    return DirectionDetails(
      distanceTextString: json['distanceTextString'] as String?,
      durationTextString: json['durationTextString'] as String?,
      distanceValueDigit: json['distanceValueDigit'] as int?,
      durationValueDigit: json['durationValueDigit'] as int?,
      encodedPoints: json['encodedPoints'] as String?,
    );
  }

  // تبدیل مدل DirectionDetails به Map/JSON جهت ذخیره‌سازی یا انتقال
  Map<String, dynamic> toJson() {
    return {
      'distanceTextString': distanceTextString,
      'durationTextString': durationTextString,
      'distanceValueDigit': distanceValueDigit,
      'durationValueDigit': durationValueDigit,
      'encodedPoints': encodedPoints,
    };
  }
}
