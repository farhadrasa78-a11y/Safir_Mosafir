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
    // انتخاب شماره پلاک (ترجیحاً شماره فارسی و در غیر این صورت انگلیسی)
    final String displayNum = farsiNumber.isNotEmpty
        ? farsiNumber
        : (englishNumber.isNotEmpty ? englishNumber : "---");

    final String displayProvince = province.isNotEmpty ? province : "کابل";
    final String displayCategory = categoryLetter.isNotEmpty ? categoryLetter : "ش";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
      child: isTemporary
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "موقت",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  displayNum,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // سمت راست (در حالت RTL سمت چپ): حرف دسته (مثلاً «ش»)
                Text(
                  displayCategory,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    "-",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // مرکز: شماره پلاک
                Text(
                  displayNum,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 0.8,
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    "-",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // سمت چپ (در حالت RTL سمت راست): نام ولایت (متغیر)
                Text(
                  displayProvince,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
    );
  }
}
