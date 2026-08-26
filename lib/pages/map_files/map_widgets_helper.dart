import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // برای بازخورد لمسی (Haptic)
import 'package:safir_passengers/global/global_var.dart';

class MapWidgetsHelper {
  /// 📍 فیلد نمایش و انتخاب آدرس (مبدأ / مقصد)
  static Widget buildAddressField(
    String text, 
    IconData icon, 
    Color iconColor, 
    Color safirColor, 
    VoidCallback onTap
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity, 
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text, 
                  style: TextStyle(
                    color: safirColor, 
                    fontSize: 14, 
                    overflow: TextOverflow.ellipsis
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔘 دکمه اصلی پایین صفحه (پشتیبانی از ترجمه و Haptic)
  static Widget buildBottomButton({
    required BuildContext? context,
    required String titleKey,
    required Color buttonColor,
    required Color pressedColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity, 
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          overlayColor: pressedColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Text(
          context != null ? getTranslation(context, titleKey) : titleKey,
          style: TextStyle(
            color: textColor, 
            fontSize: 16, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  /// 🏷️ تب‌های دسته‌بندی بالای شیت
  static Widget buildCategoryTab({
    required BuildContext context,
    required int categoryIndex,
    required int selectedCategory,
    required String labelKey,
    required Color safirColor,
    required VoidCallback onTap,
  }) {
    bool isCategorySelected = selectedCategory == categoryIndex;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isCategorySelected ? safirColor : Colors.transparent, 
                width: 2.5
              ),
            ),
          ),
          child: Text(
            getTranslation(context, labelKey),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isCategorySelected ? safirColor : Colors.grey, 
              fontWeight: isCategorySelected ? FontWeight.bold : FontWeight.normal
            ),
          ),
        ),
      ),
    );
  }

  /// 🚗 گزینه انتخاب وسیله نقلیه (با انیمیشن نرم انتخاب و Haptic)
  static Widget buildHorizontalVehicleOption({
    required BuildContext context,
    required int index,
    required int selectedVehicleType,
    required IconData icon,
    required String titleKey,
    required String subtitleKey,
    required String price,
    required Color safirColor,
    required VoidCallback onTap,
  }) {
    bool isSelected = selectedVehicleType == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? safirColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? safirColor : Colors.grey.withOpacity(0.2),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              price, 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? safirColor : Colors.black,
              ),
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      getTranslation(context, titleKey), 
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      getTranslation(context, subtitleKey), 
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Icon(icon, color: safirColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
