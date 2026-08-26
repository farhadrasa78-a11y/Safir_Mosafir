import 'package:flutter/material.dart';

class AfghanistanLicensePlate extends StatelessWidget {
  final String province;      // نام ولایت (مثلاً: کابل، هرات، بلخ)
  final String categoryLetter; // حرف یا کد (مثلاً: ش، ش-۳)
  final String englishNumber;  // شماره پلاک به انگلیسی (مثلاً: 44892)
  final String farsiNumber;    // شماره پلاک به فارسی (مثلاً: ٤٤٨٩٢)
  final bool isTemporary;      // آیا موقت است یا شخصی/دائمی

  const AfghanistanLicensePlate({
    super.key,
    this.province = "کابل",
    this.categoryLetter = "ش",
    required this.englishNumber,
    required this.farsiNumber,
    this.isTemporary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150, // عرض قابل تنظیم پلاک
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA), // پس‌زمینه سفید/کرمی ملایم
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black87, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 ردیف بالا: نام ولایت (سمت چپ)، شماره فارسی (وسط)، حرف/نوع (سمت راست)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                province,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'IranYekan', // یا هر فونت فارسی دیگری که دارید
                ),
              ),
              Text(
                farsiNumber,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 1,
                ),
              ),
              Text(
                categoryLetter,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 2),
          const Divider(height: 1, thickness: 1, color: Colors.black54),
          const SizedBox(height: 2),

          // 🔹 ردیف پایین: نوع پلاک (سمت چپ)، شماره انگلیسی (وسط)، پرچم/کد (سمت راست)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isTemporary ? "موقت" : "شخصی",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              Text(
                englishNumber,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                "AFG",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
