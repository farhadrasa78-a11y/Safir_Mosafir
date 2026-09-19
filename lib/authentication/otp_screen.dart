import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:safir_passengers/appInfo/auth_provider.dart';
import 'package:safir_passengers/authentication/user_information_screen.dart';
import 'package:safir_passengers/methods/common_methods.dart';
import 'package:safir_passengers/pages/blocked_screen.dart';
import 'package:safir_passengers/pages/safir_home_screen.dart';
import 'package:safir_passengers/theme/app_colors.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  const OTPScreen({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String? smsCode;
  CommonMethods commonMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthenticationProvider>(context, listen: true);
    final currentLangCode = context.locale.languageCode;
    final bool isRtl = currentLangCode != 'en';

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 52,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_back_ios_new_rounded : Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderLight, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 🛡️ آیکون دایره‌ای بالای صفحه با رنگ مشکی متون
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrand.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.textPrimary,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // عناوین تأیید کد
              Center(
                child: Text(
                  'otp_title'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'otp_subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // 🏷️ هدر بخش ورودی Pinput
              _buildSectionHeader(
                currentLangCode == 'en' ? 'Verification Code' : 'کد تأیید',
              ),

              // 📱 فیلد Pinput داخل کارت سفید اختصاصی UI جدید
              _buildCardGroup([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Center(
                    child: Pinput(
                      length: 6,
                      showCursor: true,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(color: AppColors.primaryBrand, width: 2),
                        ),
                      ),
                      submittedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(color: AppColors.primaryBrand, width: 1.5),
                          color: AppColors.primaryBrand.withOpacity(0.05),
                        ),
                      ),
                      onCompleted: (value) {
                        setState(() => smsCode = value);
                        verifyOTP(smsCode: smsCode!);
                      },
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 24),

              // نمایش حالت Loading یا Success
              if (authRepo.isLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBrand),
                )
              else if (authRepo.isSuccessful)
                Center(
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                    child: const Icon(Icons.done_rounded, color: Colors.white, size: 28),
                  ),
                ),

              const SizedBox(height: 16),

              // دکمه ارسال مجدد کد
              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: AppColors.primaryBrand,
                  ),
                  label: Text(
                    'otp_resend_btn'.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBrand,
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

  // 🛠️ متدهای ساخت کارت و هدر هماهنگ با UI بخش ورود و تنظیمات
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }

  void verifyOTP({required String smsCode}) {
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);

    authProvider.verifyOTP(
      context: context,
      verificationId: widget.verificationId,
      smsCode: smsCode,
      onSuccess: () async {
        try {
          bool userExits = await authProvider.checkUserExistById().timeout(
            const Duration(seconds: 4),
            onTimeout: () => false,
          );

          if (!mounted) return;

          if (userExits) {
            bool isBlocked = false;
            try {
              isBlocked = await authProvider.checkIfUserIsBlocked();
            } catch (e) {
              isBlocked = false;
            }

            if (isBlocked) {
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BlockedScreen()));
              return;
            }

            try {
              await authProvider.getUserDataFromFirebaseDatabase();
            } catch (e) {
              debugPrint("Error fetching passenger data: $e");
            }

            bool isUserComplete = false;
            try {
              isUserComplete = await authProvider.checkUserFieldsFilled();
            } catch (e) {
              isUserComplete = false;
            }

            if (isUserComplete) {
              navigate(isSingedIn: true);
            } else {
              navigate(isSingedIn: false);
            }
          } else {
            navigate(isSingedIn: false);
          }
        } catch (globalError) {
          navigate(isSingedIn: false);
        }
      },
    );
  }

  void navigate({required bool isSingedIn}) {
    if (isSingedIn) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SafirHomeScreen()), (route) => false);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const UserInformationScreen()));
    }
  }
}
