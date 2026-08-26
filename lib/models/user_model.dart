class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String blockStatus;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.blockStatus,
  });

  // تبدیل داده‌های دریافتی از فایربیس/دیتابیس به مدل مسافر
  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Safir Passenger', // مقدار پیش‌فرض عمومی
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      blockStatus: map['blockStatus']?.toString() ?? 'no',
    );
  }

  // تبدیل داده‌های JSON به مدل مسافر
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel.fromMap(json);
  }

  // تبدیل اطلاعات مدل مسافر به مپ جهت ذخیره در فایربیس
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'blockStatus': blockStatus,
    };
  }

  // تبدیل مدل به JSON جهت ذخیره محلی یا ارسال
  Map<String, dynamic> toJson() => toMap();
}
