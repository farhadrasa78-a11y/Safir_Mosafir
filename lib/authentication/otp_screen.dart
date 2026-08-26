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
    
    final defaultPinTheme = PinTheme(
      width: 54,
      height: 54,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrand.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.primaryBrand, size: 40),
                ),
                const SizedBox(height: 24),

                Text(
                  'otp.title'.tr(),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                Text(
                  'otp.subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 32),

                Pinput(
                  length: 6,
                  showCursor: true,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.primaryBrand, width: 1.5),
                      color: Colors.white,
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.primaryBrand),
                      color: AppColors.primaryBrand.withOpacity(0.05),
                    ),
                  ),
                  onCompleted: (value) {
                    setState(() => smsCode = value);
                    verifyOTP(smsCode: smsCode!);
                  },
                ),
                const SizedBox(height: 32),

                if (authRepo.isLoading)
                  const CircularProgressIndicator(color: AppColors.primaryBrand)
                else if (authRepo.isSuccessful)
                  Container(
                    height: 44,
                    width: 44,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                    child: const Icon(Icons.done, color: Colors.white, size: 26),
                  ),
                const SizedBox(height: 32),

                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.primaryBrand),
                  label: Text(
                    'otp.resend_btn'.tr(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBrand),
                  ),
                ),
              ],
            ),
          ),
        ),
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
