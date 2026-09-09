import 'package:flutter/material.dart';

class AfghanistanLicensePlate extends StatelessWidget {
  final String province;
  final String categoryLetter;
  final String englishNumber;
  final String farsiNumber;
  final bool isTemporary;

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
      width: 132,
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(5),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ردیف بالایی
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  province,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              Text(
                farsiNumber,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),

              Text(
                categoryLetter,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 1),

          // خط وسط
          const Divider(
            height: 1,
            thickness: 0.7,
            color: Colors.black54,
          ),

          const SizedBox(height: 1),

          // ردیف پایینی
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isTemporary ? "موقت" : "شخصی",
                style: const TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),

              Text(
                englishNumber,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.2,
                ),
              ),

              const Text(
                "AFG",
                style: TextStyle(
                  fontSize: 7,
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
