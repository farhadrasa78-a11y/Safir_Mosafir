import 'package:flutter/material.dart';

class AfghanistanLicensePlate extends StatelessWidget {
  final String province;
  final String categoryLetter;
  final String farsiNumber;
  final String englishNumber;
  final bool isTemporary;

  const AfghanistanLicensePlate({
    super.key,
    this.province = "کابل",
    this.categoryLetter = "ش",
    required this.farsiNumber,
    this.englishNumber = "",
    this.isTemporary = false,
  });

  @override
  Widget build(BuildContext context) {
    // اگر شماره فارسی خالی باشد، از شماره انگلیسی استفاده می‌کند و بالعکس
    final String displayNum = farsiNumber.isNotEmpty
        ? farsiNumber
        : (englishNumber.isNotEmpty ? englishNumber : "---");

    final String displayProvince = province.isNotEmpty ? province : "کابل";
    final String displayCategory = categoryLetter.isNotEmpty ? categoryLetter : "ش";

    return Container(
      width: 140,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.black87,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAlignment.center,
        children: [
          // سمت چپ: نوع کتبی (شخصی / موقت)
          Text(
            isTemporary ? "موقت" : "شخصی",
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),

          // وسط: شماره پلاک (درشت و خوانا)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              displayNum,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 0.8,
              ),
            ),
          ),

          // سمت راست: دسته و ولایت (مثلاً: کابل - ش)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayCategory,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                displayProvince,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
