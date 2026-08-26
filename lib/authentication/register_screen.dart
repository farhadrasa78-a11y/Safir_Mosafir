import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

// ایمپورت‌های پکیج سفیر مسافر و تم‌ها
import 'package:safir_passengers/appInfo/auth_provider.dart';
import 'package:safir_passengers/authentication/user_information_screen.dart';
import 'package:safir_passengers/methods/common_methods.dart';
import 'package:safir_passengers/pages/blocked_screen.dart';
import 'package:safir_passengers/pages/safir_home_screen.dart';
import 'package:safir_passengers/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.locale.languageCode == 'en') {
        context.setLocale(const Locale('fa'));
      }
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  CommonMethods commonMethods = CommonMethods();

  bool _isPhoneValid(String input) {
    String clean = input.trim();
    return RegExp(r'^[7][0-9]{8}$').hasMatch(clean);
  }

  // تابع ارتباط از طریق واتساپ برای تست فامیل‌ها در افغانستان
  Future<void> sendCodeViaWhatsApp() async {
    String rawPhoneNumber = phoneController.text.trim();
    if (rawPhoneNumber.startsWith('0')) {
      rawPhoneNumber = rawPhoneNumber.substring(1);
    }

    if (!_isPhoneValid(rawPhoneNumber)) {
      commonMethods.displaySnackBar(
        'register.invalid_phone_warning'.tr(),
        context,
      );
      return;
    }

    String fullNumber = '93$rawPhoneNumber';
    String message = Uri.encodeComponent('register.whatsapp_default_message'.tr());
    Uri whatsappUri = Uri.parse("https://wa.me/$fullNumber?text=$message");

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        commonMethods.displaySnackBar('register.whatsapp_not_installed'.tr(), context);
      }
    } catch (e) {
      debugPrint("WhatsApp launch error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // هدر بالای صفحه
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrand.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_taxi_rounded,
                        color: AppColors.primaryBrand,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                
                // عناوین خوش‌آمدگویی
                Text(
                  'register.title'.tr(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'register.subtitle'.tr(),
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                
                // 📱 کادر شماره موبایل قفل شده روی افغانستان (+93)
                Row(
                  children: [
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: const Row(
                        children: [
                          Text('🇦🇫', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 6),
                          Text(
                            '+93',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: phoneController,
                        maxLength: 9,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.phone,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: AppColors.textPrimary,
                        ),
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '781234567',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                            letterSpacing: 1.0,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.primaryBrand, width: 1.8),
                          ),
                          suffixIcon: _isPhoneValid(phoneController.text)
                              ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // 🟢 دکمه واتساپ
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: sendCodeViaWhatsApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA6E300),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'register.receive_whatsapp'.tr(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 📱 دکمه ارسال پیامک فایربیس
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: authProvider.isLoading ? null : sendPhoneNumberViaFirebase,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: AppColors.primaryBrand, strokeWidth: 2.5),
                          )
                        : Text(
                            'register.send_sms_instead'.tr(),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 28),
                
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Text(
                        'register.or_continue_with'.tr(),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 24),
                
                // ورود با گوگل
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: authProvider.isLoading ? null : () => signInWithGoogleProcess(authProvider),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                          height: 20,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.g_mobiledata_rounded, color: Colors.redAccent, size: 28),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'register.google_sign_in'.tr(),
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
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

  void sendPhoneNumberViaFirebase() {
    final authRepo = Provider.of<AuthenticationProvider>(context, listen: false);
    String rawPhoneNumber = phoneController.text.trim();
    if (rawPhoneNumber.startsWith('0')) rawPhoneNumber = rawPhoneNumber.substring(1);

    if (!_isPhoneValid(rawPhoneNumber)) {
      commonMethods.displaySnackBar('register.invalid_phone_warning'.tr(), context);
      return;
    }

    String fullPhoneNumber = '+93$rawPhoneNumber';
    authRepo.signInWithPhone(context: context, phoneNumber: fullPhoneNumber);
  }

    Future<void> signInWithGoogleProcess(AuthenticationProvider authProvider) async {
    await authProvider.signInWithGoogle(
      context,
      () async {
        bool userExits = await authProvider.checkUserExistById();
        bool userExistInDatabse = await authProvider.checkUserExistByEmail(
            authProvider.firebaseAuth.currentUser!.email!.toString());
        if (userExits && userExistInDatabse) {
          bool isBlocked = await authProvider.checkIfUserIsBlocked();
          if (isBlocked) {
            if (!mounted) return;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BlockedScreen()));
          } else {
            await authProvider.getUserDataFromFirebaseDatabase();
            navigate(isSingedIn: true);
          }
        } else {
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
