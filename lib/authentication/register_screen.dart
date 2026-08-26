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
  final Color surfaceBg = const Color(0xFFF9FAFB);

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

  CommonMethods commonMethods = CommonMethods();

  // 🌐 نمایش منوی شیک انتخاب زبان
  void showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              
              const Text(
                'انتخاب زبان / ژبه غوره کړئ / Select Language',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              _buildLanguageTile(
                context: ctx,
                flag: '🇦🇫',
                title: 'فارسی (دری)',
                code: 'fa',
              ),
              const SizedBox(height: 8),

              _buildLanguageTile(
                context: ctx,
                flag: '🇦🇫',
                title: 'پښتو',
                code: 'ps',
              ),
              const SizedBox(height: 8),

              _buildLanguageTile(
                context: ctx,
                flag: '🇬🇧',
                title: 'English',
                code: 'en',
              ),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? safirBrandColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? safirBrandColor : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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

    String currentLangName = 'فارسی';
    if (context.locale.languageCode == 'ps') {
      currentLangName = 'پښتو';
    } else if (context.locale.languageCode == 'en') {
      currentLangName = 'English';
    }

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
                // 🌐 هدر بالای صفحه (انتخاب زبان و نشان سفیر)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // آیکون هویت برند
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

                    // دکمه انتخاب زبان
                    InkWell(
                      onTap: () => showLanguageBottomSheet(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: surfaceBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.language_rounded, size: 18, color: safirBrandColor),
                            const SizedBox(width: 6),
                            Text(
                              currentLangName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: safirBrandColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: safirBrandColor),
                          ],
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
                
                // 📱 فیلد ورود شماره ساده (شروع با 07 و ۱۰ رقم)
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
                  onChanged: (value) {
                    setState(() {});
                  },
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
                
                // دکمه اصلی دریافت کد تایید
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
                
                // جداکننده مدرن
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
                
                // دکمه ورود با گوگل
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            if (!authProvider.isLoading) {
                              await authProvider.signInWithGoogle(
                                context,
                                () async {
                                  bool userExits = await authProvider.checkUserExistById();
                                  bool userExistInDatabse = await authProvider
                                      .checkUserExistByEmail(authProvider
                                          .firebaseAuth.currentUser!.email!
                                          .toString());
                                  if (userExits) {
                                    if (userExistInDatabse) {
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
                                    }
                                  } else {
                                    navigate(isSingedIn: false);
                                  }
                                },
                              );
                            }
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
                                height: 20,
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
                const SizedBox(height: 12),
                
                // دکمه ورود با اپل
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: surfaceBg,
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    label: Text(
                      getTranslation(context, "apple_sign_in_btn"),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const Icon(
                      Icons.apple,
                      color: Colors.black,
                      size: 22,
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

    // حذف صفر ابتدایی برای ساخت فرمت بین‌المللی
    if (rawPhoneNumber.startsWith('0')) {
      rawPhoneNumber = rawPhoneNumber.substring(1);
    }

    // بررسی صحت شماره ۹ رقمی بعد از حذف صفر (مثلاً 781234567)
    if (rawPhoneNumber.isEmpty ||
        rawPhoneNumber.length != 9 ||
        !RegExp(r'^[7][0-9]{8}$').hasMatch(rawPhoneNumber)) {
      commonMethods.displaySnackBar(
        getTranslation(context, "invalid_phone_warning"),
        context,
      );
      return;
    }

    // تبدیل اتوماتیک به +93 در پشت صحنه برای فایربیس
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
