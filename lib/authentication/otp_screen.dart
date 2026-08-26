import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:safir_passengers/appInfo/auth_provider.dart';
import 'package:safir_passengers/authentication/user_information_screen.dart';
import 'package:safir_passengers/methods/common_methods.dart';
import 'package:safir_passengers/pages/blocked_screen.dart';
import 'package:safir_passengers/pages/safir_home_screen.dart';
import 'package:safir_passengers/global/global_var.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  const OTPScreen({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

CommonMethods commonMethods = CommonMethods();

class _OTPScreenState extends State<OTPScreen> {
  String? smsCode;
  
  // پالت رنگی مرجع پروژه
  final Color safirBrandColor = const Color(0xFF145A41);
  final Color successColor = const Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthenticationProvider>(context, listen: true);
    
    // تم مدرن برای فیلدهای ورود کد OTP
    final defaultPinTheme = PinTheme(
      width: 54,
      height: 54,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
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
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
                    color: safirBrandColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: safirBrandColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  getTranslation(context, "otp_title"),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  getTranslation(context, "otp_subtitle"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                Pinput(
                  length: 6,
                  showCursor: true,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: safirBrandColor, width: 1.5),
                      color: Colors.white,
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: safirBrandColor),
                      color: safirBrandColor.withOpacity(0.05),
                    ),
                  ),
                  onCompleted: (value) {
                    setState(() {
                      smsCode = value;
                    });
                    verifyOTP(smsCode: smsCode!);
                  },
                ),

                const SizedBox(height: 32),

                if (authRepo.isLoading)
                  CircularProgressIndicator(
                    color: safirBrandColor,
                  )
                else if (authRepo.isSuccessful)
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: successColor,
                    ),
                    child: const Icon(
                      Icons.done,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),

                const SizedBox(height: 32),

                Text(
                  getTranslation(context, "otp_not_received"),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),

                TextButton.icon(
                  onPressed: () {
                    // منطق ارسال مجدد کد
                  },
                  icon: Icon(Icons.refresh_rounded, size: 18, color: safirBrandColor),
                  label: Text(
                    getTranslation(context, "otp_resend_btn"),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: safirBrandColor,
                    ),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BlockedScreen()),
              );
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
              if (!mounted) return;
              commonMethods.displaySnackBar(
                getTranslation(context, "complete_info_warning"),
                context,
              );
            }
          } else {
            navigate(isSingedIn: false);
          }
        } catch (globalError) {
          debugPrint("Global login error: $globalError");
          navigate(isSingedIn: false);
        }
      },
    );
  }

  void navigate({required bool isSingedIn}) {
    if (isSingedIn) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SafirHomeScreen()),
          (route) => false);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const UserInformationScreen()));
    }
  }
}
