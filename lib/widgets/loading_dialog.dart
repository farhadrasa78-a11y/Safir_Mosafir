import 'package:flutter/material.dart';

// ایمپورت ثوابت، ترجمه و پالت رنگی اختصاصی سفیر
import '../globle/global_var.dart';
import '../theme/app_colors.dart'; // آدرس فایل رنگ‌ها را در صورت نیاز اصلاح کنید

class LoadingDialog extends StatelessWidget {
  final String messageText;

  const LoadingDialog({
    super.key,
    required this.messageText,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // راست‌چین کردن متن بارگذاری
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              // انیمیشن چرخشی با رنگ اصلی برند (#145A41)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBrand),
                ),
              ),
              const SizedBox(width: 20),
              // متن پیام بارگذاری با پشتیبانی از چندزبانه
              Expanded(
                child: Text(
                  getTranslation(messageText) ?? messageText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
