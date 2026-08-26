import 'package:flutter/material.dart';

// ایمپورت ثوابت و پالت رنگی اختصاصی سفیر
import '../theme/app_colors.dart'; // آدرس فایل رنگ‌ها را در صورت نیاز اصلاح کنید

class SafirPremiumSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const SafirPremiumSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 78,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: value
              ? const LinearGradient(
                  colors: [
                    AppColors.primaryBrand,  // #145A41
                    AppColors.primaryButton, // #1B7A57
                  ], 
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: value ? null : Colors.grey[300],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // متن ON / OFF
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              top: 9,
              left: value ? 12 : 40,
              child: Text(
                value ? 'ON' : 'OFF',
                style: TextStyle(
                  color: value ? AppColors.buttonText : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            // دایره متحرک سوئیچ
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              left: value ? 44 : 4,
              top: 4,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
