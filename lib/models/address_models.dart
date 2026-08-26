class AddressModel {
  String? humanReadableAddress; // آدرس کامل و خوانا
  double? latitudePosition;     // عرض جغرافیایی (Latitude)
  double? longitudePosition;    // طول جغرافیایی (Longitude)
  String? placeID;              // آی‌دی منحصر به فرد مکان
  String? placeName;            // نام اختصاصی مکان (مثل نام چوک، سرک یا منطقه)

  AddressModel({
    this.humanReadableAddress,
    this.latitudePosition,
    this.longitudePosition,
    this.placeID,
    this.placeName,
  });

  // تبدیل داده‌های دریافتی از Map/JSON به مدل AddressModel
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      humanReadableAddress: json['humanReadableAddress'] as String?,
      latitudePosition: (json['latitudePosition'] as num?)?.toDouble(),
      longitudePosition: (json['longitudePosition'] as num?)?.toDouble(),
      placeID: json['placeID'] as String?,
      placeName: json['placeName'] as String?,
    );
  }

  // تبدیل مدل AddressModel به Map/JSON جهت ذخیره‌سازی یا ارسال به سرور
  Map<String, dynamic> toJson() {
    return {
      'humanReadableAddress': humanReadableAddress,
      'latitudePosition': latitudePosition,
      'longitudePosition': longitudePosition,
      'placeID': placeID,
      'placeName': placeName,
    };
  }
}
