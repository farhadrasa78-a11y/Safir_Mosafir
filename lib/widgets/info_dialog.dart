import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

import '../globle/global_var.dart';
import '../theme/app_colors.dart'; // آدرس فایل رنگ‌ها

class InfoDialog extends StatelessWidget {
  final String? title, description;

  const InfoDialog({
    super.key, 
    this.title, 
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.cardLightBg, // پس‌زمینه روشن کارت (#EAF6F1)
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primaryBrand, // برند (#145A41)
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                title ?? (getTranslation('notice_title') ?? 'توجه'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                description ?? (getTranslation('restart_required_desc') ?? 'برای اعمال تغییرات، برنامه نیاز به بازنشانی دارد.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Restart.restartApp();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton, // دکمه اصلی (#1B7A57)
                    foregroundColor: AppColors.buttonPressed, // حالت لمس (#0F4A35)
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    getTranslation('got_it_confirm') ?? "فهمیدم (تایید)",
                    style: const TextStyle(
                      color: AppColors.buttonText, // متن سفید (#FFFFFF)
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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
