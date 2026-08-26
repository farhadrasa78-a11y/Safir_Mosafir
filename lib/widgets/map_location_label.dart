import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:safir_passengers/theme/app_colors.dart';

// 📍 ۱. لیبل مدرن مبدأ (حلقه دایره‌ای آبی + چوبک اسنپ)
class MapOriginLabel extends StatelessWidget {
  final String? labelText;

  const MapOriginLabel({super.key, this.labelText});

  @override
  Widget build(BuildContext context) {
    final String displayText = (labelText != null && labelText!.trim().isNotEmpty)
        ? labelText!
        : context.tr('origin');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // کادر اصلی سفید آدرس
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔵 آیکون دایره‌ای استاندارد مبدأ
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppColors.originBlue, // آبی مبدأ
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                displayText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // 📍 پایه چوبکی زیر کادر
        Container(
          width: 2.5,
          height: 10,
          color: Colors.grey.shade800,
        ),
        // نقطه سیاه اتصال چوبک به زمین
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

// 🟩 ۲. لیبل مدرن و دوتکه مقصد (مربع سبز سفیر + زمان واقعی رسیدن + چوبک اسنپ)
class MapDestinationLabel extends StatelessWidget {
  final String? labelText;
  final String? arrivalTime; // زمان واقعی رسیدن (مثلاً "12:45")

  const MapDestinationLabel({
    super.key,
    this.labelText,
    this.arrivalTime,
  });

  @override
  Widget build(BuildContext context) {
    final String displayText = (labelText != null && labelText!.trim().isNotEmpty)
        ? labelText!
        : context.tr('destination');

    bool hasArrivalTime = arrivalTime != null && arrivalTime!.trim().isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // کادر اصلی مقصد
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ⏱️ بخش اول: نمایش ساعت واقعی رسیدن OSRM (مثلاً 12:45)
                if (hasArrivalTime) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        arrivalTime!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                ],

                // 🟩 بخش دوم: آیکون مربع سبز سفیر + متن مقصد
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // آیکون مربع سبز سفیر
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBrand,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Center(
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 📍 پایه چوبکی زیر کادر
        Container(
          width: 2.5,
          height: 10,
          color: Colors.grey.shade800,
        ),
        // نقطه سیاه اتصال چوبک به زمین
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
