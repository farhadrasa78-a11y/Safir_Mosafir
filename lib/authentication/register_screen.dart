import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ایمپورت‌های پکیج سفیر مسافر
import 'package:safir_passengers/appInfo/auth_provider.dart';
import 'package:safir_passengers/authentication/user_information_screen.dart';
import 'package:safir_passengers/methods/common_methods.dart';
import 'package:safir_passengers/pages/blocked_screen.dart';
import 'package:safir_passengers/pages/safir_home_screen.dart';
import 'package:safir_passengers/global/global_var.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController phoneController = TextEditingController();

  // پالت رنگی اختصاصی و مدرن سفیر
  final Color safirBrandColor = const Color(0xFF145A41);
  final Color successColor = const Color(0xFF10B981);
  final Color surfaceBg = const Color(0xFFF8FAFC);

  CommonMethods commonMethods = CommonMethods();

  @override
  void initState() {
    super.initState();
    // 🇦🇫 قفل کردن زبان پیش‌فرض برنامه روی فارسی (دری) در بدو ورود
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

  // 🌐 نمایش منوی مدرن و مینیمال انتخاب زبان
  void showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      elevation: 10,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // دستگیره بالای کشو
              Container(
                width: 38,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'انتخاب زبان / ژبه غوره کړئ',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              _buildLanguageTile(
                context: ctx,
                flag: '🇦🇫',
                title: 'فارسی (دری)',
                code: 'fa',
              ),
              const SizedBox(height: 10),

              _buildLanguageTile(
                context: ctx,
                flag: '🇦🇫',
                title: 'پښتو',
                code: 'ps',
              ),
              const SizedBox(height: 10),

              _buildLanguageTile(
                context: ctx,
                flag: '🇬🇧',
                title: 'English',
                code: 'en',
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String flag,
    required String title,
    required String code,
  }) {
    bool isSelected = context.locale.languageCode == code;
    return InkWell(
      onTap: () {
        context.setLocale(Locale(code));
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? safirBrandColor.withOpacity(0.08) : surfaceBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? safirBrandColor : Colors.grey.shade200,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 15,
                  color: isSelected ? safirBrandColor : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: safirBrandColor, size: 22),
          ],
        ),
      ),
    );
  }

  // 🔍 بررسی صحت شماره موبایل افغانستان (۱۰ رقم شروع با 07)
  bool _isPhoneValid(String input) {
    String clean = input.trim();
    return RegExp(r'^0[7][0-9]{8}$').hasMatch(clean);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    bool isRtl = context.locale.languageCode == 'fa' || context.locale.languageCode == 'ps';

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
                // 🌐 هدر بالای صفحه (فقط آیکون لوگو و آیکون کره زمین)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // آیکون برند
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: safirBrandColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_taxi_rounded,
                        color: safirBrandColor,
                        size: 24,
                      ),
                    ),

                    // دکمه کره زمین برای انتخاب زبان (بدون متن اضافی)
                    InkWell(
                      onTap: () => showLanguageBottomSheet(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: surfaceBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.language_rounded,
                            size: 22,
                            color: safirBrandColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // عناوین خوش‌آمدگویی
                Text(
                  getTranslation(context, "register_title"),
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  getTranslation(context, "register_subtitle"),
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                // 📱 فیلد ورود شماره
                TextFormField(
                  controller: phoneController,
                  maxLength: 10,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Colors.black87,
                  ),
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '0781234567',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.normal,
                    ),
                    filled: true,
                    fillColor: surfaceBg,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: safirBrandColor, width: 1.8),
                    ),
                    prefixIcon: Icon(
                      Icons.phone_android_rounded,
                      color: Colors.grey.shade500,
                      size: 22,
                    ),
                    suffixIcon: _isPhoneValid(phoneController.text)
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: successColor,
                            size: 22,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // دکمه ارسال پیامک
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: sendPhoneNumber,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: safirBrandColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            getTranslation(context, "get_otp_btn"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 28),

                // جداکننده
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Text(
                        getTranslation(context, "or_continue_with"),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 24),

                // 🔴 دکمه کامل و کاملاً فعال ورود با گوگل
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: authProvider.isGoogleSigInLoading
                        ? null
                        : () async {
                            await authProvider.signInWithGoogle(
                              context,
                              () async {
                                bool userExits = await authProvider.checkUserExistById();
                                String userEmail = authProvider.firebaseAuth.currentUser?.email ?? '';
                                bool userExistInDatabase = await authProvider.checkUserExistByEmail(userEmail);

                                if (userExits) {
                                  if (userExistInDatabase) {
                                    bool isBlocked = await authProvider.checkIfUserIsBlocked();
                                    if (isBlocked) {
                                      if (!mounted) return;
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const BlockedScreen()),
                                      );
                                    } else {
                                      await authProvider.getUserDataFromFirebaseDatabase();
                                      navigate(isSingedIn: true);
                                    }
                                  } else {
                                    navigate(isSingedIn: false);
                                  }
                                } else {
                                  navigate(isSingedIn: false);
                                }
                              },
                            );
                          },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: surfaceBg,
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: authProvider.isGoogleSigInLoading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: safirBrandColor, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                                height: 22,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.g_mobiledata_rounded, color: Colors.redAccent, size: 28),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                getTranslation(context, "google_sign_in_btn"),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                // متن قوانین و حریم خصوصی
                Center(
                  child: Text(
                    getTranslation(context, "terms_and_privacy_notice"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11.5,
                      height: 1.5,
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

  void sendPhoneNumber() {
    final authRepo = Provider.of<AuthenticationProvider>(context, listen: false);
    String rawPhoneNumber = phoneController.text.trim();

    if (rawPhoneNumber.startsWith('0')) {
      rawPhoneNumber = rawPhoneNumber.substring(1);
    }

    if (rawPhoneNumber.isEmpty ||
        rawPhoneNumber.length != 9 ||
        !RegExp(r'^[7][0-9]{8}$').hasMatch(rawPhoneNumber)) {
      commonMethods.displaySnackBar(
        getTranslation(context, "invalid_phone_warning"),
        context,
      );
      return;
    }

    String fullPhoneNumber = '+93$rawPhoneNumber';

    authRepo.signInWithPhone(
      context: context,
      phoneNumber: fullPhoneNumber,
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
