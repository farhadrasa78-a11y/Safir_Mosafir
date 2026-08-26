class OnlineNearbyDrivers {
  String? uidDriver;  // آی‌دی منحصر به فرد راننده
  double? latDriver;  // عرض جغرافیایی (Latitude)
  double? lngDriver;  // طول جغرافیایی (Longitude)

  OnlineNearbyDrivers({
    this.uidDriver,
    this.latDriver,
    this.lngDriver,
  });

  // تبدیل داده‌های دریافتی از دیتابیس/GeoFire به مدل OnlineNearbyDrivers
  factory OnlineNearbyDrivers.fromJson(Map<String, dynamic> json) {
    return OnlineNearbyDrivers(
      uidDriver: json['uidDriver'] as String?,
      latDriver: (json['latDriver'] as num?)?.toDouble(),
      lngDriver: (json['lngDriver'] as num?)?.toDouble(),
    );
  }

  // تبدیل مدل به Map/JSON جهت ذخیره‌سازی یا ارسال
  Map<String, dynamic> toJson() {
    return {
      'uidDriver': uidDriver,
      'latDriver': latDriver,
      'lngDriver': lngDriver,
    };
  }
}
