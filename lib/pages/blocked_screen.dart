import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:safir_passengers/authentication/register_screen.dart';

class BlockedScreen extends StatefulWidget {
  const BlockedScreen({super.key});

  @override
  State<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  final Color safirColor = const Color(0xFF145A41);
  bool _isLoggingOut = false;

  // 🔒 متد خروج ایمن و انتقال به صفحه لاگین/ثبت‌نام
  Future<void> _handleSignOutAndRedirect() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      // خروج کامل از فایربیس جهت مسدودسازی دسترسی‌های بعدی
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint("خطا در خروج از حساب مسدود شده: $e");
    } finally {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (c) => const RegisterScreen()),
          (route) => false, // پاک کردن کامل History صفحات قبل
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // غیرفعال کردن دکمه بازگشت گوشی برای کاربر مسدودشده
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🚫 آیکون هشدار و مسدودی محترمانه
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.block_rounded,
                      size: 64,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 📌 عنوان پیام
                  Text(
                    'account_blocked_title'.tr().isEmpty 
                        ? 'حساب کاربری شما مسدود شده است' 
                        : 'account_blocked_title'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  
                  // 📄 متن توضیح بومی‌سازی شده
                  Text(
                    'account_blocked_desc'.tr().isEmpty 
                        ? 'به دلیل نقض قوانین یا فعالیت مشکوک، دسترسی شما به سرویس‌های سفیر موقتاً محدود شده است. جهت بررسی بیشتر با پشتیبانی تماس بگیرید.' 
                        : 'account_blocked_desc'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 36),
                  
                  // 🟢 دکمه تایید و خروج با استایل اختصاصی سفیر
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: safirColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isLoggingOut ? null : _handleSignOutAndRedirect,
                      child: _isLoggingOut
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'btn_i_understand'.tr().isEmpty 
                                  ? 'متوجه شدم' 
                                  : 'btn_i_understand'.tr(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
